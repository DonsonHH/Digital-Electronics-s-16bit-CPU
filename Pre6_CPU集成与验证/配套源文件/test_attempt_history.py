"""Record-policy unit fixtures only: these tests do not execute a CPU or Vivado."""
from pathlib import Path
import json,subprocess,sys,tempfile,time,unittest
from unittest.mock import patch
from attempt_history import review_attempt_history,digest
from check_delivery import write_failure,start_report


class AttemptHistoryTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(prefix='pre6_policy_unit_');self.package=Path(self.temp.name)
        self.fixed=[]
        for i in range(8):
            p=self.write(f'accepted_{i}',program=f'p{i}',stamp='2026-11-01T12:00:00+00:00')
            self.fixed.append(dict(relative=p.relative_to(self.package).as_posix(),sha256=digest(p)))

    def tearDown(self):
        assert self.package.resolve().is_relative_to(Path(tempfile.gettempdir()).resolve())and self.package.name.startswith('pre6_policy_unit_')
        self.temp.cleanup()

    def write(self,name,program='p0',status='PASS',stamp='2026-11-02T12:00:00+00:00',native_ok=True):
        p=self.package/'验证记录'/name/'result.json';p.parent.mkdir(parents=True)
        r=dict(kind='cpu',program=program,mode='behavioral',gui_mode=False,status=status,
               started_utc=stamp,native_ok=native_ok,archived_input_sha256={},output_sha256={})
        p.write_text(json.dumps(r),encoding='utf-8');return p

    def check(self):
        def validate(path,record):
            if not record['native_ok']:raise ValueError('Missing native completion')
        return review_attempt_history(self.package,self.fixed,validate)

    def test_original_acceptance(self):
        r=self.check();self.assertEqual((r['status'],r['published_acceptance_records'],r['additional_records']),('PASS',8,0))

    def test_ninth_pass_is_allowed(self):
        self.write('new_pass');r=self.check();self.assertEqual(r['status'],'PASS');self.assertEqual(len(r['validated_passes']),9)

    def test_latest_failure_is_not_hidden_by_old_pass(self):
        self.write('new_fail',status='FAIL');r=self.check();self.assertEqual(r['status'],'FAIL');self.assertEqual(r['latest_nonpass'][0]['status'],'FAIL')

    def test_recovered_failure_is_retained(self):
        self.write('failed',status='FAIL');self.write('recovered',stamp='2026-11-03T12:00:00+00:00')
        r=self.check();self.assertEqual(r['status'],'PASS');self.assertEqual(len(r['historical_nonpass_records']),1)

    def test_incomplete_latest_attempt_cannot_pass(self):
        self.write('incomplete',status='RUNNING');self.assertEqual(self.check()['status'],'FAIL')

    def test_frozen_acceptance_cannot_be_rewritten(self):
        p=self.package/self.fixed[0]['relative'];r=json.loads(p.read_text());r['native_ok']=False;p.write_text(json.dumps(r))
        with self.assertRaisesRegex(ValueError,'Published acceptance'):self.check()

    def test_new_pass_still_needs_native_validation(self):
        self.write('bad_pass',native_ok=False)
        with self.assertRaisesRegex(ValueError,'Missing native'):self.check()

    def test_ambiguous_latest_timestamp_is_rejected(self):
        self.write('a');self.write('b',status='FAIL')
        with self.assertRaisesRegex(ValueError,'Ambiguous latest'):self.check()

    def test_old_report_cannot_remain_pass_after_failure(self):
        report=self.package/'delivery_check.json';report.write_text('{"status":"PASS"}')
        write_failure(report,ValueError('new failure'))
        r=json.loads(report.read_text());self.assertEqual(r['status'],'FAIL');self.assertIn('new failure',r['error'])

    def test_incomplete_check_supersedes_old_pass(self):
        report=self.package/'delivery_check.json';report.write_text('{"status":"PASS"}')
        start_report(report);self.assertEqual(json.loads(report.read_text())['status'],'RUNNING')

    def test_additional_output_hash_is_checked(self):
        p=self.write('bad_hash');(p.parent/'native.log').write_text('fixture')
        r=json.loads(p.read_text());r['output_sha256']={'native.log':'0'*64};p.write_text(json.dumps(r))
        with self.assertRaisesRegex(ValueError,'evidence missing or changed'):self.check()

    def test_evidence_path_cannot_escape_its_record(self):
        p=self.write('escaping');outside=self.package/'outside.txt';outside.write_text('fixture')
        r=json.loads(p.read_text());r['output_sha256']={'../../outside.txt':digest(outside)};p.write_text(json.dumps(r))
        with self.assertRaisesRegex(ValueError,'evidence missing or changed'):self.check()

    def test_missing_receipt_directory_cannot_reuse_old_pass(self):
        (self.package/'验证记录/aborted_before_receipt').mkdir()
        with self.assertRaisesRegex(ValueError,'lacks a receipt'):self.check()

    def test_runner_persists_preflight_failure(self):
        sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'Vivado'))
        import run_project
        work=self.package/'fake_work';work.mkdir()
        def fail_before_native(*args):
            receipt=json.loads((self.package/'验证记录/fake_work/result.json').read_text())
            self.assertEqual(receipt['status'],'RUNNING')
            raise ValueError('intentional unit preflight failure')
        with patch.object(run_project,'ROOT',self.package),patch.object(run_project.tempfile,'mkdtemp',return_value=str(work)),patch.object(run_project,'prepare',side_effect=fail_before_native),patch.object(run_project.subprocess,'Popen')as native:
            with self.assertRaisesRegex(ValueError,'intentional unit'):run_project.run('p0','cpu','behavioral',Path('unused'))
            native.assert_not_called()
        self.assertEqual(json.loads((self.package/'验证记录/fake_work/result.json').read_text())['status'],'FAIL')
        self.assertEqual(self.check()['status'],'FAIL')

    def test_killed_python_worker_leaves_nonpass_visible(self):
        # This worker blocks during fake preflight; it never launches AMD tools.
        script='''from pathlib import Path
import sys
sys.path.insert(0,sys.argv[1])
import run_project
root=Path(sys.argv[2]);work=root/'live_work';work.mkdir()
run_project.ROOT=root
run_project.tempfile.mkdtemp=lambda **kwargs:str(work)
def wait_for_parent(*args):
    (root/'worker_ready').write_text('fake preflight')
    sys.stdin.buffer.read(1)
    raise RuntimeError('parent released fake worker')
run_project.prepare=wait_for_parent
run_project.run('p0','cpu','behavioral',Path('unused'))
'''
        process=subprocess.Popen([sys.executable,'-B','-c',script,str(Path(__file__).resolve().parents[1]/'Vivado'),str(self.package)],stdin=subprocess.PIPE,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE,creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
        try:
            deadline=time.monotonic()+5
            while not(self.package/'worker_ready').exists():
                if process.poll()is not None:self.fail(process.stderr.read().decode(errors='replace'))
                if time.monotonic()>deadline:self.fail('controlled Python worker startup timed out')
                time.sleep(.02)
            self.assertIsNone(process.poll())
            self.assertEqual(self.check()['latest_nonpass'][0]['status'],'RUNNING')
            process.terminate();process.wait(timeout=5)
            self.assertEqual(self.check()['latest_nonpass'][0]['status'],'RUNNING')
        finally:
            if process.poll()is None:process.kill();process.wait(timeout=5)
            process.stdin.close();process.stderr.close()


if __name__=='__main__':unittest.main(verbosity=2)
