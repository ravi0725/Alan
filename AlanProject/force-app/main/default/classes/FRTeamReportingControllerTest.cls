/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Test class for LineItemReorder class
 * History     :  

 * [11.06.2014] Ankur Patel  Created
 */
@isTest(seeAllData=true)
public class FRTeamReportingControllerTest{
    public static testmethod void TestFRTeamReportingController1(){
        Test.startTest();
            //GenerateTestData.customSettingRds();
            GenerateTestData.createAccount();
        	GenerateTestData.createContact();
        	GenerateTestData.createParentCase();
        	GenerateTestData.createdefectCase();
            GenerateTestData.createCase();
            FRTeamReportingController temp = new FRTeamReportingController();
            temp.getDailyReport();
            temp.getWeekRange();
            temp.getMonthRange();
            temp.searchAcc();
        Test.stopTest();
    } 
    public static testmethod void TestFRTeamReportingController2(){
        Test.startTest();
            //GenerateTestData.customSettingRds();
            GenerateTestData.createAccount();
       		GenerateTestData.createContact();
        	GenerateTestData.createParentCase();
        	GenerateTestData.createdefectCase();
            GenerateTestData.createCase();
            FRTeamReportingController temp = new FRTeamReportingController();
            temp.cs.Due_Date__c = date.today();
        	temp.getDailyReport();
            temp.getWeekRange();
            temp.getMonthRange();
            temp.searchAcc();
        Test.stopTest();
    } 
}