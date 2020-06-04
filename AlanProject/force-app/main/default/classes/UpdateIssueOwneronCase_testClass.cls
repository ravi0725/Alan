@isTest
public class UpdateIssueOwneronCase_testClass {
    
    Static Testmethod void CaseProdLeadUpdatetest(){
        
        Profile p = [select id from profile where name='Standard User'];
        
        User us= new User();
        
        us.UserName = 'test' + 'testName' + '@ourcompany.example.com';
        us.Firstname='FirstName';
        us.Lastname='Testing'; 
        us.Email='test' + 'testName' + '@ourcompany.example.com'; 
        us.CommunityNickName='CommunityNickName';
        us.Alias='alias';
        us.Phone='12345';
        us.localesidkey='en_US';
        us.TimeZoneSidKey='America/Chicago';
        us.emailencodingkey='UTF-8';
        us.languagelocalekey='en_US';
        us.localesidkey='en_US';
        us.ProfileId= p.Id;
        
        
        insert us;
        
        Case Cas = new Case();
        cas.Defect__c=cas.Id;
        cas.OwnerId=us.Id;
        cas.Product_Lead__c=cas.OwnerId;
        cas.Priority1_Follow_up__c = TRUE;
        insert cas;
        
        Case cs= new case();
        cs.Defect__c=cas.Id;
        cs.Priority1_Follow_up__c = TRUE;
        insert cs;
        
        Test.startTest();
        
        cas.Product_Lead__c=cas.OwnerId;
        cas.Priority1_Follow_up__c = TRUE;
        update cas;
        
        Test.stopTest();
        
    }
}