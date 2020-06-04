/***
Class Name : DevelopmentHandler
Desciption : Handler class for Development trigger
Date       : 27-Sep-2016
Author     : Suresh Babu Murugan
**/
public class DevelopmentHandler {
    public static Map<String, Integer> launchControl;
    // Static initialize
    static {
        resetLaunchControl();
    }
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('JIRASyncProcess',0);
        launchControl.put('prepareJIRASyncData', 0);
        launchControl.put('SendEmailtoSFDCOwner', 0);
    }
    
    // This method is used to update values in SFDC to sync with JIRA
    public static void prepareJIRASyncData(List<Development__c> lstNewDevs, Map<Id, Development__c> mapDevs, Boolean isInsert, Boolean isUpdate){
        if(launchControl.get('prepareJIRASyncData') < 1){
            launchControl.put('prepareJIRASyncData',launchControl.get('prepareJIRASyncData') + 1);
            Set<Id> devIDs = new Set<Id>();
            Set<Id> UserIDs = new Set<Id>();
            Set<Id> TechOpsIDs = new Set<Id>();
            Set<Id> CaseIDs = new Set<Id>();
            
            for(Development__c dv: lstNewDevs){
                devIDs.add(dv.Id);
                UserIDs.add(dv.OwnerId);
                UserIDs.add(dv.CreatedById);
                UserIDs.add(dv.LastModifiedById);
                
                if(dv.Support_Case_1__c != null)
                    CaseIDs.add(dv.Support_Case_1__c);
                if(dv.QA_Tech_Ops__c != null)
                    TechOpsIDs.add(dv.QA_Tech_Ops__c);
            }
            
            List<Development__History> lstDevHistories = [SELECT ParentId, OldValue, NewValue, Field, CreatedDate, CreatedBy.Name, Id FROM Development__History WHERE ParentId IN : devIDs ORDER BY CReatedDate DESC limit 3];
            Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Name, Division__c FROM User limit 49999]);
            Map<Id, TechOps__c> mapTechOps = new Map<Id, TechOps__c>([SELECT Id, Name FROM TechOps__c WHERE Id IN : TechOpsIDs]);
            Map<Id, Case> mapCases = new Map<Id, Case>([SELECT Id, CaseNumber FROM Case WHERE Id IN : CaseIDs]);
            Map<String, JIRA_Status_Mapping__c> mapJIRAStatusCodes = JIRA_Status_Mapping__c.getAll();
            
            for(Development__c dev: lstNewDevs){
                String JIRASysINFO = '';
                if(dev.Platform__c != null){
                    JIRASysINFO += 'Platform : '+ dev.Platform__c + '\n';
                }
                if(dev.Module__c != null){
                    JIRASysINFO += 'Module : '+ dev.Module__c + '\n';
                }
                if(dev.AppServer__c != null){
                    JIRASysINFO += 'AppServer : '+ dev.AppServer__c + '\n';
                }
                if(dev.DBServer__c != null){
                    JIRASysINFO += 'DB Type : '+ dev.DBServer__c + '\n';
                }
                if(dev.Internal_URL_Reproduced_In__c != null){
                    JIRASysINFO += 'Internal URL Reproduced In : '+ dev.Internal_URL_Reproduced_In__c + '\n';
                }
                if(dev.TEST_Deploy_URL__c != null){
                    JIRASysINFO += 'TEST Deploy URL : '+ dev.TEST_Deploy_URL__c + '\n';
                }
                if(dev.PROD_Deploy_URL__c != null){
                    JIRASysINFO += 'PROD Deploy URL : '+ dev.PROD_Deploy_URL__c + '\n';
                }
                if(dev.Support_Case_1__c != null){
                    JIRASysINFO += 'Support Case Link : '+ mapCases.get(dev.Support_Case_1__c).CaseNumber + ' : ' + 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + dev.Support_Case_1__c + '\n';
                }
                if(dev.QA_Tech_Ops__c  != null){
                    JIRASysINFO += 'QA Tech Ops Link : '+ mapTechOps.get(dev.QA_Tech_Ops__c).Name + ' : '+ 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + dev.QA_Tech_Ops__c  + '\n';
                }
                
                dev.JIRA_System_Info__c = (JIRASysINFO != '' ? JIRASysINFO : null);
                if(dev.Id != null)
                    dev.SFDC_Reference__c = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + dev.Id;
                
                
                // Update JIRA Assigned User to SFDC Owner based on the User mapping provided
                List<JIRA_Development_User_Mapping__c> lstUMapping = [SELECT Id, Name, JIRA_User_Name__c, Role_Department__c, SFDC_Name__c, SFDC_User_ID__c, SFDC_User_Name__c FROM JIRA_Development_User_Mapping__c limit 49999];
                Map<String, JIRA_Development_User_Mapping__c> mapAllUserMappings = new Map<String, JIRA_Development_User_Mapping__c>();
                Map<String, Id> mapJIRAUserNames = new Map<String, Id>();
                Map<String, String> mapJIRAKey = new Map<String, String>();

                for(JIRA_Development_User_Mapping__c uMapping : lstUMapping){
                    if(uMapping.Name != 'Unassigned')
                        uMapping.Name = uMapping.Name.toLowerCase();
                    mapAllUserMappings.put(uMapping.Name, uMapping);
                    mapJIRAUserNames.put(uMapping.JIRA_User_Name__c, uMapping.SFDC_User_ID__c);
                    mapJIRAKey.put(uMapping.JIRA_User_Name__c, uMapping.Name);
                }
                
                /* update JIRA Selectlist(Multiple Choices) value to SFDC with supported picklist format */
                if(dev.Category__c != null)
                    dev.Category__c = dev.Category__c.replaceAll('\\[', '').replaceAll('\\]', '');
                if(dev.Engineering_Blocked__c != null)
                    dev.Engineering_Blocked__c = dev.Engineering_Blocked__c.replaceAll('\\[', '').replaceAll('\\]', '');
                /***/

                if(isInsert){
                    // Empty all values when cloning.
                    dev.JIRA_Issue_ID__c = null;
                    dev.JIRA_Status__c = null;
                    dev.JIRA_Issue_Assigned_User__c = null;
                    dev.SFDC_JIRA_Owner__c = null;
                    dev.SFDC_Reference__c = null;
                    dev.JIRA_Code_Fix_Information__c = null;
                    dev.JIRA_Description__c = null;
                    dev.SFDC_History__c = null;
                    dev.SFDC_CreatedBy_User__c = null;
                    dev.Notes_and_Attachment_Links__c = null;
                    
                    
                    Boolean JIRACodeFixUpdated = false;
                    Boolean JIRADescriptionUpdated = false;
                    
                    if(dev.Code_Fix_Information__c != null){
                        system.debug(' DESCRIPTION ===================>>>>'+dev.Code_Fix_Information__c);
                        String WIKIFormatted = dev.Code_Fix_Information__c.replaceAll('<br>', '\n');
                        WIKIFormatted = WIKIFormatted.replaceAll('(\\<[^\\>]*\\>)', '');
                        WIKIFormatted = WIKIFormatted.unescapeHtml4();
                        
                        dev.JIRA_Code_Fix_Information__c = WIKIFormatted;
                        JIRACodeFixUpdated = true;
                        system.debug(' WIKI Formatted : ====>'+WIKIFormatted);
                    }
                    
                    if(dev.Description__c != null){
                        system.debug(' DESCRIPTION ===================>>>>'+dev.Description__c);
                        String WIKIFormatted = JIRA_HTMLtoWIKIConverter.convertHTMLtoWIKI(dev.Description__c);
                        
                        dev.JIRA_Description__c = WIKIFormatted.unescapeHtml4();
                        JIRADescriptionUpdated = true;
                        system.debug(' WIKI Formatted : ====>'+WIKIFormatted);
                    }
                    
                    if(dev.JIRA_Code_Fix_Information__c != null && !JIRACodeFixUpdated){
                        system.debug(' ON JIRA Code Fix Update ==========================================================>>>'+dev.JIRA_Code_Fix_Information__c);
                        String HTMLFormatted = JIRA_HTMLtoWIKIConverter.convertWIKItoHTML(dev.JIRA_Code_Fix_Information__c);
                        
                        dev.Code_Fix_Information__c = HTMLFormatted;
                        system.debug(' Code fix HTML formatted ========>'+HTMLFormatted);
                    }
                    
                    if(dev.JIRA_Description__c != null && !JIRADescriptionUpdated){
                        system.debug(' ON JIRA Description ==========================================================>>>'+dev.JIRA_Description__c);
                        String HTMLFormatted = JIRA_HTMLtoWIKIConverter.convertWIKItoHTML(dev.JIRA_Description__c);
                        
                        dev.Description__c = HTMLFormatted;
                        system.debug(' Description HTML formatted ========>'+HTMLFormatted);
                    }
                    
                    dev.SFDC_History__c = 'Assignee (SFDC Owner): ' + system.UserInfo.getName()  + '\n' +
                        'Created By User (SFDC): ' + system.UserInfo.getName() + '\n' +
                        'Last Modified By User (SFDC): ' + system.UserInfo.getName() + '\n';
                    system.debug(' History value final -->'+dev.SFDC_History__c);
                    
                    // If the JIRA Owner was updated
                    if(dev.JIRA_Issue_Assigned_User__c != null){
                        dev.SFDC_JIRA_Owner__c = dev.JIRA_Issue_Assigned_User__c.toLowerCase();
                        if(mapJIRAUserNames.containsKey(dev.JIRA_Issue_Assigned_User__c)){
                            dev.OwnerId = mapJIRAUserNames.get(dev.JIRA_Issue_Assigned_User__c); // Update Salesforce User ID
                        }
                    }
                    else if(dev.JIRA_Issue_Assigned_User__c == null){
                        dev.JIRA_Issue_Assigned_User__c = 'Unassigned';
                    }
                    
                    if(mapUsers.get(system.UserInfo.getUserId()).Division__c == 'RE&WS'){
                        User systemAssigned = [SELECT Id, Name FROM User WHERE Name = 'System Assigned' limit 1];
                        dev.OwnerId = systemAssigned.Id;
                        
                        dev.SFDC_History__c = 'Assignee (SFDC Owner): ' + systemAssigned.Name  + '\n' +
                            'Created By User (SFDC): ' + system.UserInfo.getName() + '\n' +
                            'Last Modified By User (SFDC): ' + system.UserInfo.getName() + '\n';
                        system.debug(' History value final -->'+dev.SFDC_History__c);
                        
                    }
                    
                    system.debug('dev.OwnerId =======================>>>>'+dev.OwnerId);
                    // Update Owner between JIRA and SFDC
                    if(dev.OwnerId != null){
                        Boolean JIRAOwnerUpdated = false;
                        for(JIRA_Development_User_Mapping__c uMapping : mapAllUserMappings.values()){
                            if(uMapping.SFDC_User_ID__c == dev.OwnerId){
                                if(uMapping.Name == 'Unassigned'){
                                    dev.SFDC_JIRA_Owner__c = uMapping.Name;
                                    dev.JIRA_Issue_Assigned_User__c = uMapping.Name;
                                }
                                else{
                                    dev.SFDC_JIRA_Owner__c = uMapping.Name.toLowerCase();
                                    dev.JIRA_Issue_Assigned_User__c = uMapping.Name.toLowerCase();
                                }
                                JIRAOwnerUpdated = true;
                                break;
                            }
                        }
                        
                        // Current SFDC owner does not have JIRA access or not included in mapping 
                        if(!JIRAOwnerUpdated){
                            dev.SFDC_JIRA_Owner__c = 'Unassigned';
                            dev.JIRA_Issue_Assigned_User__c = 'Unassigned';
                        }
                    }
                    
                    // Update CreatedBy User's JIRA Username to map to JIRA
                    Boolean JIRACreatedByUpdated = false;
                    for(JIRA_Development_User_Mapping__c uMapping : mapAllUserMappings.values()){
                        if(uMapping.SFDC_User_ID__c == system.UserInfo.getUserId().substring(0, 15)){
                            dev.SFDC_CreatedBy_User__c = uMapping.Name.toLowerCase();
                            JIRACreatedByUpdated = true;
                            break;
                        }
                    }
                    
                    // Current SFDC CreatedBy user does not have JIRA access or not included in mapping Reporter will be SalesforceConnector
                    if(!JIRACreatedByUpdated){
                        dev.SFDC_CreatedBy_User__c = 'salesforceconnector';
                    }
                    
                    if(dev.JIRA_Status__c != null){
                        if(mapJIRAStatusCodes.containsKey('JIRA-'+dev.JIRA_Status__c)){
                            if(mapJIRAStatusCodes.get('JIRA-'+dev.JIRA_Status__c).Is_Status_Mapping__c){
                                dev.Status__c = mapJIRAStatusCodes.get('JIRA-'+dev.JIRA_Status__c).Status_Name__c;
                            }
                        }
                    }
                }
                else if(isUpdate){
                    Boolean JIRACodeFixUpdated = false;
                    Boolean JIRADescriptionUpdated = false;
                    
                    // Prevent update if JIRA sync process is going on
                    if(dev.JIRA_Sync_Processing__c && UserInfo.getName() != 'TFS API User'){
                        dev.addError('JIRA Sync process is going on.. Please refresh or try again');
                    }
                    
                    Set<String> lstNotSyncStatuses = new Set<String>(); // This set contains SFDC statuses which is not sync with JRIA
	                for(String sfMapping : mapJIRAStatusCodes.keySet()){
	                	if(sfMapping.startsWith('SFDC-') && mapJIRAStatusCodes.get(sfMapping).Is_Status_Mapping__c){
	                		lstNotSyncStatuses.add(sfMapping.removeStart('SFDC-'));
	                	}
	                }
                    
                    system.debug(' :::::::::::::: Status__c>'+ dev.Status__c +' :::: '+ mapDevs.get(dev.Id).Status__c + ' ::::' + lstNotSyncStatuses.contains(dev.Status__c));
                    system.debug(' :::::::::::::: Description__c>'+ dev.Description__c +' :::: '+ mapDevs.get(dev.Id).Description__c);
                    system.debug(' :::::::::::::: Code_Fix_Information__c>'+ dev.Code_Fix_Information__c +' :::: '+ mapDevs.get(dev.Id).Code_Fix_Information__c);
                    system.debug(' :::::::::::::: Subject__c>'+ dev.Subject__c +' :::: '+ mapDevs.get(dev.Id).Subject__c);
                    system.debug(' :::::::::::::: Client_Name__c>'+ dev.Client_Name__c +' :::: '+ mapDevs.get(dev.Id).Client_Name__c);
                    system.debug(' :::::::::::::: Internal_Priority__c>'+ dev.Internal_Priority__c +' :::: '+ mapDevs.get(dev.Id).Internal_Priority__c);
                    system.debug(' :::::::::::::: Rank__c>'+ dev.Rank__c +' :::: '+ mapDevs.get(dev.Id).Rank__c);
                    system.debug(' :::::::::::::: Est_Delivery_Date__c>'+ dev.Est_Delivery_Date__c +' :::: '+ mapDevs.get(dev.Id).Est_Delivery_Date__c);
                    system.debug(' :::::::::::::: Release_Found_In__c >'+ dev.Release_Found_In__c +' :::: '+ mapDevs.get(dev.Id).Release_Found_In__c);
                    system.debug(' :::::::::::::: Category__c>'+ dev.Category__c +' :::: '+ mapDevs.get(dev.Id).Category__c);
                    system.debug(' :::::::::::::: JIRA_System_Info__c>'+ dev.JIRA_System_Info__c +' :::: '+ mapDevs.get(dev.Id).JIRA_System_Info__c);
                    system.debug(' :::::::::::::: SFDC_Reference__c>'+ dev.SFDC_Reference__c +' :::: '+ mapDevs.get(dev.Id).SFDC_Reference__c);
                    system.debug(' :::::::::::::: SFDC_History__c>'+ dev.SFDC_History__c +' :::: '+ mapDevs.get(dev.Id).SFDC_History__c);
                    system.debug(' :::::::::::::: SFDC_JIRA_Owner__c>'+ dev.SFDC_JIRA_Owner__c +' :::: '+ mapDevs.get(dev.Id).SFDC_JIRA_Owner__c);
                    system.debug(' :::::::::::::: SFDC_CreatedBy_User__c>'+ dev.SFDC_CreatedBy_User__c +' :::: '+ mapDevs.get(dev.Id).SFDC_CreatedBy_User__c);
                    system.debug(' :::::::::::::: Business_Use_Case__c>'+ dev.Business_Use_Case__c +' :::: '+ mapDevs.get(dev.Id).Business_Use_Case__c);
                    system.debug(' :::::::::::::: Branch_1__c>'+ dev.Branch_1__c +' :::: '+ mapDevs.get(dev.Id).Branch_1__c);
                    system.debug(' :::::::::::::: Branch_2__c>'+ dev.Branch_2__c +' :::: '+ mapDevs.get(dev.Id).Branch_2__c);
                    system.debug(' :::::::::::::: Branch_3__c>'+ dev.Branch_3__c +' :::: '+ mapDevs.get(dev.Id).Branch_3__c);
                    system.debug(' :::::::::::::: Branch_4__c>'+ dev.Branch_4__c +' :::: '+ mapDevs.get(dev.Id).Branch_4__c);
                    system.debug(' :::::::::::::: Branch_Other__c>'+ dev.Branch_Other__c +' :::: '+ mapDevs.get(dev.Id).Branch_Other__c);
                    system.debug(' :::::::::::::: Deploy_to_All_Clients__c>'+ dev.Deploy_to_All_Clients__c +' :::: '+ mapDevs.get(dev.Id).Deploy_to_All_Clients__c);
                    system.debug(' :::::::::::::: Notes_and_Attachment_Links__c>'+ dev.Notes_and_Attachment_Links__c +' :::: '+ mapDevs.get(dev.Id).Notes_and_Attachment_Links__c);
                    system.debug(' :::::::::::::: Check_In_Date__c>'+ dev.Check_In_Date__c +' :::: '+ mapDevs.get(dev.Id).Check_In_Date__c);
                    system.debug(' :::::::::::::: Tech_Op_Info__c>'+ dev.Tech_Op_Info__c +' :::: '+ mapDevs.get(dev.Id).Tech_Op_Info__c);
                    system.debug(' :::::::::::::: Target_Release__c>'+ dev.Target_Release__c +' :::: '+ mapDevs.get(dev.Id).Target_Release__c);

                    system.debug(' :::::::::::::: BEFORE JIRA_Sync_Processing__c >'+ dev.JIRA_Sync_Processing__c +' :::: '+ mapDevs.get(dev.Id).JIRA_Sync_Processing__c);

                    // We should prevent editing record again when sync is going on, olny for Two way mapped fields.
                    if(dev.JIRA_Issue_ID__c != null && UserInfo.getName() != 'TFS API User' &&
                        ((dev.Status__c != null && dev.Status__c != mapDevs.get(dev.Id).Status__c && lstNotSyncStatuses.contains(dev.Status__c)) || 
                        (dev.Description__c != null && dev.Description__c != mapDevs.get(dev.Id).Description__c) ||
                        (dev.Code_Fix_Information__c != null && dev.Code_Fix_Information__c != mapDevs.get(dev.Id).Code_Fix_Information__c) ||
                        (dev.Subject__c != null && dev.Subject__c != mapDevs.get(dev.Id).Subject__c) ||
                        (dev.Internal_Priority__c != null && dev.Internal_Priority__c != mapDevs.get(dev.Id).Internal_Priority__c) ||
                        (dev.Category__c != null && dev.Category__c != mapDevs.get(dev.Id).Category__c) ||
                        (dev.Business_Use_Case__c != null && dev.Business_Use_Case__c != mapDevs.get(dev.Id).Business_Use_Case__c) ||
                        (dev.Branch_1__c != null && dev.Branch_1__c != mapDevs.get(dev.Id).Branch_1__c) ||
                        (dev.Branch_2__c != null && dev.Branch_2__c != mapDevs.get(dev.Id).Branch_2__c) ||
                        (dev.Branch_3__c != null && dev.Branch_3__c != mapDevs.get(dev.Id).Branch_3__c) ||
                        (dev.Branch_4__c != null && dev.Branch_4__c != mapDevs.get(dev.Id).Branch_4__c) ||
                        (dev.Branch_Other__c != null && dev.Branch_Other__c != mapDevs.get(dev.Id).Branch_Other__c) ||
                        (dev.Deploy_to_All_Clients__c != null && dev.Deploy_to_All_Clients__c != mapDevs.get(dev.Id).Deploy_to_All_Clients__c) ||
                        (dev.Check_In_Date__c != null && dev.Check_In_Date__c != mapDevs.get(dev.Id).Check_In_Date__c) ||
                        (dev.Release_Found_In__c != null && dev.Release_Found_In__c != mapDevs.get(dev.Id).Release_Found_In__c) ||
                        (dev.Tech_Op_Info__c != null && dev.Tech_Op_Info__c != mapDevs.get(dev.Id).Tech_Op_Info__c) ||
                        (dev.Generic_Subject__c != null && dev.Generic_Subject__c != mapDevs.get(dev.Id).Generic_Subject__c) ||
                        (dev.Steps_to_Reproduce__c != null && dev.Steps_to_Reproduce__c != mapDevs.get(dev.Id).Steps_to_Reproduce__c) ||
                        (dev.Error_Displayed_to_User__c != null && dev.Error_Displayed_to_User__c != mapDevs.get(dev.Id).Error_Displayed_to_User__c) ||
                        (dev.To_Sustaining__c != null && dev.To_Sustaining__c != mapDevs.get(dev.Id).To_Sustaining__c) ||
                        (dev.Target_Release__c != null && dev.Target_Release__c != mapDevs.get(dev.Id).Target_Release__c))){
                        
                        system.debug('Updating JIRA Sync stop checkbox ..............');
                        dev.JIRA_Sync_Processing__c = true; // Restrict update to JIRA if sync is in progress
                    }
                    system.debug(' :::::::::::::: AFTER JIRA_Sync_Processing__c >'+ dev.JIRA_Sync_Processing__c);
                    
                    if(dev.Code_Fix_Information__c != null && dev.Code_Fix_Information__c != mapDevs.get(dev.Id).Code_Fix_Information__c){
                        system.debug(' DESCRIPTION ===================>>>>'+dev.Code_Fix_Information__c);
                        String cFixStripped = dev.Code_Fix_Information__c.stripHtmlTags();
                        String oldcFixStripped = null;
                        if(mapDevs.get(dev.Id).Code_Fix_Information__c != null){
                            oldcFixStripped = mapDevs.get(dev.Id).Code_Fix_Information__c.stripHtmlTags();
                        }
                        
                        if(cFixStripped != oldcFixStripped){
                            //String WIKIFormatted = JIRA_HTMLtoWIKIConverter.convertHTMLtoWIKI(dev.Code_Fix_Information__c);
                            String WIKIFormatted = dev.Code_Fix_Information__c.replaceAll('<br>', '\n');
                            WIKIFormatted = WIKIFormatted.replaceAll('(\\<[^\\>]*\\>)', '');
                            WIKIFormatted = WIKIFormatted.unescapeHtml4();
                            
                            dev.JIRA_Code_Fix_Information__c = WIKIFormatted;
                            JIRACodeFixUpdated = true;
                            system.debug(' WIKI Formatted : ====>'+WIKIFormatted);
                        }
                    }
                    
                    if(dev.Description__c != null && dev.Description__c != mapDevs.get(dev.Id).Description__c){
                        system.debug(' DESCRIPTION ===================>>>>'+dev.Description__c);
                        String descStripped = dev.Description__c.stripHtmlTags();
                        String oldDescStripped = null;
                        if(mapDevs.get(dev.Id).Description__c != null){
                            oldDescStripped = mapDevs.get(dev.Id).Description__c.stripHtmlTags();
                        }
                        
                        if(descStripped != oldDescStripped){
                            String WIKIFormatted = JIRA_HTMLtoWIKIConverter.convertHTMLtoWIKI(dev.Description__c);
                            
                            dev.JIRA_Description__c = WIKIFormatted.unescapeHtml4();
                            JIRADescriptionUpdated = true;
                            system.debug(' WIKI Formatted : ====>'+WIKIFormatted);
                        }
                    }
                    
                    if(dev.JIRA_Code_Fix_Information__c != null && dev.JIRA_Code_Fix_Information__c != mapDevs.get(dev.Id).JIRA_Code_Fix_Information__c && !JIRACodeFixUpdated){
                        system.debug(' ON JIRA Code Fix Update ==========================================================>>>'+dev.JIRA_Code_Fix_Information__c);
                        String cFixStripped = dev.JIRA_Code_Fix_Information__c.stripHtmlTags();
                        String oldcFixStripped = null;
                        if(mapDevs.get(dev.Id).JIRA_Code_Fix_Information__c != null){
                            oldcFixStripped = mapDevs.get(dev.Id).JIRA_Code_Fix_Information__c.stripHtmlTags();
                        }
                        
                        if(cFixStripped != oldcFixStripped){
                            String HTMLFormatted = JIRA_HTMLtoWIKIConverter.convertWIKItoHTML(dev.JIRA_Code_Fix_Information__c);
                            
                            dev.Code_Fix_Information__c = HTMLFormatted;
                            system.debug(' Code fix HTML formatted ========>'+HTMLFormatted);
                        }
                    }
                    else if(dev.JIRA_Code_Fix_Information__c == null && dev.JIRA_Issue_ID__c != null){
                        dev.Code_Fix_Information__c = null;
                    }
                    
                    if(dev.JIRA_Description__c != null && dev.JIRA_Description__c != mapDevs.get(dev.Id).JIRA_Description__c && !JIRADescriptionUpdated){
                        system.debug(' ON JIRA Description ==========================================================>>>'+dev.JIRA_Description__c);
                        String jDescStripped = dev.JIRA_Description__c.stripHtmlTags();
                        String oldjDescStripped = null;
                        if(mapDevs.get(dev.Id).JIRA_Description__c != null){
                            oldjDescStripped = mapDevs.get(dev.Id).JIRA_Description__c.stripHtmlTags();
                        }
                        
                        if(jDescStripped != oldjDescStripped){
                            String HTMLFormatted = JIRA_HTMLtoWIKIConverter.convertWIKItoHTML(dev.JIRA_Description__c);
                            
                            dev.Description__c = HTMLFormatted;
                            system.debug(' Description HTML formatted ========>'+HTMLFormatted);
                        }
                    }
                    else if(dev.JIRA_Description__c == null && dev.JIRA_Issue_ID__c != null){
                        dev.Description__c = null;
                    }
                    
                    if(dev.Description__c == null){
                        dev.JIRA_Description__c = null;
                    }
                    
                    if(dev.Code_Fix_Information__c == null){
                        dev.JIRA_Code_Fix_Information__c = null;
                    }
                    
                    
                    if(dev.JIRA_Status__c != null && dev.JIRA_Status__c != mapDevs.get(dev.Id).JIRA_Status__c){
                        if(mapJIRAStatusCodes.containsKey('JIRA-'+dev.JIRA_Status__c)){
                            if(mapJIRAStatusCodes.get('JIRA-'+dev.JIRA_Status__c).Is_Status_Mapping__c){
                                dev.Status__c = mapJIRAStatusCodes.get('JIRA-'+dev.JIRA_Status__c).Status_Name__c;
                            }
                        }
                    }
                    
                    system.debug(' dev.OwnerId ==================>>>>>>>>>>>>>>>>'+dev.OwnerId);
                    
                    // If the SFDC Owner was changed
                    if(dev.OwnerId != mapDevs.get(dev.Id).OwnerId){
                        Boolean JIRAOwnerUpdated = false;
                        for(JIRA_Development_User_Mapping__c uMapping : mapAllUserMappings.values()){
                            if(uMapping.SFDC_User_ID__c == dev.OwnerId){
                                system.debug(' uMapping.Name ==============>'+uMapping.Name);
                                if(uMapping.Name == 'Unassigned'){
                                    dev.SFDC_JIRA_Owner__c = uMapping.Name;
                                    dev.JIRA_Issue_Assigned_User__c = uMapping.Name;
                                }
                                else{
                                    dev.SFDC_JIRA_Owner__c = uMapping.Name.toLowerCase();
                                    //dev.JIRA_Issue_Assigned_User__c = uMapping.Name.toLowerCase();
                                    dev.JIRA_Issue_Assigned_User__c = uMapping.JIRA_User_Name__c; // Update with JIRA User Name
                                }
                                
                                system.debug(' update JIRA Owner ==========>>');
                                JIRAOwnerUpdated = true;
                                break;
                            }
                        }
                        
                        // Current SFDC owner does not have JIRA access or not included in mapping 
                        if(!JIRAOwnerUpdated){
                            dev.SFDC_JIRA_Owner__c = 'Unassigned';
                            dev.JIRA_Issue_Assigned_User__c = 'Unassigned';
                        }
                    }
                    
                    system.debug('JIRA_Issue_Assigned_User__c =======-------------->'+dev.JIRA_Issue_Assigned_User__c);
                    
                    // If the JIRA Owner was updated
                    if(dev.JIRA_Issue_Assigned_User__c != mapDevs.get(dev.Id).JIRA_Issue_Assigned_User__c && dev.JIRA_Issue_Assigned_User__c != 'Unassigned'){ // dev.JIRA_Issue_Assigned_User__c != null
                        if(dev.JIRA_Issue_Assigned_User__c == null){
                            dev.JIRA_Issue_Assigned_User__c = 'Unassigned';
                            dev.SFDC_JIRA_Owner__c = 'Unassigned';
                        }
                        else{
                            dev.SFDC_JIRA_Owner__c = (mapJIRAKey.containsKey(dev.JIRA_Issue_Assigned_User__c) ? mapJIRAKey.get(dev.JIRA_Issue_Assigned_User__c) : null);
                        }
                        if(mapJIRAUserNames.containsKey(dev.JIRA_Issue_Assigned_User__c)){
                            dev.OwnerId = mapJIRAUserNames.get(dev.JIRA_Issue_Assigned_User__c); // Update Salesforce User ID
                        }
                    }
                    
                    dev.SFDC_History__c = 'Assignee (SFDC Owner): ' + mapUsers.get(dev.OwnerId).Name + '\n' +
                        'Created By User (SFDC): ' + mapUsers.get(dev.CreatedById).Name + '' + '\n' +
                        'Last Modified By User (SFDC): ' + system.UserInfo.getName() + '\n';
                    system.debug(' History value final -->'+dev.SFDC_History__c);
                    
                    system.debug(' SFDC_JIRA_Owner__c =============================>>'+dev.SFDC_JIRA_Owner__c);
                    system.debug(' JIRA_Issue_Assigned_User__c =============================>>'+dev.JIRA_Issue_Assigned_User__c);
                    
                    // Update CreatedBy User's JIRA Username to map to JIRA
                    Boolean JIRACreatedByUpdated = false;
                    for(JIRA_Development_User_Mapping__c uMapping : mapAllUserMappings.values()){
                        if(uMapping.SFDC_User_ID__c == dev.CreatedById){
                            dev.SFDC_CreatedBy_User__c = uMapping.Name.toLowerCase();
                            JIRACreatedByUpdated = true;
                            break;
                        }
                    }
                    
                    // Current SFDC CreatedBy user does not have JIRA access or not included in mapping Reporter will be SalesforceConnector
                    if(!JIRACreatedByUpdated){
                        dev.SFDC_CreatedBy_User__c = 'salesforceconnector';
                    }
                }
            }
        }
    }
    
    // Send email to SFDC Owner when the Owner was updated from JIRA
    public static void SendEmailtoSFDCOwner(List<Development__c> lstNewDevs, Map<Id, Development__c> mapOldDevs){
        if(launchControl.get('SendEmailtoSFDCOwner') < 1){
            launchControl.put('SendEmailtoSFDCOwner',launchControl.get('SendEmailtoSFDCOwner') + 1);
            
            OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address from OrgWideEmailAddress WHERE Address = 'donotreply_sfdcsupport@trimble.com' limit 1];
            
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Set<Id> setUserIDs = new Set<Id>();
            
            for(Development__c dev : lstNewDevs){
                setUserIDs.add(dev.OwnerId);
                setUserIDs.add(dev.CreatedById);
                setUserIDs.add(dev.LastModifiedById);
            }
            Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Email, Name, Division__c FROM User WHERE Id IN :setUserIDs AND Name != 'System Assigned' limit 49999]);
            
            for(Development__c dev : lstNewDevs){
                if(mapUsers.containsKey(dev.LastModifiedById) && mapUsers.containsKey(dev.OwnerId)){
                    if(mapUsers.get(dev.LastModifiedById).Name.contains('API User') && dev.OwnerId != mapOldDevs.get(dev.Id).OwnerId){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if(owa != null)
                            mail.setOrgWideEmailAddressId(owa.Id);
                        String[] toAddresses = new String[] {mapUsers.get(dev.OwnerId).Email};
                            mail.setToAddresses(toAddresses);
                        mail.setSubject('Development transferred to you.');
                        String body = 'Development '+ dev.Name +' has been assigned to you. Please click on the link below to view the record.<br/><br/>';
                        body += system.Url.getSalesforceBaseUrl().toExternalForm() + '/' + dev.Id;
                        mail.setHtmlBody(body);
                        allmsg.add(mail);
                    }
                }
            }
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(allmsg, false);
            system.debug('results ======================>>>>'+results);
        }
    }
    
    // This method is used to initiate JIRA sync process
    public static void JIRASyncProcess(List<Development__c> lstNewDevs, Map<Id, Development__c> mapOldDevs){
        if(launchControl.get('JIRASyncProcess') < 1){
            launchControl.put('JIRASyncProcess',launchControl.get('JIRASyncProcess') + 1);
            
            system.debug('Current User :::::::::::::::::: '+UserInfo.getName());
            if(UserInfo.getName() != 'TFS API User')
                JIRASycnOnDevelopmentUpdate.updateJIRATicket(lstNewDevs, mapOldDevs);
        }
    }
}