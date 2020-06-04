/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Controller class for QuickQuoteFromAccountPage
 * History     :  

 * [29.09.2014] Ankur Patel  Created
 */
 /*
 Swati: 7/22/2015: commmented the reference to GCCM record ID
 */
public Class QuickQuoteFromAccountController{
    Account acc;
    public boolean errorFlag{get;set;}
    public Quote qt{get;set;}
    public QuickQuoteFromAccountController(ApexPages.StandardController stdController) {
        if(!test.isrunningtest()){
        stdController.addFields('Id,Name,Type,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet'.split(','));
        }
        acc = (Account)stdController.getRecord();
        errorFlag = false;
    }
    
    public void createQuickQuote(){
        try{
            Opportunity opp = new Opportunity();
            opp.Name = acc.Name;
            opp.AccountId = acc.Id;
            opp.StageName = '2 - Needs Analysis';
            opp.CloseDate = date.today();
            opp.CurrencyISOCode = 'USD';
            opp.Type = 'Existing Business';
            opp.Selling_Division__c = 'GCCM';
            //opp.RecordTypeId = '012i0000000OrAx';
            opp.PriceBook2Id = [select Id from PriceBook2 where Name = 'GCCM Price Book'].Id;
            //opp.Product_Type__c
            insert Opp;
            
            qt = new Quote();
            qt.OpportunityId = opp.Id;
            qt.Name = acc.Name;
            qt.BillingCity = acc.BillingCity;
            qt.BillingCountry = acc.BillingCountry;
            qt.BillingName = acc.Name;
            qt.BillingPostalCode = acc.BillingPostalCode;
            qt.BillingState = acc.BillingState;
            qt.BillingStreet = acc.BillingStreet;
            qt.ShippingName = acc.Name;
            qt.ShippingCity = acc.BillingCity;
            qt.ShippingCountry = acc.BillingCountry;
            qt.ShippingPostalCode = acc.BillingPostalCode;
            qt.ShippingState = acc.BillingState;
            qt.ShippingStreet = acc.BillingStreet;
            qt.PriceBook2Id = opp.PriceBook2Id;
          /*  qt.Notes__c = '5. Payment Terms for Agreement Total in the amount of $00.00:<br/>';
            qt.Notes__c = qt.Notes__c + '   - Licensee will be invoiced $.00 upon Agreement execution, due net 30 days.<br/>';
            qt.Notes__c = qt.Notes__c + '   - Licensee will be invoiced $.00 on X/XX/XX, due net 30 days.<br/>';
            qt.Notes__c = qt.Notes__c + '   - Licensee will be invoiced $.00 on X/XX/XX, due net 30 days.<br/>';
            qt.Notes__c = qt.Notes__c + '6. A Term Discount of XX% has been applied to Term 2 Software Support and Maintenance, and Term Discount of XX% has been applied to Term 3 Software Support and Maintenance.';
            */
            insert qt;
        }catch(Exception ex){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.error,'Error while creating Quote. Please contact to your Administrator.');
            apexpages.addmessage(msg);
            errorFlag = true;
        }
    }
}