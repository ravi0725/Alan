/*
*****************************************************************************************
Name        : TestImportData 

---------------------------------------------------------------------------
Developer              Date            Description
Ankur Patel           2/1/2016          Created
*****************************************************************************************
*/

@isTest(seeAllData=true)
public class TestSelfRegistrationController{
    static testmethod void TestSelfRegistrationController1(){
        SelfRegistrationController temp = new SelfRegistrationController();
        temp.login();
        temp.password = 'trimble123';
        temp.SerialNumber = [select Id,serialnumber from asset where serialnumber != null and serialnumber != '' limit 1].serialnumber;
        temp.FirstName = 'test';
        temp.LastName = 'test';
        temp.FirstName = 'test';
        temp.submitForm();
    }
    
    static testmethod void TestSelfRegistrationController2(){
        SelfRegistrationController temp = new SelfRegistrationController();
        temp.login();
        temp.password = 'trimble123';
        temp.SerialNumber = 'trimbleTestAsset';
        temp.submitForm();
        
        temp.password = 'trim@123';
        temp.SerialNumber = 'trimbleTestAsset';
        temp.submitForm();
    }
    
    
}