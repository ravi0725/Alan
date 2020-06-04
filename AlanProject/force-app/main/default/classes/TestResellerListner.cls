/*****************************************************************************************
Name    : TestResellerListner
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           12/01/2018          Created
******************************************************************************************/
@isTest(seealldata=true)
public class TestResellerListner{
  static testmethod void TestResellerListner1(){
       
         GenerateTestData.createAccount();
         Reseller__c res = new Reseller__c();
         res.Parent_Account__c = GenerateTestData.acct.Id;
         insert res;
         
         Reseller__c res1 = new Reseller__c(id=res.id);
         delete res1;
        }
    }