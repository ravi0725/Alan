/*
* ****************************************************************************************
Name        : OpportunityHelperTest
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
P M Mamata          25/08/2015          Created
*
*****************************************************************************************/
@istest(seealldata=true)
private class OpportunityHelperTest {
    static testmethod void meth1(){
        User u = [SELECT Id, Profile.Name  FROM User where Profile.Name like 'Sales Ops - MEP - Europe' AND isactive = true LIMIT 1];
        Id pricebookId = Test.getStandardPricebookId();
        Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
        Account acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,CurrencyIsoCode = 'USD',Payment_Term__c = 'CASH IN ADVANCE',Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                                   BillingCountry = 'United States',EBS_Payment_Term__c='30 NET',Restricted_Entity__c = Label.Not_Restricted,Annual_Support_Date__c = date.today(), BillingCity = 'Pune',BillingState = 'California', BillingPostalCode = 'postal code',BillingStreet = 'A-202',Collector_Email__c = 'test@gmail.com');
        insert acct;
        
        contact ct1 = new contact();
        ct1.LastName = 'Test last name1';
        ct1.AccountId = acct.Id;
        ct1.Preferred_Language__c = 'American English';
        ct1.Email = 'tes1t@gmail.com';
        ct1.MailingStreet='test1';
        ct1.Mailingcity='testcity';
        ct1.MailingState='California';
        ct1.MailingPostalCode ='12345';
        ct1.MailingCountry = 'United States';
        insert ct1;
        
        contact ct = new contact();
        ct.LastName = 'Test last name';
        ct.AccountId = acct.Id;
        ct.Preferred_Language__c = 'American English';
        ct.Email = 'test@gmail.com';
        ct.MailingStreet='test1';
        ct.Mailingcity='testcity';
        ct.MailingState='California';
        ct.MailingPostalCode ='12345';
        ct.MailingCountry = 'United States';
        insert ct;
        Address__c adrs1;
        adrs1 = new Address__c(Name = 'Test Address',validation_Status__c='Corrected',FCH_Party_Site_Id__c = '222222',Account__c = acct.Id, Country__c = 'United States',Bill_To__c = true,Ship_To__c=true,Address_Line1__c = 'addrs4',Address_Line2__c = 'addrs4',Address_Line3__c = 'addrs4',Address_Line4__c = 'addrs4',City__c = 'city',State__c = 'California',Zip__c = 'zip');
        insert adrs1;
        
        Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c();                
        
        pricelist.Apttus_Config2__Active__c = true;
        pricelist.Name = 'MEP NA USD';
        pricelist.Legal_Entity__c = 'Legal';
        pricelist.Business_Area__c = 'MANHATTAN SOFTWARE';
        insert pricelist;
        system.runAs(u){
            
            
            List<Opportunity> opList = new List<Opportunity>();   
            Map<Id,Opportunity> opMap = new Map<Id,Opportunity>();     
            Opportunity opp1 = new Opportunity();
            opp1.AccountId = acct.Id;
            opp1.StageName = 'Inquery';
            opp1.Closedate = date.today() + 7;
            opp1.Name = 'Opp1';
            opp1.Ship_To_Account__c = acct.ID;
            opp1.Payment_Term__c = 'CASH IN ADVANCE';
            opp1.OwnerId = UserInfo.getUserId();
            opp1.Bill_To_Account__c = acct.Id;
            opp1.Ship_To_Account__c = acct.id;
            opp1.Bill_To_Contact__c = ct.Id;
            opp1.Primary_Contact__c =ct1.id;
            opp1.Bill_to_Address__c = adrs1.id;
            opp1.Ship_to_Address1__c = adrs1.id;
            //opp1.Payment_Term_Approval_Status__c = 'Approved';        
            insert opp1;
            opList.add(opp1);    
            opp1.Payment_Term__c = 'N10'; 
            opp1.Trigger_Approval__c = true;    
            opp1.CloseDate = date.today() +15;
            //update opp1;        
            opMap.put(opp1.Id,opp1);
            
            Opportunity opp = new Opportunity();
            opp.AccountId = acct.Id;
            opp.StageName = 'Inquiry';
            opp.Closedate = date.today() + 7;
            opp.Name = 'Opp1';
            opp.Bill_To_Account__c = acct.Id;
            opp.Ship_To_Account__c = acct.id;
            opp.Bill_To_Contact__c = ct.Id;
            opp.Primary_Contact__c =ct.id;
            opp.Bill_to_Address__c = adrs1.id;
            opp.Ship_to_Address1__c = adrs1.id;
            opp.Payment_Term__c = 'CASH IN ADVANCE';
            opp.OwnerId = UserInfo.getUserId();
            opp.Selling_Division__c = 'MEP NA';
            //opp.Payment_Term_Approval_Status__c = 'Approved';    
            //opp.Pricebook2Id = pricebookId;
            insert opp;
            opMap.put(opp.Id,opp);    
            opList.add(opp);                           
            Product2 prd = new Product2();
            prd.Name = 'test';
            prd.isActive = true;        
            prd.ProductCode = 'Test123';  
            prd.Product_Category_Type__c = 'Software';    
            insert prd;        
            
            Opportunity o = [SELECT Pricebook2Id FROM Opportunity WHERE Id =: opp.Id];    
            //pricebook2 standardpb = [select id from pricebook2 where isstandard = true];
            
            PriceBookEntry pbe = new PriceBookEntry();        
            pbe.PriceBook2ID = pricebookId;
            pbe.Product2Id = prd.Id;
            pbe.UnitPrice = 1;  
            pbe.IsActive = True;          
            insert pbe;                
            
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opp.Id;        
            oli.Quantity = 45;
            oli.UnitPrice = 456;
            oli.PricebookEntryId = pbe.Id;
            
            //oli.Product2Id = ;
            insert oli;
            
            Address__c adrs = new Address__c(Name = 'Test Address',Validation_Status__c='Corrected',Account__c = acct.Id, Country__c = 'UNITED STATES',Bill_To__c = true,Ship_To__c=true,Address_Line1__c = 'addrs4',Address_Line2__c = 'addrs4',Address_Line3__c = 'addrs4',Address_Line4__c = 'addrs4',City__c = 'city',State__c = 'state',Zip__c = 'zip');
            insert adrs;
            
            Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
            proposal.Apttus_Proposal__Account__c = acct.Id;
            proposal.Apttus_Proposal__Opportunity__c =opp1.Id;
            proposal.Apttus_QPConfig__PriceListId__c = pricelist.Id;
            proposal.Ship_To_Account__c = acct.Id;
            proposal.Bill_to_Address__c  = adrs.Id;
            proposal.Ship_to_Address1__c = adrs.Id;
            proposal.Apttus_QPConfig__BillToAccountId__c =acct.Id;
            proposal.OwnerId = UserInfo.getUserId();
            proposal.Apttus_Proposal__Primary__c = true;
            proposal.Can_Validate__c = false;
            //insert proposal;            
            
            OpportunityHelper.launchControl.put('OpportunityBeforeDeleteHandler',0);
            OpportunityHelper.OpportunityBeforeDeleteHandler(opList);   
            opportunityHelper.updateStartdateEnddate(opList);
            Opportunity delOpp = new Opportunity(id=Opp.id);
            delete delOpp;    
            
        }
        
        
    }
    
    static testmethod void meth2(){
        //User u = [SELECT Id FROM User where Profile.Name like '%MEP%' AND isactive = true LIMIT 1];
        Id pricebookId = [select id from Pricebook2 where name ='MEP NA'].id;
        Id Stdpricebookid = Test.getStandardPricebookId();
        Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
        Account acct = new Account(Name = 'Test Assign Case Account',Account_Division__c='MEP;MEP NA;',RecordTypeId = acctRecTypeId,CurrencyIsoCode = 'USD',Payment_Term__c = 'CASH IN ADVANCE',Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                                   BillingCountry = 'United States',Restricted_Entity__c = Label.Not_Restricted,Annual_Support_Date__c = date.today(), BillingCity = 'Pune',BillingState = 'California', BillingPostalCode = 'postal code',BillingStreet = 'A-202',Collector_Email__c = 'test@gmail.com');
        insert acct;
        
        Address__c adrs1;
        adrs1 = new Address__c(Name = 'Test Address',validation_Status__c='Corrected',FCH_Party_Site_Id__c = '222222',Account__c = acct.Id, Country__c = 'United States',Bill_To__c = true,Ship_To__c=true,Address_Line1__c = 'addrs4',Address_Line2__c = 'addrs4',Address_Line3__c = 'addrs4',Address_Line4__c = 'addrs4',City__c = 'city',State__c = 'California',Zip__c = 'zip');
        insert adrs1;
        
        Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c();                
        
        pricelist.Apttus_Config2__Active__c = true;
        pricelist.Name = 'CH Test';
        pricelist.Legal_Entity__c = 'TIBV SWISS BRANCH';
        pricelist.Business_Area__c = 'MANHATTAN SOFTWARE';
        pricelist.Division__c='MEP NA';
        insert pricelist;
        
        contact ct = new contact();
        ct.LastName = 'Test last name';
        ct.AccountId = acct.Id;
        ct.Preferred_Language__c = 'American English';
        ct.Email = 'test@gmail.com';
        ct.MailingStreet='test1';
        ct.Mailingcity='testcity';
        ct.MailingState='California';
        ct.MailingPostalCode ='12345';
        ct.MailingCountry = 'United States';
        insert ct;
        
        List<Opportunity> opList = new List<Opportunity>();   
        Map<Id,Opportunity> opMap = new Map<Id,Opportunity>();     
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acct.Id;
        opp1.Bill_To_Account__c = acct.Id;
        opp1.Ship_To_Account__c = acct.id;
        opp1.Bill_To_Contact__c = ct.Id;
        opp1.Primary_Contact__c =ct.id;
        opp1.Bill_to_Address__c = adrs1.id;
        opp1.Ship_to_Address1__c = adrs1.id;
        opp1.Account_Sub_Type__c = 'Renewal';
        opp1.Renewal_Status__c = 'New';
        opp1.StageName = '1 - Qualification';
        opp1.Closedate = date.today() + 7;
        opp1.Name = 'Opp1';
        opp1.Ship_To_Account__c = acct.ID;
        opp1.Payment_Term__c = 'CASH IN ADVANCE';
        opp1.OwnerId = UserInfo.getUserId();
        opp1.Selling_Division__c = 'MEP NA';
        opp1.Price_List__c = pricelist.id;      
        insert opp1;
        
        OpportunityHelper.validateRenewalOpportunity(new List<Opportunity>{opp1});
        
        opList.add(opp1);                    
        opMap.put(opp1.Id,opp1);
        
        Product2 prd = new Product2();
        prd.Name = 'test';
        prd.isActive = true;        
        prd.ProductCode = 'Test123';  
        prd.Product_Category_Type__c = 'Software';    
        insert prd;
        
        Product2 prd1 = new Product2();
        prd1.Name = 'test';
        prd1.isActive = true;        
        prd1.ProductCode = 'Test123';  
        prd1.Product_Category_Type__c = 'Service';    
        insert prd1;        
        
        Product2 prd2 = new Product2();
        prd2.Name = 'test';
        prd2.isActive = true;        
        prd2.ProductCode = 'Test123';  
        prd2.Product_Category_Type__c = 'Maintenance';    
        insert prd2;  
        
        
        Product2 prd3 = new Product2();
        prd3.Name = 'test';
        prd3.isActive = true;        
        prd3.ProductCode = 'Test123';  
        prd3.Product_Category_Type__c = 'SaaS';    
        insert prd3; 
        
        Product2 prd4 = new Product2();
        prd4.Name = 'test';
        prd4.isActive = true;        
        prd4.ProductCode = 'Test123';  
        prd4.Product_Category_Type__c = 'Prof. Services';    
        insert prd4; 
        
        Product2 prd5 = new Product2();
        prd5.Name = 'test';
        prd5.isActive = true;        
        prd5.ProductCode = 'Test123';  
        prd5.Product_Category_Type__c = 'Hardware';    
        insert prd5; 
        
        Product2 prd6 = new Product2();
        prd6.Name = 'test';
        prd6.isActive = true;        
        prd6.ProductCode = 'Test123';  
        prd6.Product_Category_Type__c = 'Others'; 
        prd6.ICC_Type__c ='Other';   
        insert prd6; 
        
        Product2 prd7 = new Product2();
        prd7.Name = 'test';
        prd7.isActive = true;        
        prd7.ProductCode = 'Test123';  
        prd7.Product_Category_Type__c = 'Subscription';  
        prd7.ICC_Type__c = 'Training - Hardware';  
        insert prd7;  
        
        Product2 prd8 = new Product2();
        prd8.Name = 'test';
        prd8.isActive = true;        
        prd8.ProductCode = 'Test123';  
        prd8.Product_Category_Type__c = 'Rental';    
        insert prd8;
        
        Product2 prd9 = new Product2();
        prd9.Name = 'test9';
        prd9.isActive = true;        
        prd9.ProductCode = 'Test123';  
        prd9.Product_Category_Type__c = 'Rental'; 
        prd9.Business_Area__c = 'MEP ESTIMATING';
        insert prd9;
        
        Product2 prd10 = new Product2();
        prd10.Name = 'prd10';
        prd10.isActive = true;        
        prd10.ProductCode = 'BUND-ACE-TM-D';  
        prd10.Product_Category_Type__c = 'Software'; 
        //prd10.Business_Area__c = 'MEP ESTIMATING';
        prd10.Business_Area__c = 'ACCUBID';
        prd10.Product_Line__c = 'ACC-TM BILLING SOFTWARE';
        insert prd10;
        
        PriceBookEntry Stdpbe = new PriceBookEntry();        
        Stdpbe.PriceBook2ID = StdpricebookId;
        Stdpbe.Product2Id = prd.Id;
        Stdpbe.UnitPrice = 1;    
        Stdpbe.IsActive = True;        
        insert Stdpbe;                
        
        
        PriceBookEntry Stdpbe1 = new PriceBookEntry();        
        Stdpbe1.PriceBook2ID = StdpricebookId;
        Stdpbe1.Product2Id = prd1.Id;
        Stdpbe1.UnitPrice = 1;    
        Stdpbe1.IsActive = True;        
        insert Stdpbe1; 
        
        PriceBookEntry Stdpbe2 = new PriceBookEntry();        
        Stdpbe2.PriceBook2ID = StdpricebookId;
        Stdpbe2.Product2Id = prd2.Id;
        Stdpbe2.UnitPrice = 1;    
        Stdpbe2.IsActive = True;        
        insert Stdpbe2; 
        
        PriceBookEntry Stdpbe3 = new PriceBookEntry();        
        Stdpbe3.PriceBook2ID = StdpricebookId;
        Stdpbe3.Product2Id = prd3.Id;
        Stdpbe3.UnitPrice = 1;    
        Stdpbe3.IsActive = True;        
        insert Stdpbe3; 
        
        PriceBookEntry Stdpbe4 = new PriceBookEntry();        
        Stdpbe4.PriceBook2ID = StdpricebookId;
        Stdpbe4.Product2Id = prd4.Id;
        Stdpbe4.UnitPrice = 1;    
        Stdpbe4.IsActive = True;        
        insert Stdpbe4; 
        
        PriceBookEntry Stdpbe5 = new PriceBookEntry();        
        Stdpbe5.PriceBook2ID = StdpricebookId;
        Stdpbe5.Product2Id = prd5.Id;
        Stdpbe5.UnitPrice = 1;    
        Stdpbe5.IsActive = True;        
        insert Stdpbe5; 
        
        PriceBookEntry Stdpbe6 = new PriceBookEntry();        
        Stdpbe6.PriceBook2ID = StdpricebookId;
        Stdpbe6.Product2Id = prd6.Id;
        Stdpbe6.UnitPrice = 1;    
        Stdpbe6.IsActive = True;        
        insert Stdpbe6; 
        
        PriceBookEntry Stdpbe7 = new PriceBookEntry();        
        Stdpbe7.PriceBook2ID = StdpricebookId;
        Stdpbe7.Product2Id = prd7.Id;
        Stdpbe7.UnitPrice = 1;    
        Stdpbe7.IsActive = True;        
        insert Stdpbe7; 
        
        PriceBookEntry Stdpbe8 = new PriceBookEntry();        
        Stdpbe8.PriceBook2ID = StdpricebookId;
        Stdpbe8.Product2Id = prd8.Id;
        Stdpbe8.UnitPrice = 1;    
        Stdpbe8.IsActive = True;        
        insert Stdpbe8; 
        
        
        PriceBookEntry Stdpbe9 = new PriceBookEntry();        
        Stdpbe9.PriceBook2ID = StdpricebookId;
        Stdpbe9.Product2Id = prd9.Id;
        Stdpbe9.UnitPrice = 1;    
        Stdpbe9.IsActive = True;        
        insert Stdpbe9;
        
        PriceBookEntry pbe = new PriceBookEntry();        
        pbe.PriceBook2ID = pricebookId;
        pbe.Product2Id = prd.Id;
        pbe.UnitPrice = 1;    
        pbe.IsActive = True;        
        insert pbe;                
        
        
        PriceBookEntry pbe1 = new PriceBookEntry();        
        pbe1.PriceBook2ID = pricebookId;
        pbe1.Product2Id = prd1.Id;
        pbe1.UnitPrice = 1;    
        pbe1.IsActive = True;        
        insert pbe1; 
        
        PriceBookEntry pbe2 = new PriceBookEntry();        
        pbe2.PriceBook2ID = pricebookId;
        pbe2.Product2Id = prd2.Id;
        pbe2.UnitPrice = 1;    
        pbe2.IsActive = True;        
        insert pbe2; 
        
        PriceBookEntry pbe3 = new PriceBookEntry();        
        pbe3.PriceBook2ID = pricebookId;
        pbe3.Product2Id = prd3.Id;
        pbe3.UnitPrice = 1;    
        pbe3.IsActive = True;        
        insert pbe3; 
        
        PriceBookEntry pbe4 = new PriceBookEntry();        
        pbe4.PriceBook2ID = pricebookId;
        pbe4.Product2Id = prd4.Id;
        pbe4.UnitPrice = 1;    
        pbe4.IsActive = True;        
        insert pbe4; 
        
        PriceBookEntry pbe5 = new PriceBookEntry();        
        pbe5.PriceBook2ID = pricebookId;
        pbe5.Product2Id = prd5.Id;
        pbe5.UnitPrice = 1;    
        pbe5.IsActive = True;        
        insert pbe5; 
        
        PriceBookEntry pbe6 = new PriceBookEntry();        
        pbe6.PriceBook2ID = pricebookId;
        pbe6.Product2Id = prd6.Id;
        pbe6.UnitPrice = 1;    
        pbe6.IsActive = True;        
        insert pbe6; 
        
        PriceBookEntry pbe7 = new PriceBookEntry();        
        pbe7.PriceBook2ID = pricebookId;
        pbe7.Product2Id = prd7.Id;
        pbe7.UnitPrice = 1;    
        pbe7.IsActive = True;        
        insert pbe7; 
        
        PriceBookEntry pbe8 = new PriceBookEntry();        
        pbe8.PriceBook2ID = pricebookId;
        pbe8.Product2Id = prd8.Id;
        pbe8.UnitPrice = 1;    
        pbe8.IsActive = True;        
        insert pbe8; 
        
        PriceBookEntry pbe9 = new PriceBookEntry();        
        pbe9.PriceBook2ID = pricebookId;
        pbe9.Product2Id = prd9.Id;
        pbe9.UnitPrice = 1;    
        pbe9.IsActive = True;        
        insert pbe9; 
        
        List<OpportunityLineItem> Olilist = new List<OpportunityLineItem>();        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp1.Id;        
        oli.Quantity = 45;
        oli.Totalprice = 456;
        oli.PricebookEntryId = pbe.Id;
        Olilist.add(oli);
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp1.Id;        
        oli2.Quantity = 45;
        oli2.Totalprice = 456;
        oli2.PricebookEntryId = pbe1.Id;
        Olilist.add(oli2);
        
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp1.Id;        
        oli3.Quantity = 45;
        oli3.UnitPrice = 456;
        oli3.PricebookEntryId = pbe2.Id;
        Olilist.add(oli3);
        
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = opp1.Id;        
        oli4.Quantity = 45;
        oli4.UnitPrice = 456;
        oli4.PricebookEntryId = pbe3.Id;
        Olilist.add(oli4);
        
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = opp1.Id;        
        oli5.Quantity = 45;
        oli5.UnitPrice = 456;
        oli5.PricebookEntryId = pbe4.Id;
        Olilist.add(oli5);
        
        OpportunityLineItem oli6 = new OpportunityLineItem();
        oli6.OpportunityId = opp1.Id;        
        oli6.Quantity = 45;
        oli6.UnitPrice = 456;
        oli6.PricebookEntryId = pbe5.Id;
        Olilist.add(oli6);
        
        OpportunityLineItem oli7 = new OpportunityLineItem();
        oli7.OpportunityId = opp1.Id;        
        oli7.Quantity = 45;
        oli7.UnitPrice = 456;
        oli7.PricebookEntryId = pbe6.Id;
        Olilist.add(oli7);     
        
        OpportunityLineItem oli8 = new OpportunityLineItem();
        oli8.OpportunityId = opp1.Id;        
        oli8.Quantity = 45;
        oli8.UnitPrice = 456;
        oli8.PricebookEntryId = pbe7.Id;
        Olilist.add(oli8);
        
        
        OpportunityLineItem oli9 = new OpportunityLineItem();
        oli9.OpportunityId = opp1.Id;        
        oli9.Quantity = 45;
        oli9.UnitPrice = 456;
        oli9.PricebookEntryId = pbe8.Id;
        Olilist.add(oli9);
        
        OpportunityLineItem oli10 = new OpportunityLineItem();
        oli10.OpportunityId = opp1.Id;        
        oli10.Quantity = 45;
        oli10.UnitPrice = 456; 
        oli10.PricebookEntryId = pbe9.Id;
        oli10.Product2Id = prd9.Id;
        Olilist.add(oli10); 
        insert Olilist;
        //
        delete Olilist;
        Asset ast1 = new Asset();
        ast1.accountId = acct.Id;
        ast1.Name = 'ast1';
        ast1.Product2Id = prd10.Id;
        ast1.Status = 'Active';
        insert ast1;
        entitlement ent1 = new entitlement();
        ent1.accountId= acct.Id;
        ent1.Name = 'testent1';
        ent1.AssetId = ast1.Id;
        ent1.Contract_Start_Date__c = date.today() - 150;
        ent1.Contract_Start_Date__c = date.today() + 150;
        ent1.Entitlement_Product__c = prd10.Id;
        insert ent1;
        //
        
        
        Opportunity updateOpp1 = new Opportunity(id=Opp1.id);
        updateOpp1.StageName = '6 - Closed Won';
        //updateOpp1.Selling_Division__c = 'MEP';
        
        OpportunityHelper.launchControl.put('validateMEPNAEstimatingBusinessArea',0);
        update updateOpp1;
        
        /*
        OpportunityLineItem oli11 = new OpportunityLineItem();
        oli11.OpportunityId = updateOpp1.Id;        
        oli11.Quantity = 45;
        oli11.UnitPrice = 456; 
        oli11.PricebookEntryId = pbe9.Id;
        oli11.Product2Id = prd10.Id;
        oli11.Type__c = 'Renewal';
        insert Oli11;
        */
        
        OpportunityHelper.RollupOpptyLines(opMap); 
        OpportunityHelper.IsWeekendDay(date.today());
        OpportunityHelper.AddBusinessDays(date.today(), 2);
        OpportunityHelper.updateProposalPaymentTerm(null,null);
        OpportunityHelper.validatePaymentTerm(null,null);
        
        OpportunityHelper.setLaunchControl();
    }
    
    static testmethod void meth3(){
        //User u = [SELECT Id FROM User where Profile.Name like '%MEP%' AND isactive = true LIMIT 1];
        Id pricebookId = [select id from Pricebook2 where name ='MEP NA'].id;
        Id Stdpricebookid = Test.getStandardPricebookId();
        Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
        Account acct = new Account(Name = 'Test Assign Case Account',Account_Division__c='MEP;MEP NA;',RecordTypeId = acctRecTypeId,CurrencyIsoCode = 'USD',Payment_Term__c = 'CASH IN ADVANCE',Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
                                   BillingCountry = 'United States',Restricted_Entity__c = Label.Not_Restricted,Annual_Support_Date__c = date.today(), BillingCity = 'Pune',BillingState = 'California', BillingPostalCode = 'postal code',BillingStreet = 'A-202',Collector_Email__c = 'test@gmail.com');
        insert acct;
        
        Address__c adrs1;
        adrs1 = new Address__c(Name = 'Test Address',validation_Status__c='Corrected',FCH_Party_Site_Id__c = '222222',Account__c = acct.Id, Country__c = 'United States',Bill_To__c = true,Ship_To__c=true,Address_Line1__c = 'addrs4',Address_Line2__c = 'addrs4',Address_Line3__c = 'addrs4',Address_Line4__c = 'addrs4',City__c = 'city',State__c = 'California',Zip__c = 'zip');
        insert adrs1;
        
        Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c();                
        
        pricelist.Apttus_Config2__Active__c = true;
        pricelist.Name = 'CH Test';
        pricelist.Legal_Entity__c = 'TIBV SWISS BRANCH';
        pricelist.Business_Area__c = 'MANHATTAN SOFTWARE';
        pricelist.Division__c='MEP NA';
        insert pricelist;
        
        contact ct = new contact();
        ct.LastName = 'Test last name';
        ct.AccountId = acct.Id;
        ct.Preferred_Language__c = 'American English';
        ct.Email = 'test@gmail.com';
        ct.MailingStreet='test1';
        ct.Mailingcity='testcity';
        ct.MailingState='California';
        ct.MailingPostalCode ='12345';
        ct.MailingCountry = 'United States';
        insert ct;
        
        List<Opportunity> opList = new List<Opportunity>();   
        Map<Id,Opportunity> opMap = new Map<Id,Opportunity>();     
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acct.Id;
        opp1.Bill_To_Account__c = acct.Id;
        opp1.Ship_To_Account__c = acct.id;
        opp1.Bill_To_Contact__c = ct.Id;
        opp1.Primary_Contact__c =ct.id;
        opp1.Bill_to_Address__c = adrs1.id;
        opp1.Ship_to_Address1__c = adrs1.id;
        opp1.Account_Sub_Type__c = 'Renewal';
        opp1.Renewal_Status__c = 'New';
        opp1.StageName = '6 - Closed Won';
        opp1.Closedate = date.today() + 7;
        opp1.Name = 'Opp1';
        opp1.Ship_To_Account__c = acct.ID;
        opp1.Payment_Term__c = 'CASH IN ADVANCE';
        opp1.OwnerId = UserInfo.getUserId();
        opp1.Selling_Division__c = 'MEP NA';
        opp1.Price_List__c = pricelist.id;      
        insert opp1;
        
        OpportunityHelper.validateRenewalOpportunity(new List<Opportunity>{opp1});
        
        opList.add(opp1);                    
        opMap.put(opp1.Id,opp1);
        
        Product2 prd = new Product2();
        prd.Name = 'test';
        prd.isActive = true;        
        prd.ProductCode = 'Test123';  
        prd.Product_Category_Type__c = 'Software';    
        insert prd;
        
        Product2 prd1 = new Product2();
        prd1.Name = 'test';
        prd1.isActive = true;        
        prd1.ProductCode = 'Test123';  
        prd1.Product_Category_Type__c = 'Service';    
        insert prd1;        
        
        Product2 prd2 = new Product2();
        prd2.Name = 'test';
        prd2.isActive = true;        
        prd2.ProductCode = 'Test123';  
        prd2.Product_Category_Type__c = 'Maintenance';    
        insert prd2;  
        
        
        Product2 prd3 = new Product2();
        prd3.Name = 'test';
        prd3.isActive = true;        
        prd3.ProductCode = 'Test123';  
        prd3.Product_Category_Type__c = 'SaaS';    
        insert prd3; 
        
        Product2 prd4 = new Product2();
        prd4.Name = 'test';
        prd4.isActive = true;        
        prd4.ProductCode = 'Test123';  
        prd4.Product_Category_Type__c = 'Prof. Services';    
        insert prd4; 
        
        Product2 prd5 = new Product2();
        prd5.Name = 'test';
        prd5.isActive = true;        
        prd5.ProductCode = 'Test123';  
        prd5.Product_Category_Type__c = 'Hardware';    
        insert prd5; 
        
        Product2 prd6 = new Product2();
        prd6.Name = 'test';
        prd6.isActive = true;        
        prd6.ProductCode = 'Test123';  
        prd6.Product_Category_Type__c = 'Others'; 
        prd6.ICC_Type__c ='Other';   
        insert prd6; 
        
        Product2 prd7 = new Product2();
        prd7.Name = 'test';
        prd7.isActive = true;        
        prd7.ProductCode = 'Test123';  
        prd7.Product_Category_Type__c = 'Subscription';  
        prd7.ICC_Type__c = 'Training - Hardware';  
        insert prd7;  
        
        Product2 prd8 = new Product2();
        prd8.Name = 'test';
        prd8.isActive = true;        
        prd8.ProductCode = 'Test123';  
        prd8.Product_Category_Type__c = 'Rental';    
        insert prd8;
        
        Product2 prd9 = new Product2();
        prd9.Name = 'test9';
        prd9.isActive = true;        
        prd9.ProductCode = 'Test123';  
        prd9.Product_Category_Type__c = 'Rental'; 
        prd9.Business_Area__c = 'MEP ESTIMATING';
        insert prd9;
        
        Product2 prd10 = new Product2();
        prd10.Name = 'prd10';
        prd10.isActive = true;        
        prd10.ProductCode = 'BUND-ACE-TM-D';  
        prd10.Product_Category_Type__c = 'Software'; 
        //prd10.Business_Area__c = 'MEP ESTIMATING';
        prd10.Business_Area__c = 'ACCUBID';
        prd10.Product_Line__c = 'ACC-TM BILLING SOFTWARE';
        insert prd10;
        
        PriceBookEntry Stdpbe = new PriceBookEntry();        
        Stdpbe.PriceBook2ID = StdpricebookId;
        Stdpbe.Product2Id = prd.Id;
        Stdpbe.UnitPrice = 1;    
        Stdpbe.IsActive = True;        
        insert Stdpbe;                
        
        
        PriceBookEntry Stdpbe1 = new PriceBookEntry();        
        Stdpbe1.PriceBook2ID = StdpricebookId;
        Stdpbe1.Product2Id = prd1.Id;
        Stdpbe1.UnitPrice = 1;    
        Stdpbe1.IsActive = True;        
        insert Stdpbe1; 
        
        PriceBookEntry Stdpbe2 = new PriceBookEntry();        
        Stdpbe2.PriceBook2ID = StdpricebookId;
        Stdpbe2.Product2Id = prd2.Id;
        Stdpbe2.UnitPrice = 1;    
        Stdpbe2.IsActive = True;        
        insert Stdpbe2; 
        
        PriceBookEntry Stdpbe3 = new PriceBookEntry();        
        Stdpbe3.PriceBook2ID = StdpricebookId;
        Stdpbe3.Product2Id = prd3.Id;
        Stdpbe3.UnitPrice = 1;    
        Stdpbe3.IsActive = True;        
        insert Stdpbe3; 
        
        PriceBookEntry Stdpbe4 = new PriceBookEntry();        
        Stdpbe4.PriceBook2ID = StdpricebookId;
        Stdpbe4.Product2Id = prd4.Id;
        Stdpbe4.UnitPrice = 1;    
        Stdpbe4.IsActive = True;        
        insert Stdpbe4; 
        
        PriceBookEntry Stdpbe5 = new PriceBookEntry();        
        Stdpbe5.PriceBook2ID = StdpricebookId;
        Stdpbe5.Product2Id = prd5.Id;
        Stdpbe5.UnitPrice = 1;    
        Stdpbe5.IsActive = True;        
        insert Stdpbe5; 
        
        PriceBookEntry Stdpbe6 = new PriceBookEntry();        
        Stdpbe6.PriceBook2ID = StdpricebookId;
        Stdpbe6.Product2Id = prd6.Id;
        Stdpbe6.UnitPrice = 1;    
        Stdpbe6.IsActive = True;        
        insert Stdpbe6; 
        
        PriceBookEntry Stdpbe7 = new PriceBookEntry();        
        Stdpbe7.PriceBook2ID = StdpricebookId;
        Stdpbe7.Product2Id = prd7.Id;
        Stdpbe7.UnitPrice = 1;    
        Stdpbe7.IsActive = True;        
        insert Stdpbe7; 
        
        PriceBookEntry Stdpbe8 = new PriceBookEntry();        
        Stdpbe8.PriceBook2ID = StdpricebookId;
        Stdpbe8.Product2Id = prd8.Id;
        Stdpbe8.UnitPrice = 1;    
        Stdpbe8.IsActive = True;        
        insert Stdpbe8; 
        
        
        PriceBookEntry Stdpbe9 = new PriceBookEntry();        
        Stdpbe9.PriceBook2ID = StdpricebookId;
        Stdpbe9.Product2Id = prd9.Id;
        Stdpbe9.UnitPrice = 1;    
        Stdpbe9.IsActive = True;        
        insert Stdpbe9;
        
        PriceBookEntry pbe = new PriceBookEntry();        
        pbe.PriceBook2ID = pricebookId;
        pbe.Product2Id = prd.Id;
        pbe.UnitPrice = 1;    
        pbe.IsActive = True;        
        insert pbe;                
        
        
        PriceBookEntry pbe1 = new PriceBookEntry();        
        pbe1.PriceBook2ID = pricebookId;
        pbe1.Product2Id = prd1.Id;
        pbe1.UnitPrice = 1;    
        pbe1.IsActive = True;        
        insert pbe1; 
        
        PriceBookEntry pbe2 = new PriceBookEntry();        
        pbe2.PriceBook2ID = pricebookId;
        pbe2.Product2Id = prd2.Id;
        pbe2.UnitPrice = 1;    
        pbe2.IsActive = True;        
        insert pbe2; 
        
        PriceBookEntry pbe3 = new PriceBookEntry();        
        pbe3.PriceBook2ID = pricebookId;
        pbe3.Product2Id = prd3.Id;
        pbe3.UnitPrice = 1;    
        pbe3.IsActive = True;        
        insert pbe3; 
        
        PriceBookEntry pbe4 = new PriceBookEntry();        
        pbe4.PriceBook2ID = pricebookId;
        pbe4.Product2Id = prd4.Id;
        pbe4.UnitPrice = 1;    
        pbe4.IsActive = True;        
        insert pbe4; 
        
        PriceBookEntry pbe5 = new PriceBookEntry();        
        pbe5.PriceBook2ID = pricebookId;
        pbe5.Product2Id = prd5.Id;
        pbe5.UnitPrice = 1;    
        pbe5.IsActive = True;        
        insert pbe5; 
        
        PriceBookEntry pbe6 = new PriceBookEntry();        
        pbe6.PriceBook2ID = pricebookId;
        pbe6.Product2Id = prd6.Id;
        pbe6.UnitPrice = 1;    
        pbe6.IsActive = True;        
        insert pbe6; 
        
        PriceBookEntry pbe7 = new PriceBookEntry();        
        pbe7.PriceBook2ID = pricebookId;
        pbe7.Product2Id = prd7.Id;
        pbe7.UnitPrice = 1;    
        pbe7.IsActive = True;        
        insert pbe7; 
        
        PriceBookEntry pbe8 = new PriceBookEntry();        
        pbe8.PriceBook2ID = pricebookId;
        pbe8.Product2Id = prd8.Id;
        pbe8.UnitPrice = 1;    
        pbe8.IsActive = True;        
        insert pbe8; 
        
        PriceBookEntry pbe9 = new PriceBookEntry();        
        pbe9.PriceBook2ID = pricebookId;
        pbe9.Product2Id = prd9.Id;
        pbe9.UnitPrice = 1;    
        pbe9.IsActive = True;        
        insert pbe9; 
        
        List<OpportunityLineItem> Olilist = new List<OpportunityLineItem>();        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp1.Id;        
        oli.Quantity = 45;
        oli.Totalprice = 456;
        oli.PricebookEntryId = pbe.Id;
        Olilist.add(oli);
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp1.Id;        
        oli2.Quantity = 45;
        oli2.Totalprice = 456;
        oli2.PricebookEntryId = pbe1.Id;
        Olilist.add(oli2);
        
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp1.Id;        
        oli3.Quantity = 45;
        oli3.UnitPrice = 456;
        oli3.PricebookEntryId = pbe2.Id;
        Olilist.add(oli3);
        
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = opp1.Id;        
        oli4.Quantity = 45;
        oli4.UnitPrice = 456;
        oli4.PricebookEntryId = pbe3.Id;
        Olilist.add(oli4);
        
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = opp1.Id;        
        oli5.Quantity = 45;
        oli5.UnitPrice = 456;
        oli5.PricebookEntryId = pbe4.Id;
        Olilist.add(oli5);
        
        OpportunityLineItem oli6 = new OpportunityLineItem();
        oli6.OpportunityId = opp1.Id;        
        oli6.Quantity = 45;
        oli6.UnitPrice = 456;
        oli6.PricebookEntryId = pbe5.Id;
        Olilist.add(oli6);
        
        OpportunityLineItem oli7 = new OpportunityLineItem();
        oli7.OpportunityId = opp1.Id;        
        oli7.Quantity = 45;
        oli7.UnitPrice = 456;
        oli7.PricebookEntryId = pbe6.Id;
        Olilist.add(oli7);     
        
        OpportunityLineItem oli8 = new OpportunityLineItem();
        oli8.OpportunityId = opp1.Id;        
        oli8.Quantity = 45;
        oli8.UnitPrice = 456;
        oli8.PricebookEntryId = pbe7.Id;
        Olilist.add(oli8);
        
        
        OpportunityLineItem oli9 = new OpportunityLineItem();
        oli9.OpportunityId = opp1.Id;        
        oli9.Quantity = 45;
        oli9.UnitPrice = 456;
        oli9.PricebookEntryId = pbe8.Id;
        Olilist.add(oli9);
        
        OpportunityLineItem oli10 = new OpportunityLineItem();
        oli10.OpportunityId = opp1.Id;        
        oli10.Quantity = 45;
        oli10.UnitPrice = 456; 
        oli10.PricebookEntryId = pbe9.Id;
        oli10.Product2Id = prd9.Id;
        Olilist.add(oli10); 
        insert Olilist;
        //
        delete Olilist;
        Asset ast1 = new Asset();
        ast1.accountId = acct.Id;
        ast1.Name = 'ast1';
        ast1.Product2Id = prd10.Id;
        ast1.Status = 'Active';
        insert ast1;
        entitlement ent1 = new entitlement();
        ent1.accountId= acct.Id;
        ent1.Name = 'testent1';
        ent1.AssetId = ast1.Id;
        ent1.Contract_Start_Date__c = date.today() - 150;
        ent1.Contract_Start_Date__c = date.today() + 150;
        ent1.Entitlement_Product__c = prd10.Id;
        insert ent1;
        //
        
        
        Opportunity updateOpp1 = new Opportunity(id=Opp1.id);
        updateOpp1.StageName = '6 - Closed Won';
        //updateOpp1.Selling_Division__c = 'MEP';
        
        OpportunityHelper.launchControl.put('validateMEPNAEstimatingBusinessArea',0);
        update updateOpp1;
        
        /*
        OpportunityLineItem oli11 = new OpportunityLineItem();
        oli11.OpportunityId = updateOpp1.Id;        
        oli11.Quantity = 45;
        oli11.UnitPrice = 456; 
        oli11.PricebookEntryId = pbe9.Id;
        oli11.Product2Id = prd10.Id;
        oli11.Type__c = 'Renewal';
        insert Oli11;
        */
        
        OpportunityHelper.RollupOpptyLines(opMap); 
        OpportunityHelper.IsWeekendDay(date.today());
        OpportunityHelper.AddBusinessDays(date.today(), 2);
        OpportunityHelper.updateProposalPaymentTerm(null,null);
        OpportunityHelper.validatePaymentTerm(null,null);
        
        OpportunityHelper.setLaunchControl();
    }
}