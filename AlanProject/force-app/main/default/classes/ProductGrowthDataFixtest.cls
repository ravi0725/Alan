@istest(seealldata=true)
public class ProductGrowthDataFixtest{
 public static testmethod void meth1(){
       
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();   
        
         Batch_Data_Fix_Object__c batchObj = new Batch_Data_Fix_Object__c(Record_ID__c = GenerateTestData.opp.id);
        insert batchObj;
        
        ProductGrowthDataFix bdf = new ProductGrowthDataFix();
        
        ID batchID = database.executebatch(bdf);
        }
     }