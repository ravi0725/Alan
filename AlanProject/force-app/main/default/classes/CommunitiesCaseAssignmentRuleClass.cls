/*****************************************************************************************
    Name         : CommunitiesCaseAssignmentRuleClass 
    Desc         : Used for assigning the case record to a queue called Customer Portal Case Queue.
    Project Item : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta          01/22/2014          Created
******************************************************************************************/
public class CommunitiesCaseAssignmentRuleClass{

    public String caseId{get;set;}
    
    /**
     * Method name  : CommunitiesCaseAssignmentRuleClass
     * Description  : Constructor of the Controller class - Initializes all the variables.                
     * Return Type  : 
     * Parameter    : 
     **/
    public CommunitiesCaseAssignmentRuleClass(ApexPages.StandardSetController controller){
        caseId = ApexPages.currentPage().getParameters().get('id');
    }
    
    /**
     * Method name  : submitCaseForAssignmentRule
     * Description  : This method is used to change the owner of the case record to a queue called Customer Portal Case Queue      
     * Return Type  : PageReference
     * Parameter    : 
     **/
    public PageReference submitCaseForAssignmentRule(){
        List<Case> caseList = new List<Case>();
        caseList = [Select Id, OwnerId, Account.BillingCountry, Contact.Preferred_Language__c from Case where Id =: caseId];
        if(caseList.size() > 0){
           Case case1 = new Case();
           case1 = caseList.get(0);
           List<User> userList = new List<User>();
           userList = [Select Id, ProfileId from User where Id =: case1.OwnerId];
           List<Profile> profileList = new List<Profile>();
           profileList = [Select Id, Name from Profile where Name =: Label.MEP_Europe_Community_Profile];
           if(profileList.size() > 0){
              if(userList.get(0).ProfileId == profileList.get(0).Id){
                String developerName = 'test';
                if(case1.Account.BillingCountry == 'Switzerland' && case1.Contact.Preferred_Language__c == 'German'){
                   developerName = Label.Customer_Portal_Case_CH;
                }else if(case1.Account.BillingCountry == 'Germany' || case1.Account.BillingCountry == 'Austria'){
                   developerName = Label.Customer_Portal_Case_DEAT;
                }else if(case1.Account.BillingCountry == 'United Kingdom'){
                   developerName = Label.Customer_Portal_Case_UK;
                }else if(case1.Account.BillingCountry == 'France' || (case1.Account.BillingCountry == 'Switzerland' && case1.Contact.Preferred_Language__c == 'French')){
                   developerName = Label.Customer_Portal_Case_FR;
                }else{
                   developerName = Label.Customer_Portal_Case_DEAT;
                }
                if(developerName != 'test'){
                   List<Group> groupList = new List<Group>();
                   groupList = [Select Id from Group where DeveloperName =: developerName];
                   if(groupList.size() > 0){
                     case1.OwnerId = groupList.get(0).Id;
                     update case1;
                   }                           
                }
              }           
           }   
        }
        return new PageReference('/home/home.jsp');  
    }
}