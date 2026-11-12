from pathlib import Path
import subprocess

root=Path(__file__).resolve().parent.parent
container='csdlpt-nhom8-verify'
base=['docker','exec',container,'bash','-c',
 'SQLCMDPASSWORD="$MSSQL_SA_PASSWORD" /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C -f 65001 "$@"','sql']
def run(args,ok=True):
 p=subprocess.run(base+args,capture_output=True,encoding='utf-8',errors='replace')
 if ok and p.returncode: raise RuntimeError(p.stdout+p.stderr)
 return p.stdout+p.stderr
def file_run(path,abort=True):
 subprocess.run(['docker','cp',str(path),container+':/tmp/profile.sql'],check=True,capture_output=True)
 return run((['-b'] if abort else [])+['-i','/tmp/profile.sql'])
source=(root/'output/Truy_van_xay_dung_CSDLPT_Nhom_8.sql').read_text(encoding='utf-8-sig')
run(['-b','-Q',"CREATE DATABASE ForeignCore;"])
run(['-b','-Q',"USE ForeignCore; CREATE TABLE dbo.Sentinel(Value int); INSERT dbo.Sentinel VALUES(123);"])
guard=root/'tmp/project_guard.sql'
guard.write_text(source.replace('AirCore','ForeignCore'),encoding='utf-8-sig')
out=file_run(guard,abort=False)
if 'FAIL' not in out or '51000' not in out: raise RuntimeError(out)
run(['-b','-Q',"USE ForeignCore; IF (SELECT COUNT(*) FROM sys.tables)<>1 OR (SELECT Value FROM dbo.Sentinel)<>123 THROW 51999,'Foreign database modified',1;"])
print('Foreign-database guard, including SSMS batch continuation: PASS')

# All names below belong to the disposable verification container created for this task.
for name in ['AirCore','AirReporting','AirBranch_HN','AirBranch_DN','AirBranch_HCM','AirReference_HN','AirReference_DN','AirReference_HCM']:
 run(['-b','-Q',f"USE master; ALTER DATABASE [{name}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [{name}];"])
core=root/'tmp/project_core.sql'
core.write_text(source.replace("DECLARE @Node varchar(4)='LAB';","DECLARE @Node varchar(4)='CORE';"),encoding='utf-8-sig')
file_run(core); file_run(core)
run(['-b','-Q',"USE AirCore; IF OBJECT_ID('dbo.usp_CreateHold','P') IS NULL THROW 51999,'Missing core module',1; IF (SELECT COUNT(*) FROM dbo.Inventory)<>4 THROW 51999,'Missing inventory',1;"])
print('Cold CORE deployment without LAB branch databases and replay: PASS')
