trigger RoundingonProposalLineItem on Apttus_Proposal__Proposal_Line_Item__c (before Update,before insert) {
    for(Apttus_Proposal__Proposal_Line_Item__c app: Trigger.New)
    {
        try{
            if(app.Price_List_Legal_Entity__c=='TIBV SWISS BRANCH'){
                //Extended_Price_Disp_Rounding__c
                app.Extended_Price_Disp_Rounding__c = SwissRounding.ApplySwissRounding(app.Extended_Price_Disp__c);
                //Base_Price_Disp_Rounded__c
                app.Base_Price_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Base_Price_Disp__c);
            }
            else
            {
                app.Extended_Price_Disp_Rounding__c  = app.Extended_Price_Disp__c;
                app.Base_Price_Disp_Rounded__c = app.Base_Price_Disp__c;
                
                 if(app.service_Start_date__c != Null && app.Service_End_date__c != Null){
                 Integer NoMonths =0;
                 String Output = CalculateDuration.MonthsandDays(app.service_Start_date__c,app.Service_End_date__c);
                List<String>OutputList = Output.split(':');
                NoMonths = Integer.valueof(OutputList.get(0));
                app.Number_of_Months__c = NoMonths;
                }
            }
             if(app.Apttus_QPConfig__Quantity2__c!=Null && app.Apttus_QPConfig__Quantity2__c==0)
          app.Apttus_QPConfig__IsPrimaryLine__c = False;
        }catch(Exception ex){
            app.addError('Some Exception occurred while saving. Please contact to your Administrator.');
        }
    }
}