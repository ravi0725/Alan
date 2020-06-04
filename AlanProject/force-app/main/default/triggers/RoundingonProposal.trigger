trigger RoundingonProposal on Apttus_Proposal__Proposal__c (before update,before insert) {
    //if(checkRecursive.isFirstRun()){
       // checkRecursive.setFirstRunFalse();
        List<Apttus_Proposal__Proposal__c > app1 = new List<Apttus_Proposal__Proposal__c >();
        List<Apttus_Proposal__Proposal__c > Updateapp1 = new List<Apttus_Proposal__Proposal__c >();
        Set<ID> PropoID = new Set<ID>();
        for(Apttus_Proposal__Proposal__c app : trigger.new){
            try{
                                  
                    app.Software_Only_Total_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Software_Only_Total_Disp__c);
                    app.Software_Disc_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Software_Disc_Disp__c);
                    app.Software_Total_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Software_Total_Disp__c);
                    app.Software_Disc_2dec_Rounded__c = SwissRounding.ApplySwissRounding(app.Software_Disc_2dec__c);
                    app.Third_Party_Total_Disp_Rounded__c  = SwissRounding.ApplySwissRounding(app.Third_Party_Total_Disp__c);
                    app.Third_Party_Disc_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Third_Party_Disc_Disp__c);
                    app.Hardware_Total_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Hardware_Total_Disp__c);
                    app.Hardware_Discount_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Hardware_Discount_Disp__c);
                    app.Service_Total_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Service_total_disp__c);
                    app.Service_Discount_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Service_Discount2__c);
                    app.Maintenance_Total_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Maintenance_Total_Disp__c);
                	
                	// Added by Suresh Babu - 03-May-2016
                	app.Training_Discount_Display_Rounded__c = SwissRounding.ApplySwissRounding(app.Training_Discount_Display__c);
                	app.Training_Net_Price_Total_Disp_Rounded__c = SwissRounding.ApplySwissRounding(app.Training_Net_Price_Display__c);
                	app.Special_Services_Discount_Rounded__c = SwissRounding.ApplySwissRounding(app.Special_Services_Discount_Disp__c);
                	app.Special_Services_Total_Rounded__c = SwissRounding.ApplySwissRounding(app.Special_Services_Total_Display__c);
                	// 
                
            }catch(Exception ex){
                app.addError('Some Exception occurred while saving. Please contact to your Administrator.');
            }
        }
   // } 
}