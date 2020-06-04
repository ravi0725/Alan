public class ContactHandler{
    public static Map<String, Integer> launchControl;
    
    // Static initialize
    static {
        resetLaunchControl();
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('configOutboundMessage', 0);
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void setLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('configOutboundMessage', 1);
    }
    
    public static List<Contact> validateDisableCallout(List<Contact> conList){
        List<Contact> newConList = new List<Contact>();
        for(Contact con : conList){
            if(!(con.Disable_Callout__c && Label.Disable_FCH_Callout.contains(UserInfo.getName()))){
                newConList.add(con);
            }
        }
        return newConList ;
    }
    
    public static boolean validateContactExternalKeyValue(List<Contact> newList,Map<Id,Contact> oldMap){
        boolean flag = true;
        for(Contact con : newList){
            if(con.FCH_Contact_Id__c != oldMap.get(con.Id).FCH_Contact_Id__c || 
               con.Enterprise_Contact_Number__c != oldMap.get(con.Id).Enterprise_Contact_Number__c){
                   flag = false;
                   break;
               }
        }
        return flag;
    }
    
    public static void configOutboundMessage(List<Contact> newList,Map<Id,Contact> newMap,Map<Id,Contact> oldMap,boolean isInsert, boolean isUpdate, boolean isDelete){
        if(launchControl.get('configOutboundMessage') < 1){
            launchControl.put('configOutboundMessage',launchControl.get('configOutboundMessage') + 1);
            String usrProfileName;
            set<String> accIdSet = new set<String>();
            set<String> conIdSet = new set<String>();
            set<String> deleteSet = new set<String>();
            set<Id> validIds = new set<ID>();
            if(isUpdate)validIds = Utils.verifyFieldUpdate(newMap,oldMap,'Contact','FCH Integration','FCHContact');
            for(Contact con : newList){
                if((isUpdate || isInsert || isDelete) && (con.Account_Life_Cycle_Stage__c == 'Customer' || con.Account_Life_Cycle_Stage__c == 'Qualified Prospect') && 
                   con.Account_Status__c == 'Active'){ //validIds.contains(con.Id)
                       accIdSet.add(con.AccountID);
                       conIdSet.add(con.Id);
                       deleteSet.add(con.Id + ' ~~ ' + con.Enterprise_Contact_Number__c + ' ~~ ' + con.FCH_Contact_Id__c);
                   }
            }
            List<String> tempIdList = new List<String>();
            tempIdList.addAll(accIdSet);
            usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name; 
            system.debug('-----------------------' + conIdSet);
            system.debug('-----------------------' + tempIdList);
            system.debug('-----------------------' + deleteSet);
            if(!Label.Restrict_Callout_Profile.contains(usrProfileName))
                AccountCreationCalloutEX.CallEBS(tempIdList, 'NoOp', (isInsert ? 'Create' : (isUpdate ? 'Update' : 'Delete')) , 'NoOp',conIdSet,new Set<String>(),deleteSet);
        }
    }
    
    Public static void CheckInvoice(List<Contact> newList){
        system.debug('>>>>>>>>>c.Invoice_Delivery_Method__c>>>>>>>>>..'+newList);
        for(contact c : newList){
            system.debug('>>>>>>>>>c.Invoice_Delivery_Method__c>>>>>>>>>..'+c.Invoice_Delivery_Method__c);
            if(c.Invoice_Delivery_Method__c != Null)
                c.Invoice__c = true;
        }
    }
    
    public static void validateTAPContact(List<Contact> conList,Map<Id,Contact> conMap){
        //Added for TAP Project - To Identity Duplicate COntacts based on Email  
        set<String> NewEmailSet = new set<String>();
        set<String> OldEmailSet = new set<String>();
        if(conMap == null) conMap = new Map<Id,Contact>();
        for(Contact Con : conList){
            if(Con.Email != null && Con.MarketingListTAP__c && Con.Unique_Contact_Relationship__c){
              	NewEmailSet.add(Con.Email);
            }
            
            if(Con.Email != null && con.MarketingListTAP__c &&
               (conMap.containsKey(Con.Id) ? Con.Unique_Contact_Relationship__c != conMap.get(Con.Id).Unique_Contact_Relationship__c : false))
                    Con.SystemValidatedDuplicateContact__c = false;
        }
        
        if(NewEmailSet.size() > 0){
            for(Contact Con : [select Id,Email from Contact where Email In : NewEmailSet AND MarketingListTAP__c = true
                               AND Unique_Contact_Relationship__c = true AND Id not in : conMap.keyset()]){
                                   OldEmailSet.add(Con.Email);
                               }
            
            for(Contact Con : conList){
                if(Con.Email != Null && con.MarketingListTAP__c && Con.Unique_Contact_Relationship__c ? OldEmailSet.contains(con.Email) : false){
                    Con.Unique_Contact_Relationship__c = False;
                    Con.SystemValidatedDuplicateContact__c = true;
                }
            }
        }
    }
}