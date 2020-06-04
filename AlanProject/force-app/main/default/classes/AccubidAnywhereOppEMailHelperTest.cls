@isTest 
private class AccubidAnywhereOppEMailHelperTest {
    static testMethod void testGetMetadata() {
        
        //1. ACCUBID PROD. START-----------------------------------------------------------------------------------------
        Product2 prod = new  Product2(
            Name = 'Prod 1',
            ProductCode = 'SUB-ANY-EST-PRO-D',
            CurrencyIsoCode = 'USD'
        );
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();    
            
        PricebookEntry pbe = new  PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 0.0,
            CurrencyIsoCode = 'USD',
            isActive = TRUE
        );
        insert pbe;
        
        Opportunity opp = new Opportunity(
            Accubid_Email_Alert__c = false,
            MEPNA_Submit_for_Order_Audit__c = true,
            Name = 'TestOpp',
            CloseDate = date.parse('12/27/2019'),
            Pricebook2Id = pricebookId,
            StageName = '4 - Proposal/Price Quote'
        );
        insert opp;
        
        
        OpportunityLineItem line = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = prod.Id,
            Quantity = 1,
            //CurrencyIsoCode = 'USD',
            UnitPrice = 1800,
            PricebookEntryId = pbe.Id
            
        );
        insert line;
        
        OpportunityAccubidAnywhere_EmailSetting__mdt mdt1 = new OpportunityAccubidAnywhere_EmailSetting__mdt (); 
        mdt1.ProductCodes__c = 'SUB-ANY-EST-PRO-D';
        system.debug('mdt1---->'+mdt1);
        
        AccubidAnywhereOppEMailHelper.AccuOppEmail(new List<Opportunity>{opp});
        //1. ACCUBID PROD. END-------------------------------------------------------------------------------------------
        
        //2. TRAINING PROD. START-----------------------------------------------------------------------------------------
        Product2 prod2 = new  Product2(
            Name = 'Prod 2',
            ProductCode = 'TRN-OTH-CUST-EL',
            CurrencyIsoCode = 'USD'
        );
        insert prod2;
        
        Id pricebookId2 = Test.getStandardPricebookId();    
            
        PricebookEntry pbe2 = new  PricebookEntry(
            Pricebook2Id = pricebookId2,
            Product2Id = prod2.Id,
            UnitPrice = 0.0,
            CurrencyIsoCode = 'USD',
            isActive = TRUE
        );
        insert pbe2;
        
        Opportunity opp2 = new Opportunity(
            Autobid_Email_Alert__c = false,
            Name = 'TestOpp2',
            CloseDate = date.parse('12/27/2019'),
            Pricebook2Id = pricebookId2,
            StageName = '6 - Closed Won'
        );
        insert opp2;
        
        
        OpportunityLineItem line2 = new OpportunityLineItem(
            OpportunityId = opp2.Id,
            Product2Id = prod2.Id,
            Quantity = 1,
            //CurrencyIsoCode = 'USD',
            UnitPrice = 1800,
            PricebookEntryId = pbe2.Id
            
        );
        insert line2;
        
        AccubidAnywhereOppEMailHelper.TRNOppEmail(new List<Opportunity>{opp2});
        //2. TRAINING PROD. END------------------------------------------------------------------------------------------
        
        //3. AUTOBID PROD. START-----------------------------------------------------------------------------------------
        Product2 prod3 = new  Product2(
            Name = 'Prod 3',
            ProductCode = 'SOF-ABCOM-OSV-EDU-M',
            CurrencyIsoCode = 'USD'
        );
        insert prod3;
        
        Id pricebookId3 = Test.getStandardPricebookId();    
            
        PricebookEntry pbe3 = new  PricebookEntry(
            Pricebook2Id = pricebookId3,
            Product2Id = prod3.Id,
            UnitPrice = 0.0,
            CurrencyIsoCode = 'USD',
            isActive = TRUE
        );
        insert pbe3;
        
        Opportunity opp3 = new Opportunity(
            Autobid_Email_Alert__c = false,
            Name = 'TestOpp3',
            CloseDate = date.parse('12/27/2019'),
            Pricebook2Id = pricebookId3,
            StageName = '6 - Closed Won'
        );
        insert opp3;
        
        
        OpportunityLineItem line3 = new OpportunityLineItem(
            OpportunityId = opp3.Id,
            Product2Id = prod3.Id,
            Quantity = 1,
            //CurrencyIsoCode = 'USD',
            UnitPrice = 1800,
            PricebookEntryId = pbe3.Id
            
        );
        insert line3;
        
        OpportunityAccubidAnywhere_EmailSetting__mdt mdt3 = new OpportunityAccubidAnywhere_EmailSetting__mdt (); 
        mdt3.ProductCodes__c = 'SOF-ABCOM-OSV-EDU-M';
        
        AccubidAnywhereOppEMailHelper.AutoBidEmail(new List<Opportunity>{opp3});
        //3. AUTOBID PROD. END-----------------------------------------------------------------------------------------
    	
        
        //4. T-EST PROD. START-----------------------------------------------------------------------------------------
        Product2 prod4 = new  Product2(
            Name = 'Prod 4',
            ProductCode = 'T-EST-TRN-WB-2H',
            CurrencyIsoCode = 'USD'
        );
        insert prod4;
        
        Id pricebookId4 = Test.getStandardPricebookId();    
            
        PricebookEntry pbe4 = new  PricebookEntry(
            Pricebook2Id = pricebookId4,
            Product2Id = prod4.Id,
            UnitPrice = 0.0,
            CurrencyIsoCode = 'USD',
            isActive = TRUE
        );
        insert pbe4;
        
        Opportunity opp4 = new Opportunity(
            Autobid_Email_Alert__c = false,
            Name = 'TestOpp4',
            CloseDate = date.parse('12/27/2019'),
            Pricebook2Id = pricebookId4,
            StageName = '6 - Closed Won'
        );
        insert opp4;
        
        
        OpportunityLineItem line4 = new OpportunityLineItem(
            OpportunityId = opp4.Id,
            Product2Id = prod4.Id,
            Quantity = 1,
            //CurrencyIsoCode = 'USD',
            UnitPrice = 1800,
            PricebookEntryId = pbe4.Id
            
        );
        insert line4;
        
        OpportunityAccubidAnywhere_EmailSetting__mdt mdt4 = new OpportunityAccubidAnywhere_EmailSetting__mdt (); 
        mdt4.ProductCodes__c = 'T-EST-TRN-WB-2H';
        
        AccubidAnywhereOppEMailHelper.EstOppProdEmail(new List<Opportunity>{opp4});
    	//4. T-EST PROD. END-----------------------------------------------------------------------------------------
    
    }
}