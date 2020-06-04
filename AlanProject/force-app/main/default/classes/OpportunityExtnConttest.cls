@isTest(seealldata=true)

private class OpportunityExtnConttest{

    static testmethod void OpportunityExtnContM1(){
        test.startTest();
        GenerateTestData.createAccount();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();
        GenerateTestData.createAddress();
        GenerateTestData.createContact();
         Test.setCurrentPage(Page.opportunity_edit_AddressInfoOverride);
         System.currentPageReference().getParameters().put('id', GenerateTestData.opp.id);
         ApexPages.standardController stdCon =new  ApexPages.standardController(GenerateTestData.opp);
         OpportunityExtnCont ObjInst = new OpportunityExtnCont(stdCon);
         ObjInst.billToAddressId =  GenerateTestData.adrs.id;
         ObjInst.shipToAddressId =  GenerateTestData.adrs.id;
         ObjInst.billToContactId = GenerateTestData.ct.id;
         ObjInst.shipToContactId = GenerateTestData.ct.id;
         ObjInst.loadOptyDetail();
         ObjInst.formatAddress(GenerateTestData.adrs);
         ObjInst.getBillToContact();
         ObjInst.getShipToContact();
         ObjInst.save();
         
         }
  }