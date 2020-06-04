/*****************************************************************************************
    Name         : AccountNameChangesScheduleTest 
    Desc         : Test Class for AccountNameChangesSchedule class

---------------------------------------------------------------------------
 Developer              	Date            Description
---------------------------------------------------------------------------
Suresh Babu Murugan			12/07/2015		Created
******************************************************************************************/
@isTest(SeeAllData = TRUE)
public class AccountNameChangesScheduleTest {
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';

	static testmethod void test() {
        System.Test.startTest();
		String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new AccountNameChangesSchedule());
		
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
		system.Test.stopTest();
	}
}