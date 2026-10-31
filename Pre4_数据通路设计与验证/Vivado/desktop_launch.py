"""Launch an authorized desktop tool from the Codex MSIX process context.

Only the newly created wrapper's desktop-app policy is set. No registry,
vendor files, system environment, privileges or job policies are changed.
The wrapper's descendants use Windows' ordinary desktop DLL search path.

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
k.InitializeProcThreadAttributeList.argtypes=[c.c_void_p,w.DWORD,w.DWORD,c.POINTER(c.c_size_t)];k.InitializeProcThreadAttributeList.restype=w.BOOL
k.UpdateProcThreadAttribute.argtypes=[c.c_void_p,w.DWORD,c.c_size_t,c.c_void_p,c.c_size_t,c.c_void_p,c.c_void_p];k.UpdateProcThreadAttribute.restype=w.BOOL
k.DeleteProcThreadAttributeList.argtypes=[c.c_void_p]
k.CreateProcessW.argtypes=[w.LPCWSTR,w.LPWSTR,c.c_void_p,c.c_void_p,w.BOOL,w.DWORD,c.c_void_p,w.LPCWSTR,c.POINTER(SIEX),c.POINTER(PI)];k.CreateProcessW.restype=w.BOOL
k.WaitForSingleObject.argtypes=[w.HANDLE,w.DWORD];k.WaitForSingleObject.restype=w.DWORD
k.GetExitCodeProcess.argtypes=[w.HANDLE,c.POINTER(w.DWORD)];k.GetExitCodeProcess.restype=w.BOOL
k.CloseHandle.argtypes=[w.HANDLE]
k.GetStdHandle.argtypes=[w.DWORD];k.GetStdHandle.restype=w.HANDLE
k.SetHandleInformation.argtypes=[w.HANDLE,w.DWORD,w.DWORD];k.SetHandleInformation.restype=w.BOOL

args=sys.argv[1:]
if not args: raise SystemExit('desktop_launch.py <program> [args...]')
size=c.c_size_t()
k.InitializeProcThreadAttributeList(None,1,0,c.byref(size))
buf=c.create_string_buffer(size.value)
if not k.InitializeProcThreadAttributeList(buf,1,0,c.byref(size)): raise c.WinError(c.get_last_error())
policy=w.DWORD(1)
if not k.UpdateProcThreadAttribute(buf,0,0x20012,c.byref(policy),4,None,None): raise c.WinError(c.get_last_error())
si=SIEX();si.si.cb=c.sizeof(si);si.attrs=c.cast(buf,c.c_void_p)
si.si.dwFlags=0x100
si.si.hStdInput=k.GetStdHandle(-10)
si.si.hStdOutput=k.GetStdHandle(-11)
si.si.hStdError=k.GetStdHandle(-12)
for h in (si.si.hStdInput,si.si.hStdOutput,si.si.hStdError): k.SetHandleInformation(h,1,1)
cmd=c.create_unicode_buffer(subprocess.list2cmdline(args))
pi=PI()
if not k.CreateProcessW(None,cmd,None,None,True,0x08000000|0x80000,None,None,c.byref(si),c.byref(pi)): raise c.WinError(c.get_last_error())
print('DESKTOP_WRAPPER_PID',pi.pid,flush=True)
k.WaitForSingleObject(pi.process,0xFFFFFFFF)
exitcode=w.DWORD()
k.GetExitCodeProcess(pi.process,c.byref(exitcode))
k.CloseHandle(pi.thread);k.CloseHandle(pi.process)
k.DeleteProcThreadAttributeList(buf)
print('DESKTOP_EXIT',exitcode.value,flush=True)
raise SystemExit(exitcode.value if exitcode.value<128 else 1)
