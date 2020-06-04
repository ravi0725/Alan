/*****************************************************************************************
Name        : CreateQuoteFromOppty
Desc        : Used to Default Values from Oppty to Quote Proposal    
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           07/09/2015          Created
******************************************************************************************/
public class CreateQuoteFromOppty{
    
    public String OppID{get;set;}
    Public String AccId{get;set;}
    Public string errorMsg{get;set;}
    public boolean errorPopup{get;set;}
    Public Opportunity OppRec {get;set;}
    Public String proposalId {get;set;}
    List<Account> BillToAcc = new List<Account>();
    
    public CreateQuoteFromOppty(ApexPages.StandardController stdController){
        this.OppRec= (Opportunity)stdController.getRecord();
        OppID = this.OppRec.Id;
        OppRec = [Select Id,Owner.Name,Account.Name,Amount,Industry__c,ForecastCategoryName,Project__c,Sell_Through__c,ExpectedRevenue,Total_Hardware_Currency__c,Total_Service_Currency__c,Total_Software_Currency__c,Total_Maintenance_Currency__c,Total_Prof_Serv__c,Total_SaaS__c,Bill_To_Contact__c,Service_Start_Date__c,Service_End_Date__c,Duration__c,Duration_UOM__c,Ship_to_Address1__r.Account__c,Description,Bill_to_Address__r.Account__c,Bill_to_account__c,Bill_To_Contact__r.Name,Primary_Contact__r.Name, Name,Bill_to_Address_Disp__c,Ship_to_Address_Disp__c, CloseDate, Timeframe_to_Buy__c,Selling_Division__c,Opportunity_Product__c,Account.Number_of_Months__c, Demo_Date__c, EG_First_Meeting_Date__c, Price_List__c, Payment_Term__c, 
                  StageName,Number_of_Months__c,Partner_2__c,CreatedById, LastModifiedById, Bill_To_Address__c,Ship_To_Address1__c,Customer_Type__c,Reseller__c,Register_To__c, Product_Family__c,Product_Type__c, Primary_Contact__c, Probability, OwnerId, AccountId, Ship_To_Account__c, Ship_To_Address__c, Price_List_Name__c
                  from Opportunity where Id =: OppRec.Id];
        AccId = System.currentPageReference().getParameters().get('AcctId');
    }
    
    Public Pagereference cont(){
        Opportunity Op = [Select Id,Bill_To_Contact__c,Industry__c,Service_Start_Date__c,Partner_2__c,Service_End_Date__c,Duration__c,Duration_UOM__c,Ship_to_Address1__r.Account__c,Description,Bill_to_Address__r.Account__c,Bill_to_account__c,Bill_To_Contact__r.Name,Primary_Contact__r.Name, Name,Bill_to_Address_Disp__c,Ship_to_Address_Disp__c, CloseDate, Timeframe_to_Buy__c,Selling_Division__c,Opportunity_Product__c,Account.Number_of_Months__c, Demo_Date__c, EG_First_Meeting_Date__c, Price_List__c, Payment_Term__c, 
                          StageName,Number_of_Months__c,Bill_To_Address__c,Ship_To_Address1__c,Customer_Type__c,Reseller__c,Register_To__c, Product_Family__c,Product_Type__c, Primary_Contact__c, Probability, OwnerId, AccountId, Ship_To_Account__c, Ship_To_Address__c, Price_List_Name__c, CurrencyIsoCode 
                          from Opportunity where Id =: OppRec.Id];
        proposalId =  expressQuote.createQuoteOrProposal(Op,AccId);
        system.debug('>>>>>>>ProposalID>>>>'+proposalId);
        return new PageReference(Label.Internal_UAT_url+'/'+proposalId+'/e?cancelURL=%2Fapex%2Fapttus_proposal__cancelactioninterceptor%3FactionName%3Dcreate_oppty_proposal%26objectId%3D'+OppRec.Id+'%26opportunityId%3D'+OppRec.Id+'%26proposalId%3D'+proposalId+'%26rollbackId%3D'+proposalId+'&retURL=%2F'+proposalId);  
        
    }
    
    public void test(){
        List<Opportunity> op = [select Id, Name from Opportunity limit 40000];
    }
}