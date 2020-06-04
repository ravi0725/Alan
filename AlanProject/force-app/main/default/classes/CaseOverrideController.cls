/*****************************************************************************************
    Name    : CaseOverrideController 
    Desc    : Used to implement show sales ops comments to reps when they are trying to create cases..
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Suresh Banbu            3/16/2017          Created
******************************************************************************************/
public class CaseOverrideController {
    public Boolean ErrorPopup {get;set;}
    public Boolean isGCCMSupportCase {get;set;}
    public Boolean isPlancalInternalCase {get;set;}
    public String messagetoUser {get;set;}
    public Map<String, String> mapURLParam {get;set;}
    public String urlEncoded {get;set;}
    
    /**
     * Method name  : CaseOverrideController
     * Description  : Constructor of the Controller class - Initializes all the variables.
     * Return Type  : Void
     * Parameter    : StandardController
     **/
    public CaseOverrideController(ApexPages.StandardController controller) {
        isGCCMSupportCase = false;
        isPlancalInternalCase = false;
        mapURLParam = new Map<String, String>();
        mapURLParam = ApexPages.currentPage().getParameters();
        
        if(mapURLParam.containsKey('save_new')){
            mapURLParam.remove('save_new');
        }
        
        urlEncoded = '/500/e?';
        for(String param: mapURLParam.keySet()){
            system.debug(' Key: '+param+' Value : '+mapURLParam.get(param));
            if(param == 'retURL'){
                String encodedStr = EncodingUtil.urlEncode(mapURLParam.get(param), 'UTF-8');
                system.debug('encodedStr ===>'+encodedStr);
                urlEncoded += param +'='+ encodedStr + '&';
            }
            else{
                urlEncoded += param +'='+ mapURLParam.get(param) + '&';
            }
            
            //Default shipping address for Michael Attard(MEPNA)
            if(param == 'def_account_id' && Label.MEPNA_Default_Shipping_Address_Users.contains(userinfo.getName())){
                for(Address__c add : [select ID,Name from Address__c where Ship_To__c = true and Account__c =: mapURLParam.get(param) and Primary__c = true]){
                    urlEncoded += 'CF' + Label.MEPNA_Shipping_Address + '=' + EncodingUtil.urlEncode(add.Name, 'UTF-8') + '&';
                    urlEncoded += Label.MEPNA_Shipping_Address + '_lkid=' + add.Id + '&';
                }
            }
        }
        
        if([select ID,Division__c from User where Id =: UserInfo.getUserId()].Division__c == 'TAP'){
            urlEncoded += 'RecordType=' + Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('TAP - Customer Support').getRecordTypeId() + '&';
            urlEncoded += 'isWsVw=true&';
            urlEncoded += 'BusinessHours_lkid=' + Label.TAP_Business_Hours + '&';
            urlEncoded += 'BusinessHours=TAP - Business Hours&';
        }
        urlEncoded = urlEncoded.removeEnd('&');
        
        
        
        system.debug('urlEncoded ========>'+urlEncoded);
    }
    
    public PageReference Initialize(){
        try{
            if(ApexPages.CurrentPage().getParameters().get('RecordType') != null){
                if(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId() == ApexPages.CurrentPage().getParameters().get('RecordType')){
                    // ONLY for GCCM - Support Case Record Type
                    isGCCMSupportCase = true;
                }
                else if(Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Case (Plancal Internal) Record Type').getRecordTypeId() == ApexPages.CurrentPage().getParameters().get('RecordType')){
                    isPlancalInternalCase = true;
                }
                else{
                    isGCCMSupportCase = false;
                    isPlancalInternalCase = false;
                }
            }
            else{
                Schema.DescribeSObjectResult cseDescribe = Case.SObjectType.getDescribe();
                //Integer avlRecordTypeCount = 0;
                //Map<String, Id> mapRecordTypes = new Map<String, Id>();
                Id defaultRecordTypeId = null;
                for (Schema.RecordTypeInfo recordType : cseDescribe.getRecordTypeInfos()) {
                    system.debug('recordType =========>>'+recordType);
                    /*
                    if(recordType.isAvailable() && !recordType.isMaster()){ // Not Master
                        avlRecordTypeCount++;
                        mapRecordTypes.put(recordType.getName(), recordType.getRecordTypeId());
                    }
                    */
                    if (recordType.isDefaultRecordTypeMapping()) {
                        system.debug('recordType NAME =========>>'+recordType.Name);
                        defaultRecordTypeId = recordType.getRecordTypeId();
                    }
                }

                if(defaultRecordTypeId == Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('GCCM - Support Case Record Type').getRecordTypeId()){
                    isGCCMSupportCase = true;
                }
                else if(defaultRecordTypeId == Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Case (Plancal Internal) Record Type').getRecordTypeId()){
                    isPlancalInternalCase = true;
                }
            }
            
            if(ApexPages.CurrentPage().getParameters().get('def_account_id') != null && isGCCMSupportCase){
                Account acc = [SELECT Id, Name, Sales_Ops_Comments__c, Agreement_Comments__c FROM Account WHERE Id =: ApexPages.CurrentPage().getParameters().get('def_account_id') Limit 1];
                system.debug('acc ==>'+acc);
                if(acc != null && (acc.Sales_Ops_Comments__c != null || string.isNotBlank(acc.Agreement_Comments__c))){
                    ErrorPopup = true;
                    messagetoUser = (string.isNotBlank(acc.Sales_Ops_Comments__c) ?'<b>Sales Ops Comments : </b><br/>'+acc.Sales_Ops_Comments__c+'<br/><br/>':'') + (string.isNotBlank(acc.Agreement_Comments__c) ? '<b>Agreement Comments : </b><br/>'+acc.Agreement_Comments__c : '');
                }
                else{
                    system.debug(' Redirection Entry..................');
                    PageReference pg = new PageReference(urlEncoded);
                    pg.getParameters().put('nooverride', '1');
                    pg.getParameters().put('sfdc.override', '0');
                    pg.setRedirect(true);
                    return pg;
                }
            }
            else if(isPlancalInternalCase){ // This condition will remove "Assign using active assignment rules" for MEP Internal cases only on Creation
                PageReference pg = new PageReference(urlEncoded);
                pg.getParameters().put('nooverride', '1');
                pg.getParameters().put('sfdc.override', '0');
                pg.getParameters().put('cas21', '1');
                pg.setRedirect(true);
                return pg;
            }
            else{ // No Account Id is found in URL
                system.debug(' Redirection Entry..................');
                PageReference pg = new PageReference(urlEncoded);
                pg.getParameters().put('nooverride', '1');
                pg.getParameters().put('sfdc.override', '0');
                pg.setRedirect(true);
                return pg;
            }
        }
        catch(Exception exp){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, exp.getStackTraceString());
            ApexPages.addMessage(msg);
        }
        return null;
    }

    // This method used to redirect to case creation page
    public PageReference continueCaseCreation(){
        PageReference pRef = new PageReference(urlEncoded);
        pRef.getParameters().put('nooverride', '1');
        pRef.getParameters().put('sfdc.override', '0');
        pRef.setRedirect(true);
        return pRef;
    }
}