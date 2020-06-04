public class AddressHandler{
    public static Map<String, Integer> launchControl;
    
    // Static initialize
    static {
        resetLaunchControl();
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('configOutboundMessage', 0);
        launchControl.put('resetStatusFlag', 0);
    }
    
    //Set Trigger control (e.g. for testing)
    public static void setLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('configOutboundMessage', 1);
        launchControl.put('resetStatusFlag', 1);
    }
    
    public static List<Address__c> validateDisableCallout(List<Address__c> addList){
        List<Address__c> newAddList = new List<Address__c>();
        for(Address__c add : addList){
            if(!(add.Disable_Callout__c && Label.Disable_FCH_Callout.contains(UserInfo.getName()))){
                newAddList.add(add);
            }
        }
        return newAddList;
    }
    
    public static boolean validateAddressExternalKeyValue(List<Address__c> newList,Map<Id,Address__c> oldMap){
        boolean flag = true;
        for(Address__c add : newList){
            if(add.FCH_Party_Site_ID__c != oldMap.get(add.Id).FCH_Party_Site_ID__c || 
              add.Enterprise_Address_Number__c != oldMap.get(add.Id).Enterprise_Address_Number__c){
                flag = false;
                break;
            }
        }
        return flag;
    }
    
    public static void configOutboundMessage(List<Address__c> newList,Map<Id,Address__c> newMap,Map<Id,Address__c> oldMap,boolean isInsert, boolean isUpdate, boolean isDelete){
        system.debug('----------CallOut------');
        if(launchControl.get('configOutboundMessage') < 1){
            launchControl.put('configOutboundMessage',launchControl.get('configOutboundMessage') + 1);
            String usrProfileName;
            set<String> accIdSet = new set<String>();
            set<String> addIdSet = new set<String>();
            set<String> deleteSet = new set<String>();
        set<Id> validIds = new set<ID>();
        if(isUpdate)validIds = Utils.verifyFieldUpdate(newMap,oldMap,'Address__c','FCH Integration','FCHAddress');
            for(Address__c address : newList){
            if((validIds.contains(address.Id) || isInsert || isDelete) && (address.Account_Life_Cycle_Stage__c == 'Customer' || address.Account_Life_Cycle_Stage__c == 'Qualified Prospect') && 
                    address.Account_Status__c == 'Active'){
                    accIdSet.add(address.Account__c);
                    addIdSet.add(address.Id);
                    deleteSet.add(address.Id + ' ~~ ' + address.Enterprise_Address_Number__c + ' ~~ ' + address.FCH_Party_Site_ID__c);
                }
            }
            system.debug('----------addIdSet------' + addIdSet);
            List<String> tempIdList = new List<String>();
            tempIdList.addAll(accIdSet);
            usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name; 
            system.debug('----------tempIdList------' + tempIdList);
            if(!usrProfileName.contains(Label.Restrict_Callout_Profile) && !AccountCreationCalloutEX.recursiveCallFlag
                && tempIdList.size() == 1)
                AccountCreationCalloutEX.CallEBS(tempIdList,'NoOp','NoOp',(isInsert ? 'Create' : (isUpdate ? 'Update' : 'Delete')),new Set<String>(),addIdSet,deleteSet);
        }
    }
    
    public static void setAddressName(List<Address__c> newList){
    USer userRec = [select u.Profile.Name,division__c from User u where u.id = :Userinfo.getUserId()]; 
    String Usrdivision = userRec.division__c;
    String Profile = userRec.Profile.Name;
        for(Address__c addr : newList){
            if(addr.Account_Name__c != null ? addr.Account_Name__c.length()>80 : false)
            addr.Name = addr.Account_Name__c.substring(0,79);
            else
            addr.Name = addr.Account_Name__c; 
            
            if(addr.country__c=='Brazil')
            addr.Brazilian_Neighborhood__c = addr.Address_Line2__c;
            
            if(Profile !='API Only'){
            if(usrdivision != NULL && usrdivision=='TAP')
            addr.POS_Flag__c = True;
            else
            addr.POS_Flag__c = False;
           }
        }
        
    }
    
    public static void populateRegionValue(List<Address__c> newList){
        system.debug('ONN=============');
        for(Address__c addr : newList){
            if(addr.Country__c != NULL ? Country_Region_Mapping__c.getValues(addr.Country__c) != NULL : false){
                addr.Address_Region__c = Country_Region_Mapping__c.getValues(addr.Country__c).Region__c;
            }
        }
    }
  
    public static void resetStatusFlag(Map<Id,Address__c> newMap, Map<Id,Address__c> oldMap){
    String usrProfileName;
    usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name; 
    system.debug('*****UserProfile*****'+usrProfileName);
        if(launchControl.get('resetStatusFlag') < 1){
            launchControl.put('resetStatusFlag',launchControl.get('resetStatusFlag') + 1);
            for(Address__c Ad : newMap.values())
            {
                if(!usrProfileName.contains(Label.Restrict_Callout_Profile) && ((oldMap.get(Ad.id).Address_Line1__c != Null && oldMap.get(Ad.id).Address_Line1__c != newMap.get(Ad.id).Address_Line1__c)||
                   (oldMap.get(Ad.id).Address_Line2__c != Null && oldMap.get(Ad.id).Address_Line2__c != newMap.get(Ad.id).Address_Line2__c)||
                   (oldMap.get(Ad.id).Address_Line3__c != Null && oldMap.get(Ad.id).Address_Line3__c != newMap.get(Ad.id).Address_Line4__c)||
                   (oldMap.get(Ad.id).Address_Line4__c != Null && oldMap.get(Ad.id).Address_Line3__c != newMap.get(Ad.id).Address_Line4__c)||
                   (oldMap.get(Ad.id).State__c!= Null && oldMap.get(Ad.id).State__c!= newMap.get(Ad.id).State__c)||
                   (oldMap.get(Ad.id).City__c!= Null && oldMap.get(Ad.id).City__c!= newMap.get(Ad.id).City__c)||
                   (oldMap.get(Ad.id).County__c!= Null && oldMap.get(Ad.id).County__c!= newMap.get(Ad.id).County__c)||
                   (oldMap.get(Ad.id).Country__c!= Null && oldMap.get(Ad.id).Country__c!= newMap.get(Ad.id).Country__c)||
                   (oldMap.get(Ad.id).Zip__c!= Null && oldMap.get(Ad.id).Zip__c!= newMap.get(Ad.id).Zip__c))){
                    system.debug('*****UserProfile*****'+usrProfileName);
                       Ad.Validation_Status_Code__c ='';
                       Ad.Validation_Status__c ='';
                   }
            }
        }
    }
}