"""Keep published acceptance fixed while reviewing later append-only attempts."""
from datetime import datetime
import hashlib,json


def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def review_attempt_history(package,frozen,validate_pass):
    """Validate every PASS; a later failed/incomplete attempt cannot reuse an old PASS."""
    for directory in (package/'验证记录').iterdir():
        if directory.is_dir()and not(directory/'result.json').is_file():
            raise ValueError('Attempt directory lacks a receipt: '+directory.name)
    paths=sorted((package/'验证记录').glob('*/result.json'))
    found={p.relative_to(package).as_posix():p for p in paths}
    fixed={row['relative']:row['sha256']for row in frozen}
    if len(fixed)!=len(frozen):raise ValueError('Duplicate published acceptance record')
    for relative,expected in fixed.items():
        if relative not in found or digest(found[relative])!=expected:
            raise ValueError('Published acceptance record missing or changed: '+relative)
    latest={};passed=[];failed=[]
    for relative,path in found.items():
        record=json.loads(path.read_text(encoding='utf-8-sig'))
        status=record['status']
        if status not in ['PASS','FAIL','RUNNING']:raise ValueError('Unknown attempt status: '+relative)
        if type(record['gui_mode'])is not bool:raise ValueError('Invalid GUI identity: '+relative)
        stamp=datetime.fromisoformat(record['started_utc'].replace('Z','+00:00'))
        if stamp.tzinfo is None:raise ValueError('Attempt timestamp lacks timezone: '+relative)
        profile=tuple(record[k]for k in ['kind','program','mode','gui_mode'])
        if profile in latest and stamp==latest[profile][0]:
            raise ValueError('Ambiguous latest attempt for '+str(profile))
        if profile not in latest or stamp>latest[profile][0]:latest[profile]=(stamp,relative,status)
        for mapping in ['archived_input_sha256','output_sha256']:
            for name,expected in record.get(mapping,{}).items():
                target=(path.parent/name).resolve()
                if not target.is_relative_to(path.parent.resolve())or not target.is_file()or digest(target)!=expected:
                    raise ValueError('Attempt evidence missing or changed: '+relative+' / '+name)
        if status=='PASS':
            validate_pass(path,record)
            passed.append(dict(relative=relative,**{k:record[k]for k in ['program','kind','mode','gui_mode','status']}))
        elif relative in fixed:raise ValueError('Published acceptance is not PASS: '+relative)
        else:failed.append(dict(relative=relative,status=status))
    unresolved=[dict(profile=list(profile),relative=value[1],status=value[2])for profile,value in latest.items()if value[2]!='PASS']
    return dict(status='FAIL'if unresolved else'PASS',published_acceptance_records=len(fixed),
                additional_records=len(paths)-len(fixed),validated_passes=passed,
                historical_nonpass_records=failed,latest_nonpass=unresolved)
