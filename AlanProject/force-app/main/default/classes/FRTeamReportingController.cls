/**
 * Company     : Trimble Software Technology Pvt Ltd.,
 * Description : Appers as a Popup Page from Quote Detail pageon Proposal Line Item related List
 * History     : 
 * [6.Nov.2014] Ankur Patel    - Code Created.
 **/
public class FRTeamReportingController{
    public case cs{get;set;}
    public String StartDate{get;set;}
    public String EndDate{get;set;}
    public string ownersName{get;set;}
    public string accountName{get;set;}
    public transient List<Account> accList{get;set;} 
    public boolean showTable{get;set;}
    public boolean flag{get;set;}
    public Id teamReportId{get;set;}
    public Id customerReportId{get;set;}
    public string reportURL{get;set;}
    public FRTeamReportingController(){
        cs = new Case();
        accList = new List<Account>();
        showTable = false;
        flag = false;
        reportURL = '';
        accountName = '';
        teamReportId = null;
        customerReportId = null;
        Set<Id> userIdSet = new Set<ID>();
        
        for(GroupMember gpMem : [select UserOrGroupId from GroupMember where Group.DeveloperName = 'CAD_FR_Nova_Technic_Team']){
            userIdSet.add(gpMEm.USerOrGroupId);
        }
        
        ownersName = '';
        for(User ur : [select Name from User where Id in : userIdSet]){
            ownersName = ownersName + ',' + ur.Name;
        }
        
        if(ownersName.length() > 0){
            ownersName = ownersName.subString(1,ownersName.length());
        }
        
        for(Report rt : [select Id,DeveloperName from Report where DeveloperName in : 'FR_Team_Report_Based_on_Customer,FR_Team_Reporting'.split(',')]){
            if(rt.DeveloperName == 'FR_Team_Report_Based_on_Customer'){
                customerReportId = rt.Id;
            }else{
                teamReportId = rt.Id;
            }
        }
    }
    
    public void getDailyReport(){
        if(checkDateValue()){
            StartDate = cs.Due_Date__c.month() + '/' + cs.Due_Date__c.day() + '/' + cs.Due_Date__c.year();
            reportURL = '/' + teamReportId + '?pv0=' + StartDate + '&pv1=' + StartDate + '&pv5=' + ownersName + '&pv7=' + StartDate + '&pv8=' + StartDate;
        }
    }
    
    public void getWeekRange(){
        flag= false;
        if(checkDateValue()){
            flag = true;
            Date d1 = cs.Due_Date__c.toStartofWeek();
            StartDate = d1.month() + '/' + d1.day() + '/' + d1.year();
            d1 = (d1 + 6);
            EndDate = d1.month() + '/' + d1.day() + '/' + d1.year();
            reportURL = '/' + teamReportId + '?pv0=' + EndDate + '&pv1=' + StartDate + '&pv5=' + ownersName + '&pv7=' + EndDate + '&pv8=' + StartDate;
        }
    }
    
    public void getMonthRange(){
        flag = false;
        if(checkDateValue()){
            flag = true;
            Date d1 = cs.Due_Date__c.toStartOfMonth();
            StartDate = d1.month() + '/' + d1.day() + '/' + d1.year();
            d1 = (d1 + (date.daysInMonth(d1.year(),d1.month()) - 1));
            EndDate = d1.month() + '/' + d1.day() + '/' + d1.year();
            reportURL = '/' + teamReportId + '?pv0=' + EndDate + '&pv1=' + StartDate + '&pv5=' + ownersName + '&pv7=' + EndDate + '&pv8=' + StartDate;
        }
    }
    
    public void searchAcc(){
        accList = [select Id,Name from Account where Name like : '%' + accountName + '%' and (BillingCountry = 'France' or
                    (BillingCountry = 'Switzerland' and Preferred_Language__c = 'French'))];
        if(accList.size() > 0){
            showTable = true;        
        }
    }
    
    public boolean checkDateValue(){
        if(cs.Due_Date__c == null){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.error,'Please select Date.');
            apexpages.addmessage(msg);
            return false;
        }
        return true;
    }
}