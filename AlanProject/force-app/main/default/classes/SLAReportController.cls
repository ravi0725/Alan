public class SLAReportController{

    public Boolean displayInput{get;set;}
    public Boolean displayReport{get;set;}
    public Case slacase{get;set;}
    public List<case> slalst{get;set;}
    public String AccountName{get;set;}    
    public SLAReportController(){
    displayInput = true;
    displayReport = false;
    slacase=new Case();
     
    
    }
    
    public void getReport()
    {
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RE&WS - Support').getRecordTypeId();
        displayInput = false;
        displayReport = true;
        slalst = [Select Id, casenumber, priority, Manhattan_US_Case_Number__c, account.Name, status, Awaiting_Client_Response__c, Client_Monitoring__c, Fixed_Pending_Client_Confirmation__c, On_Hold__c, Patch_Delivered_to_Client__c, SA_Research_In_Progress__c, With_Engineering__c, With_Hosting_Services__c  from Case where accountid =: slacase.accountid and RecordTypeid =: caseRecordTypeId  and (Not status like 'Case Closed by%') order by priority];
        if(slalst.size() > 0)
        AccountName = slalst[0].account.Name; 
        
 
    }
    
    public PageReference exportReport()
    {

        PageReference pr = new PageReference('/apex/SLAReportExcel');
        pr.setRedirect(false);
        return pr;
    }

}