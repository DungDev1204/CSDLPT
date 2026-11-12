from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parent.parent
CONTAINER='csdlpt-nhom8-runready-verify'
BASE=['docker','exec',CONTAINER,'bash','-c',
 'SQLCMDPASSWORD="$MSSQL_SA_PASSWORD" /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C -f 65001 "$@"','sql']
def run(args):
 p=subprocess.run(BASE+args,capture_output=True,encoding='utf-8',errors='replace')
 if p.returncode: raise RuntimeError(p.stdout+p.stderr)
 return p.stdout+p.stderr
def sql(s): return run(['-b','-Q',s])
def file(path,abort=True):
 subprocess.run(['docker','cp',str(path),CONTAINER+':/tmp/check.sql'],check=True,capture_output=True)
 return run((['-b'] if abort else [])+['-i','/tmp/check.sql'])

assertions="""
USE AirCore; SET NOCOUNT ON;
IF (SELECT COUNT(*) FROM dbo.Payment)<>3 THROW 51999,'Payment count',1;
IF (SELECT COUNT(*) FROM dbo.Ticket)<>4 THROW 51999,'Ticket count',1;
IF (SELECT COUNT(*) FROM dbo.Ticket WHERE Status='ISSUED')<>3 THROW 51999,'Issued tickets',1;
IF (SELECT COUNT(*) FROM dbo.Refund)<>1 THROW 51999,'Refund count',1;
IF (SELECT SUM(Amount) FROM dbo.Payment)<>6000000 THROW 51999,'Gross cash',1;
IF (SELECT SUM(Amount) FROM dbo.Refund)<>1500000 THROW 51999,'Refund cash',1;
IF NOT EXISTS(SELECT 1 FROM dbo.Inventory WHERE FlightID='TEST01' AND FareClass='ECO' AND Held=0 AND Sold=3 AND Capacity-Held-Sold=7)
 THROW 51999,'Inventory counters',1;
IF EXISTS(SELECT 1 FROM dbo.Inventory i OUTER APPLY
 (SELECT SUM(Quantity) Q FROM dbo.SeatHold h WHERE h.FlightID=i.FlightID AND h.FareClass=i.FareClass AND Status='ACTIVE') a
 WHERE i.Held<>COALESCE(a.Q,0)) THROW 51999,'Held invariant',1;
IF EXISTS(SELECT 1 FROM dbo.Inventory i OUTER APPLY
 (SELECT COUNT(*) Q FROM dbo.Ticket t JOIN dbo.SeatHold h ON h.HoldID=t.HoldID
 WHERE h.FlightID=i.FlightID AND h.FareClass=i.FareClass AND t.Status='ISSUED') a
 WHERE i.Sold<>a.Q) THROW 51999,'Sold invariant',1;
IF EXISTS(SELECT 1 FROM dbo.SeatHold h OUTER APPLY
 (SELECT COUNT(*) Q FROM dbo.Ticket t WHERE t.HoldID=h.HoldID) a
 WHERE h.Status='CONFIRMED' AND h.Quantity<>a.Q) THROW 51999,'Ticket invariant',1;
IF EXISTS(SELECT 1 FROM dbo.Payment p JOIN dbo.SeatHold h ON h.HoldID=p.HoldID
 WHERE p.Amount<>h.Quantity*h.UnitPrice OR h.Status<>'CONFIRMED') THROW 51999,'Money invariant',1;
IF (SELECT COUNT(*) FROM AirReporting.dbo.vSalesOrderGlobal)<>5 THROW 51999,'Global orders',1;
IF (SELECT COUNT(*) FROM AirReporting.dbo.vSalesOrderGlobal WHERE Status='ISSUED')<>3 THROW 51999,'Global issued orders',1;
IF (SELECT COUNT(*) FROM AirReporting.dbo.vSalesOrderGlobal WHERE Status='CANCELLED')<>2 THROW 51999,'Global cancelled orders',1;
IF (SELECT COUNT(*) FROM AirReporting.dbo.vSalesItemGlobal)<>6 THROW 51999,'Global passengers',1;
IF COL_LENGTH('AirReporting.hcm.SalesItem','PassengerDocument') IS NOT NULL THROW 51999,'Private document copied',1;
IF (SELECT COUNT(*) FROM AirReference_HN.dbo.Flight)<>3
 OR (SELECT COUNT(*) FROM AirReference_DN.dbo.Flight)<>3
 OR (SELECT COUNT(*) FROM AirReference_HCM.dbo.Flight)<>3 THROW 51999,'Catalog replication',1;
IF (SELECT COUNT(*) FROM AirReporting.dbo.SyncWatermark)<>3 THROW 51999,'Copy watermarks',1;
PRINT 'All demo counts, money, invariants, fragments and catalog copies: PASS';
"""
print(sql(assertions).strip())
file(ROOT/'output/Truy_van_xay_dung_CSDLPT_Nhom_8.sql')
print(sql(assertions).strip()); print('Full script replay without duplicate records: PASS')

sql('CREATE DATABASE ForeignCore;')
sql('USE ForeignCore; CREATE TABLE dbo.Sentinel(Value int); INSERT dbo.Sentinel VALUES(123);')
guard=ROOT/'tmp/runready_guard.sql'
guard.write_text((ROOT/'output/Truy_van_xay_dung_CSDLPT_Nhom_8.sql').read_text(encoding='utf-8-sig').replace('AirCore','ForeignCore'),encoding='utf-8-sig')
out=file(guard,abort=False)
if '51000' not in out: raise RuntimeError('Missing ownership rejection: '+out[-2000:])
sql("USE ForeignCore; IF (SELECT COUNT(*) FROM sys.objects WHERE is_ms_shipped=0 AND type IN ('U','V','P'))<>1 OR (SELECT Value FROM dbo.Sentinel)<>123 THROW 51999,'Foreign database modified',1;")
print('Foreign-database guard with SSMS batch continuation: PASS')

# Disposable database fixtures are inside our isolated test container only.
for name in ['AirCore','AirReporting','AirBranch_HN','AirBranch_DN','AirBranch_HCM','AirReference_HN','AirReference_DN','AirReference_HCM']:
 sql(f'USE master; ALTER DATABASE [{name}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [{name}];')
original=ROOT/'tmp/build_project_sql.py'
ns={'__file__':str(original)}
exec(compile(original.read_text(encoding='utf-8').split('\nOUT.write_text(')[0],str(original),'exec'),ns)
legacy=ROOT/'tmp/legacy_project.sql'
legacy.write_text('\n'.join(ns['PARTS']).replace('DECLARE @RunDemo bit=0;','DECLARE @RunDemo bit=1;'),encoding='utf-8-sig')
file(legacy)
file(ROOT/'output/Truy_van_xay_dung_CSDLPT_Nhom_8.sql')
print(sql(assertions).strip())
sql("USE AirBranch_DN; IF (SELECT PassengerName FROM dbo.SalesItem WHERE OrderID='40000000-0000-0000-0000-000000000001' AND ItemNo=1)<>N'Hành khách thử 01' THROW 51999,'Existing passenger overwritten',1;")
print('Upgrade from previous submission, preserving existing passengers and sold counters: PASS')
