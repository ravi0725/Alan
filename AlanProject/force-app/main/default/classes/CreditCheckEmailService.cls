/*****************************************************************************************
    Name        : CreditCheckEmailService
    Desc        : CreditCheckEmailService class is a global class.
                  It is invoked by Email Service InboundEmailService.
                                          
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo         15/06/2015            Created
******************************************************************************************/
global class CreditCheckEmailService implements Messaging.InboundEmailHandler {
global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String Sub = email.subject;
		String firstLine = email.plainTextBody.split('\n')[0];   
		String action;       
       
		if(firstLine.contains('Approved') || firstLine.contains('approved') || firstLine.contains('Approve') || firstLine.contains('approve') || firstLine.contains('APPROVE') || firstLine.contains('APPROVED'))
		action = 'Approve';
		else if(firstLine.contains('Rejected') || firstLine.contains('rejected') || firstLine.contains('Reject') || firstLine.contains('reject') || firstLine.contains('REJECT') || firstLine.contains('REJECTED'))
		action = 'Reject';
    	   
           Integer index;
           String taskidnew;
           index = sub.lastIndexof('Q-');       
           taskidnew = sub.substring(index,index+10);
           system.debug('************'+taskidnew);
           system.debug('************'+firstLine);
           List<Apttus_Proposal__Proposal__c> Prop = new List<Apttus_Proposal__Proposal__c>();
           List<Apttus__APTS_Agreement__c> AggList = new List<Apttus__APTS_Agreement__c >();
           Prop = [Select id,Credit_Status__c,Apttus_Proposal__Opportunity__c,Credit_Approved__c,Apttus_Proposal__Approval_Stage__c,Apttus_QPApprov__Approval_Status__c from Apttus_Proposal__Proposal__c where Name=:taskidnew];
           System.debug('-----Prop--------'+Prop+'------Prop.get(0).id--------'+Prop.get(0).id);
    		AggList = [Select id,Apttus__Status_Category__c ,Apttus__Status__c,Credit_Status__c,Credit_Approved__c,Fusion_Project_Number__c,Total_Agreement_Value_Formula__c,Apttus__Contract_Start_Date__c, Apttus__Contract_End_Date__c from Apttus__APTS_Agreement__c where Apttus_QPComply__RelatedProposalId__r.Name =: taskidnew and Apttus__Status_Category__c ='Credit Check Hold' and Apttus__Status__c='Hold'];
           System.debug('-----AggList--------(AggList)'+AggList);
		   System.debug('-----Prop--------(Prop)'+Prop);
    		ID QtId = (Prop.size()>0) ? Prop.get(0).id : '';
           if(Prop.size()>0 && AggList.size()>0)
           {
           System.debug('---------action------------'+action);    
           if(action == 'Approve'){
           Prop.get(0).Apttus_Proposal__Approval_Stage__c= 'Order Submitted';//'Credit Reviewed & Approved';
           AggList.get(0).Credit_Approved__c = 'Y';
            Prop.get(0).Credit_Approved__c = 'Y';
            AggList.get(0).Apttus__Status_Category__c = 'In Effect : Submitted';
            AggList.get(0).Apttus__Status__c ='Activated';
           
           CreditHistoryLogs ch = new CreditHistoryLogs();
           String LogStr = 'Quote / Proposal / Agreement is Approved by : '+email.fromName+' Credit_Approved : Y ; Order Submitted : Y';
           ch.CreateLog(LogStr,Prop.get(0).Id,AggList.get(0).Id); 
           }
         /*  else if(action =='Reject'){
            Prop.get(0).Apttus_Proposal__Approval_Stage__c='';
            AggList.get(0).Credit_Approved__c = 'N';
            Prop.get(0).Credit_Approved__c = 'N';
           
           } */
               update Prop[0];
               update AggList[0];
           
               if(action=='Approve')
               {
                CallEBSForSubmitOrder(QtId,'1');
               }
           }
           
           return result;
           
         
   }

    @future(callout=True)
    Public Static void CallEBSForSubmitOrder(ID QtId,String Opr)
    {
    SubmitorderFromEmailService Qp = new SubmitorderFromEmailService();
     Qp.SubmitOrder(QtId,Opr);
   
    }
}