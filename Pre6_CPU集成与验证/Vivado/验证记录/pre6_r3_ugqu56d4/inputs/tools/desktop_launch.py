"""Launch an authorized desktop tool from the Codex MSIX process context.

Only the newly created wrapper's desktop-app policy is set. No registry,
vendor files, system environment, privileges or existing job policies change.
A private, non-inherited kill-on-close job owns only this invocation's tree.
Atomic JOB_LIST assignment avoids a create/assign orphaning race; closing or
killing this launcher cleans its tree, never another open Vivado instance.

See Microsoft UpdateProcThreadAttribute: DESKTOP_APP_POLICY enable tree=1.
"""
import ctypes as c
from ctypes import wintypes as w
import sys,subprocess

k=c.WinDLL('kernel32',use_last_error=True)
class SI(c.Structure):
    _fields_=[('cb',w.DWORD),('lpReserved',w.LPWSTR),('lpDesktop',w.LPWSTR),('lpTitle',w.LPWSTR),('dwX',w.DWORD),('dwY',w.DWORD),('dwXSize',w.DWORD),('dwYSize',w.DWORD),('dwXCountChars',w.DWORD),('dwYCountChars',w.DWORD),('dwFillAttribute',w.DWORD),('dwFlags',w.DWORD),('wShowWindow',w.WORD),('cbReserved2',w.WORD),('lpReserved2',c.c_void_p),('hStdInput',w.HANDLE),('hStdOutput',w.HANDLE),('hStdError',w.HANDLE)]
class SIEX(c.Structure):
    _fields_=[('si',SI),('attrs',c.c_void_p)]
class PI(c.Structure):
    _fields_=[('process',w.HANDLE),('thread',w.HANDLE),('pid',w.DWORD),('tid',w.DWORD)]
class BasicLimits(c.Structure):
    _fields_=[('process_time',c.c_int64),('job_time',c.c_int64),('flags',w.DWORD),
              ('min_working_set',c.c_size_t),('max_working_set',c.c_size_t),
              ('active_processes',w.DWORD),('affinity',c.c_size_t),
              ('priority',w.DWORD),('scheduling',w.DWORD)]
class IoCounters(c.Structure):
    _fields_=[(name,c.c_uint64) for name in ('read_ops','write_ops','other_ops','read_bytes','write_bytes','other_bytes')]
class ExtendedLimits(c.Structure):
    _fields_=[('basic',BasicLimits),('io',IoCounters),('process_memory',c.c_size_t),
              ('job_memory',c.c_size_t),('peak_process_memory',c.c_size_t),('peak_job_memory',c.c_size_t)]
k.InitializeProcThreadAttributeList.argtypes=[c.c_void_p,w.DWORD,w.DWORD,c.POINTER(c.c_size_t)];k.InitializeProcThreadAttributeList.restype=w.BOOL
k.UpdateProcThreadAttribute.argtypes=[c.c_void_p,w.DWORD,c.c_size_t,c.c_void_p,c.c_size_t,c.c_void_p,c.c_void_p];k.UpdateProcThreadAttribute.restype=w.BOOL
k.DeleteProcThreadAttributeList.argtypes=[c.c_void_p]
k.CreateProcessW.argtypes=[w.LPCWSTR,w.LPWSTR,c.c_void_p,c.c_void_p,w.BOOL,w.DWORD,c.c_void_p,w.LPCWSTR,c.POINTER(SIEX),c.POINTER(PI)];k.CreateProcessW.restype=w.BOOL
k.WaitForSingleObject.argtypes=[w.HANDLE,w.DWORD];k.WaitForSingleObject.restype=w.DWORD
k.GetExitCodeProcess.argtypes=[w.HANDLE,c.POINTER(w.DWORD)];k.GetExitCodeProcess.restype=w.BOOL
k.CloseHandle.argtypes=[w.HANDLE]
k.GetStdHandle.argtypes=[w.DWORD];k.GetStdHandle.restype=w.HANDLE
k.SetHandleInformation.argtypes=[w.HANDLE,w.DWORD,w.DWORD];k.SetHandleInformation.restype=w.BOOL
k.CreateJobObjectW.argtypes=[c.c_void_p,w.LPCWSTR];k.CreateJobObjectW.restype=w.HANDLE
k.SetInformationJobObject.argtypes=[w.HANDLE,c.c_int,c.c_void_p,w.DWORD];k.SetInformationJobObject.restype=w.BOOL

args=sys.argv[1:]
if not args: raise SystemExit('desktop_launch.py <program> [args...]')
job=None;attrs_ready=False;pi=PI();exitcode=w.DWORD()
try:
    # NULL security attributes mean the job handle is NOT inherited by children.
    job=k.CreateJobObjectW(None,None)
    if not job: raise c.WinError(c.get_last_error())
    limits=ExtendedLimits();limits.basic.flags=0x2000  # KILL_ON_JOB_CLOSE
    if not k.SetInformationJobObject(job,9,c.byref(limits),c.sizeof(limits)): raise c.WinError(c.get_last_error())
    size=c.c_size_t()
    k.InitializeProcThreadAttributeList(None,2,0,c.byref(size))
    buf=c.create_string_buffer(size.value)
    if not k.InitializeProcThreadAttributeList(buf,2,0,c.byref(size)): raise c.WinError(c.get_last_error())
    attrs_ready=True
    policy=w.DWORD(1)
    if not k.UpdateProcThreadAttribute(buf,0,0x20012,c.byref(policy),c.sizeof(policy),None,None): raise c.WinError(c.get_last_error())
    jobs=(w.HANDLE*1)(job)
    if not k.UpdateProcThreadAttribute(buf,0,0x2000D,jobs,c.sizeof(jobs),None,None): raise c.WinError(c.get_last_error())
    si=SIEX();si.si.cb=c.sizeof(si);si.attrs=c.cast(buf,c.c_void_p)
    si.si.dwFlags=0x100
    si.si.hStdInput=k.GetStdHandle(-10)
    si.si.hStdOutput=k.GetStdHandle(-11)
    si.si.hStdError=k.GetStdHandle(-12)
    for h in (si.si.hStdInput,si.si.hStdOutput,si.si.hStdError): k.SetHandleInformation(h,1,1)
    cmd=c.create_unicode_buffer(subprocess.list2cmdline(args))
    if not k.CreateProcessW(None,cmd,None,None,True,0x08000000|0x80000,None,None,c.byref(si),c.byref(pi)): raise c.WinError(c.get_last_error())
    print('DESKTOP_JOB_BOUND kill_on_close=1 revision=job1',flush=True)
    print('DESKTOP_WRAPPER_PID',pi.pid,flush=True)
    if k.WaitForSingleObject(pi.process,0xFFFFFFFF)!=0: raise c.WinError(c.get_last_error())
    if not k.GetExitCodeProcess(pi.process,c.byref(exitcode)): raise c.WinError(c.get_last_error())
finally:
    if pi.thread:k.CloseHandle(pi.thread)
    if pi.process:k.CloseHandle(pi.process)
    if attrs_ready:k.DeleteProcThreadAttributeList(buf)
    if job:k.CloseHandle(job)
print('DESKTOP_EXIT',exitcode.value,flush=True)
raise SystemExit(exitcode.value if exitcode.value<128 else 1)
