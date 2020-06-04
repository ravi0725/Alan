@isTest(seealldata=true)
private class BrazilianControllerTest{
    static testmethod void meth1(){
    GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        ApexPages.StandardController sc = new ApexPages.StandardController(GenerateTestData.adrs);
        System.currentPageReference().getParameters().put('id', GenerateTestData.adrs.Id);
        BrazilianNeighborhoodAddressController bnc = new BrazilianNeighborhoodAddressController(sc);
        bnc.brazilianState ='CE';
        bnc.brazilianCity ='ICO';
        bnc.getStates();
        bnc.getCities();
        bnc.save();
    }
   }