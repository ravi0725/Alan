@isTest(seealldata=true)
public class LoanRrentalHistoryHandlertest{
    static testmethod void LoanRrentalHistoryHandler1(){
        
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();        
        GenerateTestData.createAddress();
        GenerateTestData.createProposal();
        GenerateTestData.createProduct2();
        Apttus_Config2__ProductConfiguration__c acpcfg = new Apttus_Config2__ProductConfiguration__c();
        acpcfg.Name = 'test acpcfg';
        acpcfg.Apttus_QPConfig__Proposald__c = GenerateTestData.proposal.Id;
        acpcfg.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist.Id;
        //acpcfg.Apttus_Config2__Status__c ='Finalized';
        insert acpcfg;
        
        
        Apttus_Config2__LineItem__c standardliTm = new Apttus_Config2__LineItem__c();
        //standardliTm.Apttus_Config2__ChargeType__c = 'Standard Price';
        //standardliTm.Apttus_Config2__IsPrimaryLine__c = true;
        standardliTm.Apttus_Config2__ItemSequence__c = 1;
        standardliTm.Apttus_Config2__LineNumber__c = 1;
        standardliTm.Apttus_Config2__ConfigurationId__c = acpcfg.Id;
        standardliTm.Apttus_Config2__Quantity__c = 2;
        standardliTm.Apttus_Config2__ProductId__c = GenerateTestData.prd.Id;
        standardliTm.Apttus_Config2__PrimaryLineNumber__c = 1;
        standardliTm.Apttus_Config2__IsOptionRollupLine__c = true;
        standardliTm.Duration__c = 1;
        standardliTm.service_Start_Date__c=date.newinstance(2016,04,01);
        standardliTm.service_End_date__c = system.today()+50;
        standardliTm.Duration_UOM__c = 'Year';
        standardliTm.Apttus_Config2__ChargeType__c = 'Maintenance Fee';
        standardliTm.Apttus_Config2__IsOptionRollupLine__c = False;
        standardliTm.Apttus_Config2__AdjustmentAmount__c = 100;
        standardliTm.Apttus_Config2__AdjustmentType__c = '% Discount';
        standardliTm.Apttus_Config2__PriceListId__c = GenerateTestData.pricelist1.id;
        //standardliTm.Asset_Oracle_ID__c = 'test';
        insert standardliTm;
        
        GenerateTestData.CreateProposalLineItem();
        
        Loaner_Rentals__c loaner = new Loaner_Rentals__c();
        loaner.Product__c =  GenerateTestData.prd.Id;
        insert loaner;
        
        Loaner_Rental_History__c his = new Loaner_Rental_History__c();
        his.Loaner_Rentals__c = loaner.id;
        his.Opportunity__c = GenerateTestData.opp.Id;
        //his.Check_Out_Date__c = system.today();
        insert his; 
        
        List<Loaner_Rental_History__c> Hislist = new List<Loaner_Rental_History__c>();
        Hislist.add(his);
        
        LoanRrentalHistoryHandler loRent = new LoanRrentalHistoryHandler();
        //LoanRrentalHistoryHandler.updateStartdateEnddate(HisList);
        }
  }