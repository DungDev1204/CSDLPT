from pathlib import Path
import subprocess
from concurrent.futures import ThreadPoolExecutor

ROOT=Path(__file__).resolve().parent.parent
CONTAINER='csdlpt-nhom8-verify'
BASE=['docker','exec',CONTAINER,'bash','-c',
      'SQLCMDPASSWORD="$MSSQL_SA_PASSWORD" /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C -b -f 65001 "$@"','sql']

def query(s, expected=0):
    p=subprocess.run(BASE+['-Q',s],capture_output=True,encoding='utf-8',errors='replace')
    if p.returncode!=expected:
        raise RuntimeError(p.stdout+p.stderr)
    return p.stdout+p.stderr

def run_file(path):
    subprocess.run(['docker','cp',str(path),CONTAINER+':/tmp/verify.sql'],check=True,capture_output=True)
    p=subprocess.run(BASE+['-i','/tmp/verify.sql'],capture_output=True,encoding='utf-8',errors='replace')
    if p.returncode: raise RuntimeError(p.stdout+p.stderr)
    return p.stdout

# Full submission, then demo twice. No reset of existing test databases.
print('Submission replay: PASS' if run_file(ROOT/'output/Truy_van_xay_dung_CSDLPT_Nhom_8.sql') else 'done')
source=(ROOT/'output/Truy_van_xay_dung_CSDLPT_Nhom_8.sql').read_text(encoding='utf-8-sig')
demo=ROOT/'tmp/project_demo.sql'
demo.write_text(source.replace('DECLARE @RunDemo bit=0;','DECLARE @RunDemo bit=1;'),encoding='utf-8-sig')
run_file(demo); run_file(demo)
print('Demo replay twice: PASS')
query("""USE AirCore; SET NOCOUNT ON;
IF (SELECT COUNT(*) FROM dbo.Payment WHERE ExternalRef='DEMO_PAY_001')<>1 THROW 51999,'Duplicate payment',1;
IF (SELECT COUNT(*) FROM dbo.Ticket t JOIN dbo.SeatHold h ON h.HoldID=t.HoldID WHERE h.RequestID='50000000-0000-0000-0000-000000000001')<>2 THROW 51999,'Duplicate ticket',1;
IF (SELECT Sold FROM dbo.Inventory WHERE FlightID='TEST01' AND FareClass='ECO')<>2 THROW 51999,'Duplicate sold counter',1;
IF (SELECT COUNT(*) FROM AirReporting.dbo.vSalesItemGlobal)<>2 THROW 51999,'Bad reporting projection',1;
IF COL_LENGTH('AirReporting.dn.SalesItem','PassengerDocument') IS NOT NULL THROW 51999,'Private fields leaked',1;
""")
print('Payment/ticket idempotency and reporting projection: PASS')

def contender(i):
    sql=f"""USE AirCore; SET NOCOUNT ON; WAITFOR DELAY '00:00:02';
    DECLARE @H uniqueidentifier;
    EXEC dbo.usp_CreateHold @RequestID='60000000-0000-0000-0000-00000000000{i}',
      @OrderID='70000000-0000-0000-0000-00000000000{i}',@BranchID='HN',
      @FlightID='TEST02',@FareClass='ECO',@Quantity=1,@HoldID=@H OUTPUT;
    SELECT @H;"""
    return subprocess.run(BASE+['-Q',sql],capture_output=True,encoding='utf-8',errors='replace')

with ThreadPoolExecutor(max_workers=2) as pool:
    results=list(pool.map(contender,[1,2]))
if sum(p.returncode==0 for p in results)!=1:
    raise RuntimeError('Last-seat concurrency: '+repr([(p.returncode,p.stdout,p.stderr) for p in results]))
failure=next(p for p in results if p.returncode)
if '51009' not in failure.stdout: raise RuntimeError(failure.stdout+failure.stderr)
query("USE AirCore; IF (SELECT Held+Sold FROM dbo.Inventory WHERE FlightID='TEST02' AND FareClass='ECO')<>1 THROW 51999,'Overbooking',1;")
print('Two concurrent last-seat requests: one success, one 51009, no overbooking: PASS')

test=ROOT/'tmp/project_business_checks.sql'
print(run_file(test).strip())

# Deploy a real-branch profile on the same isolated engine (generic names are new).
node=ROOT/'tmp/project_hn.sql'
node.write_text(source.replace("DECLARE @Node varchar(4)='LAB';","DECLARE @Node varchar(4)='HN';"),encoding='utf-8-sig')
run_file(node); run_file(node)
query("""USE AirBranch;
IF (SELECT BranchID FROM dbo.LocalBranch)<>'HN' THROW 51999,'Wrong branch',1;
IF (SELECT COUNT(*) FROM dbo.CustomerProfile)<>1 THROW 51999,'Seed duplication',1;
IF OBJECT_ID('dbo.usp_CreateOrder','P') IS NULL THROW 51999,'Missing branch procedure',1;
IF NOT EXISTS(SELECT 1 FROM AirReference.sys.tables WHERE name='Flight') THROW 51999,'Missing reference catalog',1;
""")
print('HN node deployment and replay: PASS')
