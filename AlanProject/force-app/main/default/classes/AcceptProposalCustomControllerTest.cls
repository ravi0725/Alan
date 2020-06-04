/*
 * Description:AcceptProposalCustomControllerTest  
 * Modified By: P M MAMATA
 * Date: 01-09-2015
 * 
*/

@isTest(seealldata=true)
Private class AcceptProposalCustomControllerTest{

    static testmethod void meth1(){
        GenerateTestData.createAccount();
        GenerateTestData.createAddress();
        GenerateTestData.createPriceList();
        GenerateTestData.createOpportunity();        
        GenerateTestData.createProposal();
        System.currentPageReference().getParameters().put('id', GenerateTestData.proposal.Id);
        AcceptProposalCustomController apc = new AcceptProposalCustomController();
        apc.UpdateStage();
        //PageReference p = apc.UpdateStage();
        PageReference p1 = apc.callActionMethod();
    }

}