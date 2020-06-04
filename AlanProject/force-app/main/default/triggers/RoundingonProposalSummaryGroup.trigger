trigger RoundingonProposalSummaryGroup on Apttus_QPConfig__ProposalSummaryGroup__c (before update,before insert) {

    for(Apttus_QPConfig__ProposalSummaryGroup__c app: Trigger.New)
    {
        try{
            
            if(app.Price_List_Legal_Entity__c=='TIBV SWISS BRANCH'){
                //Net_Price_Disp_Rounded__c
                app.Net_Price_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Net_Price_Disp__c);
            }else{
                app.Net_Price_Disp_Rounded__c = app.Net_Price_Disp__c;
            }
        }catch(Exception ex){
            app.addError('Some Exception occurred while saving. Please contact to your Administrator.');
        }
    }
}