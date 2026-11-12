USE AirCore;
GO
SET NOCOUNT ON; SET XACT_ABORT ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
DECLARE @R uniqueidentifier=NEWID(),@O uniqueidentifier=NEWID(),@H uniqueidentifier,@H2 uniqueidentifier,
 @P uniqueidentifier,@P2 uniqueidentifier,@Error int=0;
EXEC dbo.usp_CreateHold @R,@O,'HN','TEST01','ECO',2,@H OUTPUT;
EXEC dbo.usp_CreateHold @R,@O,'HN','TEST01','ECO',2,@H2 OUTPUT;
IF @H<>@H2 THROW 51999,'Retry hold changed ID',1;
IF (SELECT Held FROM dbo.Inventory WHERE FlightID='TEST01' AND FareClass='ECO')<>2 THROW 51999,'Retry double-held',1;
BEGIN TRY EXEC dbo.usp_CreateHold @R,@O,'HN','TEST01','ECO',3,@H2 OUTPUT; END TRY
BEGIN CATCH SET @Error=ERROR_NUMBER(); END CATCH;
IF @Error<>51004 THROW 51999,'Changed retry payload accepted',1;
SET @Error=0;
BEGIN TRY EXEC dbo.usp_ConfirmHold @H,'HN','CHECK_PAY_001',1,@P OUTPUT; END TRY
BEGIN CATCH SET @Error=ERROR_NUMBER(); END CATCH;
IF @Error<>51015 THROW 51999,'Wrong amount accepted',1;
IF EXISTS(SELECT 1 FROM dbo.Payment WHERE HoldID=@H) THROW 51999,'Failed payment persisted',1;
IF (SELECT Held FROM dbo.Inventory WHERE FlightID='TEST01' AND FareClass='ECO')<>2 THROW 51999,'Rollback changed held',1;
SET @Error=0;
BEGIN TRY EXEC dbo.usp_ConfirmHold @H,'DN','CHECK_PAY_001',3000000,@P OUTPUT; END TRY
BEGIN CATCH SET @Error=ERROR_NUMBER(); END CATCH;
IF @Error<>51011 THROW 51999,'Wrong branch accepted',1;
EXEC dbo.usp_ConfirmHold @H,'HN','CHECK_PAY_001',3000000,@P OUTPUT;
EXEC dbo.usp_ConfirmHold @H,'HN',' CHECK_PAY_001 ',3000000,@P2 OUTPUT;
IF @P<>@P2 THROW 51999,'Payment retry changed ID',1;
IF (SELECT COUNT(*) FROM dbo.Ticket WHERE HoldID=@H)<>2 THROW 51999,'Ticket quantity mismatch',1;
SET @Error=0;
BEGIN TRY EXEC dbo.usp_CancelHold @H,'HN'; END TRY
BEGIN CATCH SET @Error=ERROR_NUMBER(); END CATCH;
IF @Error<>51021 THROW 51999,'Confirmed hold cancelled',1;

DECLARE @T uniqueidentifier=(SELECT TOP(1) TicketID FROM dbo.Ticket WHERE HoldID=@H ORDER BY ItemNo),
 @Refund uniqueidentifier,@Refund2 uniqueidentifier;
EXEC dbo.usp_RefundTicket @T,'HN','CHECK_REFUND_001',@Refund OUTPUT;
EXEC dbo.usp_RefundTicket @T,'HN',' CHECK_REFUND_001 ',@Refund2 OUTPUT;
IF @Refund<>@Refund2 THROW 51999,'Refund retry changed ID',1;
IF (SELECT COUNT(*) FROM dbo.Refund WHERE TicketID=@T)<>1 THROW 51999,'Duplicate refund',1;
IF (SELECT Sold FROM dbo.Inventory WHERE FlightID='TEST01' AND FareClass='ECO')<>3 THROW 51999,'Refund stock incorrect',1;
SET @Error=0;
BEGIN TRY EXEC dbo.usp_RefundTicket @T,'HN','OTHER_REFUND',@Refund2 OUTPUT; END TRY
BEGIN CATCH SET @Error=ERROR_NUMBER(); END CATCH;
IF @Error<>51033 THROW 51999,'Same ticket refunded twice',1;

SET @R=NEWID(); SET @O=NEWID();
EXEC dbo.usp_CreateHold @R,@O,'HCM','TEST01','ECO',1,@H OUTPUT;
EXEC dbo.usp_CancelHold @H,'HCM'; EXEC dbo.usp_CancelHold @H,'HCM';
IF (SELECT Held FROM dbo.Inventory WHERE FlightID='TEST01' AND FareClass='ECO')<>0 THROW 51999,'Cancel leaked seat',1;
SET @Error=0;
BEGIN TRY EXEC dbo.usp_ConfirmHold @H,'HCM','CANCELLED_PAY',1500000,@P OUTPUT; END TRY
BEGIN CATCH SET @Error=ERROR_NUMBER(); END CATCH;
IF @Error<>51014 THROW 51999,'Cancelled hold confirmed',1;
SET @R=NEWID(); SET @O=NEWID();
EXEC dbo.usp_CreateHold @R,@O,'HCM','TEST01','ECO',1,@H OUTPUT;
-- Fixture only: move both timestamps into the past without breaking ExpiresAt>CreatedAt.
UPDATE dbo.SeatHold SET CreatedAt=DATEADD(minute,-20,SYSUTCDATETIME()),ExpiresAt=DATEADD(minute,-1,SYSUTCDATETIME()) WHERE HoldID=@H;
EXEC dbo.usp_ExpireHolds; EXEC dbo.usp_ExpireHolds;
IF (SELECT Status FROM dbo.SeatHold WHERE HoldID=@H)<>'EXPIRED' THROW 51999,'Expiry failed',1;
IF (SELECT Held FROM dbo.Inventory WHERE FlightID='TEST01' AND FareClass='ECO')<>0 THROW 51999,'Expiry leaked seat',1;
SET @R=NEWID(); SET @O=NEWID(); SET @Error=0;
BEGIN TRY EXEC dbo.usp_CreateHold @R,@O,'HN','TEST03','ECO',1,@H OUTPUT; END TRY
BEGIN CATCH SET @Error=ERROR_NUMBER(); END CATCH;
IF @Error<>51007 THROW 51999,'Closed flight booked',1;
IF EXISTS(SELECT 1 FROM dbo.SeatHold WHERE RequestID=@R) THROW 51999,'Invalid hold persisted',1;
IF @@TRANCOUNT<>0 THROW 51999,'Transaction leaked',1;
PRINT 'Hold retries, payload mismatch, amount/branch checks, rollback, refunds, cancellations, expiry and closed flight: PASS';

IF DATABASE_PRINCIPAL_ID('test_booking') IS NULL CREATE USER test_booking WITHOUT LOGIN;
ALTER ROLE booking_executor ADD MEMBER test_booking;
EXECUTE AS USER='test_booking';
SET @Error=0;
BEGIN TRY UPDATE dbo.Inventory SET Sold=Sold WHERE FlightID='TEST01'; END TRY
BEGIN CATCH SET @Error=ERROR_NUMBER(); END CATCH;
IF @Error<>229 THROW 51999,'Direct inventory update not denied',1;
SET @R=NEWID(); SET @O=NEWID();
EXEC dbo.usp_CreateHold @R,@O,'HN','TEST01','BUS',1,@H OUTPUT;
EXEC dbo.usp_CancelHold @H,'HN';
REVERT;
PRINT 'Booking role can execute business procedures and cannot update Inventory: PASS';

-- Assert the invariant queries rather than relying only on visual empty result sets.
IF EXISTS(SELECT 1 FROM dbo.Inventory i OUTER APPLY
 (SELECT SUM(Quantity) Q FROM dbo.SeatHold h WHERE h.FlightID=i.FlightID AND h.FareClass=i.FareClass AND Status='ACTIVE') a
 WHERE i.Held<>COALESCE(a.Q,0)) THROW 51999,'Held invariant failed',1;
IF EXISTS(SELECT 1 FROM dbo.Inventory i OUTER APPLY
 (SELECT COUNT(*) Q FROM dbo.Ticket t JOIN dbo.SeatHold h ON h.HoldID=t.HoldID
 WHERE h.FlightID=i.FlightID AND h.FareClass=i.FareClass AND t.Status='ISSUED') a
 WHERE i.Sold<>a.Q) THROW 51999,'Sold invariant failed',1;
IF EXISTS(SELECT 1 FROM dbo.SeatHold h OUTER APPLY
 (SELECT COUNT(*) Q FROM dbo.Ticket t WHERE t.HoldID=h.HoldID) a
 WHERE h.Status='CONFIRMED' AND h.Quantity<>a.Q) THROW 51999,'Ticket invariant failed',1;
IF EXISTS(SELECT 1 FROM dbo.Payment p JOIN dbo.SeatHold h ON h.HoldID=p.HoldID
 WHERE p.Amount<>h.Quantity*h.UnitPrice OR h.Status<>'CONFIRMED') THROW 51999,'Money invariant failed',1;
EXEC dbo.usp_CreateExpiryJob; EXEC dbo.usp_CreateExpiryJob;
IF (SELECT COUNT(*) FROM msdb.dbo.sysjobs WHERE name='AirCore_ExpireHolds')<>1 THROW 51999,'Duplicate expiry job',1;
PRINT 'All four invariants and expiry-job replay: PASS';
GO
USE AirBranch_HN;
GO
DECLARE @Passengers dbo.PassengerList,@Order uniqueidentifier=NEWID(),@Request uniqueidentifier=NEWID(),@Error int=0;
INSERT @Passengers VALUES(1,N'Role test passenger',NULL);
IF DATABASE_PRINCIPAL_ID('test_branch') IS NULL CREATE USER test_branch WITHOUT LOGIN;
ALTER ROLE branch_executor ADD MEMBER test_branch;
EXECUTE AS USER='test_branch';
EXEC dbo.usp_CreateOrder @Order,@Request,'10000000-0000-0000-0000-000000000001','HN_NV01','TEST01','ECO',@Passengers;
EXEC dbo.usp_CreateOrder @Order,@Request,'10000000-0000-0000-0000-000000000001','HN_NV01','TEST01','ECO',@Passengers;
BEGIN TRY SELECT DocumentNo FROM dbo.CustomerProfile; END TRY
BEGIN CATCH SET @Error=ERROR_NUMBER(); END CATCH;
REVERT;
IF @Error<>229 THROW 51999,'Branch private-field permissions incorrect',1;
IF (SELECT COUNT(*) FROM dbo.SalesOrder WHERE OrderID=@Order)<>1 THROW 51999,'Duplicate branch order',1;
IF (SELECT COUNT(*) FROM dbo.SalesItem WHERE OrderID=@Order)<>1 THROW 51999,'Duplicate passenger',1;
UPDATE @Passengers SET PassengerName=N'Changed payload'; SET @Error=0;
BEGIN TRY EXEC dbo.usp_CreateOrder @Order,@Request,'10000000-0000-0000-0000-000000000001','HN_NV01','TEST01','ECO',@Passengers; END TRY
BEGIN CATCH SET @Error=ERROR_NUMBER(); END CATCH;
IF @Error<>51103 THROW 51999,'Changed passenger retry accepted',1;
PRINT 'Branch TVP permissions, private-field restrictions and order idempotency: PASS';
GO
