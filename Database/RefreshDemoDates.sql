/* Baked With Love - refresh the sample data dates.
   The sample orders are created relative to the day the database was built, so after a few
   days the dashboard's "last 7 days" chart goes empty. This script moves every date forward
   by the same amount so the newest order is 3 hours old again. Safe to run any time.

   Run from PowerShell (from the BakedWithLove folder):
     sqlcmd -S "(localdb)\MSSQLLocalDB" -d "<full path to App_Data\BakedWithLove.mdf>" -i Database\RefreshDemoDates.sql
   or open it in Visual Studio's SQL Server Object Explorer and execute it. */

SET NOCOUNT ON;
DECLARE @shift INT = DATEDIFF(MINUTE, DATEADD(HOUR, 3, (SELECT MAX(OrderDate) FROM Orders)), GETDATE());

IF @shift > 0
BEGIN
    DECLARE @days INT = @shift / 1440;
    UPDATE Orders              SET OrderDate = DATEADD(MINUTE, @shift, OrderDate), PreferredDate = DATEADD(DAY, @days, PreferredDate);
    UPDATE OrderStatusHistory  SET ChangedAt = DATEADD(MINUTE, @shift, ChangedAt);
    UPDATE Payments            SET PaidAt    = DATEADD(MINUTE, @shift, PaidAt) WHERE PaidAt IS NOT NULL;
    UPDATE CustomOrders        SET CreatedAt = DATEADD(MINUTE, @shift, CreatedAt), RequiredDate = DATEADD(DAY, @days, RequiredDate);
    UPDATE Reviews             SET CreatedAt = DATEADD(MINUTE, @shift, CreatedAt);
    UPDATE Feedback            SET CreatedAt = DATEADD(MINUTE, @shift, CreatedAt);
    UPDATE LoyaltyTransactions SET CreatedAt = DATEADD(MINUTE, @shift, CreatedAt);
    UPDATE Notifications       SET CreatedAt = DATEADD(MINUTE, @shift, CreatedAt);
    PRINT 'Sample dates moved forward by ' + CAST(@shift / 60 AS VARCHAR(10)) + ' hours.';
END
ELSE
    PRINT 'Sample dates are already current.';
