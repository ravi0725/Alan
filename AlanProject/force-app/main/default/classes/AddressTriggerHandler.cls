/*****************************************************************************************
    Name         : AddressTriggerHandler 
    Desc         : Used for Populating Account.Restricted_Entity__c based on ALL Address record's Restricted_Party_Indicator__c field value associated with it. This controller will be called from AddressTrigger Trigger.

---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prasad Mahamunee        07/31/2015          Created
******************************************************************************************/
public class AddressTriggerHandler
{
    
       /*
        * Method name  : setAccountRestrictedEntity
        * Description  : This is a static method to set Account's Restricted_Entity__c field. It checks All Addresses to associated Account and set value as - (Restricted/Check in Progress/Not Restricted).
        * Return Type  : NA
        * Parameter    : List of New and Old Addresses.
        */  
    public static void setAccountRestrictedEntity(List<Address__c>lstNewAddress, List<Address__c>lstOldAddress)
    {
        set<Id>setAccountIds = new set<Id>();
        for(Integer iCount=0; iCount < lstNewAddress.size(); iCount++)
        {
            Address__c objOldAddress = null;
            if(trigger.isUpdate)
                objOldAddress = lstOldAddress[iCount];
            Address__c objNewAddress = lstNewAddress[iCount];
            if((trigger.isInsert && objNewAddress.Account__c != null ) || (trigger.isUpdate && objOldAddress.Restricted_Party_Indicator__c != objNewAddress.Restricted_Party_Indicator__c && objNewAddress.Account__c != null))
            {
                if(trigger.isUpdate && objNewAddress.Account__c != objOldAddress.Account__c)
                {
                    setAccountIds.add(objNewAddress.Account__c);
                    setAccountIds.add(objOldAddress.Account__c);
                }
                else
                    setAccountIds.add(objNewAddress.Account__c);
                
            }
        }
        
        if(setAccountIds != null && setAccountIds.size() > 0)
            updateAccountRestrictedEntity(setAccountIds);
    }
    
        /*
        * Method name  : updateAccountRestrictedEntity
        * Description  : This is a static method. This method takes set of Account Ids and updates Restricted_Entity__c field of those Accounts. 
        * Return Type  : NA
        * Parameter    : Set of Account Ids to process. 
        */
    public static void updateAccountRestrictedEntity(set<Id>setAccountIds)
    {
        List<Account> lstAccount = [select id, name,Restricted_Entity__c,(select id,Account__c,Restricted_Party_Indicator__c from Addresses__r ) from Account where id in :setAccountIds];
        
        List<Account>lstAccountsToUpdate = new List<Account>();
        
        for(Account objAccount : lstAccount)
        {
            if(objAccount.Addresses__r != null && objAccount.Addresses__r.size() > 0)
            {
                objAccount.Restricted_Entity__c = getRestrictedEntityForAccount(objAccount);
                lstAccountsToUpdate.add(objAccount);
            }
        }
        
        if(lstAccountsToUpdate != null && lstAccountsToUpdate.size() > 0)
            update lstAccountsToUpdate;
    }
    
    /*
    * Method name  : getRestrictedEntityForAccount
    * Description  : This is a static method. This method takes Account object and returns Restricted_Entity__c field value for that particular  Account. 
    * Return Type  : NA
    * Parameter    : Account object to manipulate Restricted_Entity__c field value.
    */
    public static String getRestrictedEntityForAccount(Account objAccount)
    {
        String strRestrictedEntity = '';
        boolean bCheckInProgressFound = false;
        boolean bAllNotRestrictedFound = true;
        for(Address__c objAddress : objAccount.Addresses__r)
        {
            if( !String.isEmpty(objAddress.Restricted_Party_Indicator__c))
            {
                if(objAddress.Restricted_Party_Indicator__c.equalsIgnoreCase('Restricted'))
                    return 'Restricted';
                if(objAddress.Restricted_Party_Indicator__c.equalsIgnoreCase('Check in Progress'))
                    bCheckInProgressFound = true;
                if(!objAddress.Restricted_Party_Indicator__c.equalsIgnoreCase('Not Restricted'))
                    bAllNotRestrictedFound = false;
            }
        }
        
        if(bCheckInProgressFound)
            return 'Check in Progress';
        
        if(bAllNotRestrictedFound)
            return 'Not Restricted';
        
        return strRestrictedEntity;
    }
    
    /*
    *   Method Name :   checkPrimaryAddressForAccount
    *   Description :   This is a static method. This method used restrict one Address should be Primary Address for Account
    *   Parameter   :   MAP of New & Old Addresses
    *   Return Type :   N/A
    */
    public static void checkPrimaryAddressForAccount(Map<Id, Address__c> mapNewAddresses, Map<Id, Address__c> mapOldAddresses){
     String usrProfileName;
    usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name; 
        RecursiveTriggerUtility.isAddressRecursive = false;
        Set<Id> AccountIds = new Set<Id>();
        Set<Id> AddressIds = new Set<Id>();
        for(Address__c adr : mapNewAddresses.values()){
            AccountIds.add(adr.Account__c);
            AddressIds.add(adr.Id);
        }
        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, BillingCountry, County__c, BillingState, BillingPostalCode,Validation_Status_Code__c,Validation_Status__c,Job_Token__c FROM Account WHERE Id IN : AccountIds]);
        
        List<Account> lstAccountsUpdate = new List<Account>();
        Set<Account> setAccountsUpdate = new Set<Account>();
        for(Address__c adr : mapNewAddresses.values()){
            if(adr.Primary__c){
                // checking ANY Address value GOT Changed
                Address__c oldadr = mapOldAddresses.get(adr.Id);
                if(!usrProfileName.contains(Label.Restrict_Callout_Profile) && adr.Address_line1__c != oldadr.Address_line1__c ||
                    adr.Address_line2__c != oldadr.Address_line2__c ||
                    adr.Address_line3__c != oldadr.Address_line3__c ||
                    adr.Address_line4__c != oldadr.Address_line4__c ||
                    adr.City__c != oldadr.City__c ||
                    adr.Country__c != oldadr.Country__c ||
                    adr.County__c != oldadr.County__c ||
                    adr.State__c != oldadr.State__c ||
                    adr.Zip__c != oldadr.Zip__c ||
                    adr.validation_status__c != oldadr.validation_Status__c ||
                    adr.validation_status_Code__c != oldadr.validation_status_Code__c ||
                    adr.Job_Token__c != oldadr.Job_Token__c){
                    
                    Account accChanged = updateAccountBillingAddress(mapAccounts.get(adr.Account__c), adr);
                    setAccountsUpdate.add(accChanged);
                }
            }
        }
        if(setAccountsUpdate.size() > 0){
            AccountHelper.launchControl.put('resetStatusFlag', 1);
            lstAccountsUpdate.addAll(setAccountsUpdate);
            update lstAccountsUpdate;
        }
    }
    
    /*
    *   Method Name :   updateAccountBillingAddress
    *   Description :   This is a static method. This method used to update Account's Billing Address using Primary Address
    *   Parameter   :   Account Record, Address Record
    *   Return Type :   N/A
    */
    public static Account updateAccountBillingAddress(Account AccountRecord, Address__c addressRecord){
        // combining street lines
        String street = '';
        if(addressRecord.Address_line1__c != null)
            street = addressRecord.Address_line1__c;
        if(addressRecord.Address_line2__c != null)
            street += '\r\n' + addressRecord.Address_line2__c;
        if(addressRecord.Address_line3__c != null)
            street += '\r\n' + addressRecord.Address_line3__c;
        if(addressRecord.Address_line4__c != null)
            street += '\r\n' + addressRecord.Address_line4__c;
            
        AccountRecord.BillingStreet     =   street;
        AccountRecord.BillingCity       =   addressRecord.City__c;
        AccountRecord.BillingCountry    =   addressRecord.Country__c;
        AccountRecord.County__c         =   addressRecord.County__c;
        AccountRecord.BillingState      =   addressRecord.State__c;
        AccountRecord.BillingPostalCode =   addressRecord.Zip__c;
        AccountRecord.Validation_Status_Code__c =   addressRecord.Validation_Status_Code__c;
        AccountRecord.Validation_Status__c =   addressRecord.Validation_Status__c;
        AccountRecord.Job_Token__c =   addressRecord.Job_Token__c;
        return AccountRecord;
    }
}