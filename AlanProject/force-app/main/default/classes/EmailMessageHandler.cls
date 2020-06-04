public class EmailMessageHandler {
    public static Map<String, Integer> launchControl;
    // Static initialize
    static {
        resetLaunchControl();
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('ResetCase24HoursNotification',0);
        launchControl.put('setToAddress',0);
    }
    
    // Reset Trigger control (e.g. for testing)
    public static void setLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('ResetCase24HoursNotification',1);
        launchControl.put('setToAddress',1);
    }
    
    public static void removeCreditCardNumber(List<EmailMessage> newEmailList){
        String reGexVisa= '\\d\\d\\d\\d[ -]?\\d\\d\\d\\d[ -]?\\d\\d\\d\\d[ -]?\\d\\d\\d\\d';

        for(EmailMessage msg : newEmailList){ 
            if(msg.TextBody != null)msg.TextBody = msg.TextBody.replaceAll(reGexVisa , 'XXXX XXXX XXXX XXXX');
            if(msg.HtmlBody != null)msg.HtmlBody = msg.HtmlBody.replaceAll(reGexVisa , 'XXXX XXXX XXXX XXXX');
        }
    }
    
    //Update Case when Email message Incoming = false
    public static void ResetCase24HoursNotification(List<EmailMessage> newEmailList){
        system.debug('-----------------launchControl-------------' + launchControl.get('ResetCase24HoursNotification'));
        if(launchControl.get('ResetCase24HoursNotification') < 1){
            
            Map<Id,Case> parentMap = new Map<Id, Case>();
            for(EmailMessage msg : newEmailList){
                string objPrefix = (String)msg.ParentId; // CaseID - String ObjPreFix = (String)msg.ParentId
                system.debug('objPrefix----------' + objPrefix);
                system.debug('objPrefix incoming----------' + !msg.Incoming);
                system.debug('objPrefix left 3----------' + objPrefix.left(3));
                system.debug('Obj ---'+Schema.getGlobalDescribe().get('Case').getDescribe().getKeyPrefix());
                if(objPrefix != Null && !msg.Incoming && objPrefix.left(3) == Schema.getGlobalDescribe().get('Case').getDescribe().getKeyPrefix()){
                    parentMap.put(msg.ParentId, null);
                }
            }
            system.debug('-----------------parentMap-------------' + parentMap);
            set<Id> existingMsgIds = new set<Id>();
            parentMap = new Map<Id,Case>([Select Id,Status,status_reason__c,Record_Type_Name__c,OwnerId,Bypass_Validation__c, To_Address__c, 
                                          CC_Address__c, createdby.IsPortalEnabled, product_group__c from Case where Id IN: parentMap.keySet()  and Record_Type_Name__c =: Label.GCCM_Support_Case_Record_Type]);
            system.debug('-----------------parentMap-------------' + parentMap);
            for(EmailMessage em : [select Id,ParentId from EmailMessage where parentId in: parentMap.keySet() and 
                                   Incoming = false]){
                                       existingMsgIds.add(em.Id);
                                   }
            
            List<Case> updateCSList = new List<Case>();
            for(EmailMessage em : newEmailList){
                String objPrefix = em.ParentId;
               // system.debug('------ ' +parentMap.keySet() + '-------22' + parentMap.get(em.ParentId).Record_Type_Name__c);
                if(parentMap.containsKey(em.ParentId)){
                    if(parentMap.get(em.ParentId).Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type){
                        Case cs = new Case();
                        cs = parentMap.get(em.ParentId);
                        cs.Case24HoursTimeStamp__c = null;
                        String statusReason = (parentMap.get(em.ParentId).status_reason__c == null ? '' : parentMap.get(em.ParentId).status_reason__c);
                        if((existingMsgIds.size() != 0 || cs.To_Address__c == null || cs.To_Address__c == '' ) && cs.Status != 'Closed' && !statusReason.contains('Escalated') && cs.createdby.IsPortalEnabled != True){
                            cs.Status = 'Open';
                            cs.status_reason__c = 'Waiting for Client Response';
                        }
                        cs.Bypass_Validation__c = (cs.Bypass_Validation__c == 'true' ? 'false' : 'true');
                       // cs.product_group__c  = cs.product_group__c;
                      //  if(cs.product_group__c ==null || cs.product_group__c !=null || cs.product_group__c =='' || cs.product_group__c !='')
                        updateCSList.add(cs);
                     
                    }
                }
            }
            if(updateCSList.size() > 0){
                launchControl.put('ResetCase24HoursNotification',launchControl.get('ResetCase24HoursNotification') + 1);
                CaseHandler.setLaunchControl();
                update updateCSList;
            }
        }
    }
    
    //Update Case when Email message Incoming = true
    public static void setToAddress(List<EmailMessage> newEmailList){
        system.debug('-----------------launchControl-------------' + launchControl.get('setToAddress'));
        if(launchControl.get('setToAddress') < 1){
            Map<Id,EmailMessage > parentMap = new Map<Id,EmailMessage >();
            Map<Id,Case> caseMap = new Map<Id,Case>();
            boolean flag = false;
            
            for(EmailMessage msg : newEmailList){
                system.debug('parentMap*******'+msg);
                string objPrefix = (String)msg.ParentId;
                if(msg.Incoming && objPrefix.left(3) == Schema.getGlobalDescribe().get('Case').getDescribe().getKeyPrefix()){
                    parentMap.put(msg.ParentId,msg);
                }
            }
            system.debug('-----------------parentMap-------------' + parentMap);
            system.debug('parentMap*******'+parentMap);
            
            if(parentMap.size() > 0){
                set<Id> existingCaseIds = new set<Id>();
                boolean firstInboundMsg = true;
                boolean emailAddressFlag = true;
                caseMap = new Map<Id,Case>([Select Id,CreatedDate,status_reason__c, Status,Record_Type_Name__c,OwnerId,Bypass_Validation__c, To_Address__c, 
                                            CC_Address__c from Case where Id IN: parentMap.keySet()]);
                system.debug('-----------------caseMap-------------' + caseMap);
                for(EmailMessage em : [select Id,ParentId from EmailMessage where parentId in: parentMap.keySet() and Incoming = true]){
                                           String objPrefix = em.parentId;
                                           if(objPrefix.startsWith('500')){
                                               firstInboundMsg = false;
                                               String str = caseMap.get(em.ParentId).OwnerId;
                                               system.debug('-----------------str-------------' + str);
                                               if(str.startsWith('00G'))existingCaseIds.add(em.parentId);
                                               system.debug('-----------------caseMap.get(em.parentId).CreatedDate.isSameDay(system.now())-------------' + caseMap.get(em.parentId).CreatedDate.isSameDay(system.now()));
                                               if(caseMap.get(em.parentId).CreatedDate.isSameDay(system.now())){
                                                   Long dt1Long = caseMap.get(em.parentId).CreatedDate.getTime()/1000/60;
                                                   Long dt2Long = system.now().getTime()/1000/60;
                                                   if((((dt2Long - dt1Long) / 1000) / 60) > 1.0)emailAddressFlag = false;
                                               }else{
                                                   emailAddressFlag = false;           
                                               }
                                               system.debug('-----------------emailAddressFlag------------' + emailAddressFlag);
                                           }
                                       }
                system.debug('-----------------existingCaseIds-------------' + existingCaseIds);
                for(EmailMessage em : newEmailList){
                    system.debug('-----------------existingCaseIds-------------' + (parentMap.get(em.ParentId) != null && caseMap.get(em.ParentId) != null));
                    if(parentMap.get(em.ParentId) != null && caseMap.get(em.ParentId) != null){
                        if(emailAddressFlag){
                            if(em.ToAddress != null && em.ToAddress != '' && parentMap.containsKey(em.ParentId) && 
                               (caseMap.get(em.ParentId).To_Address__c == null || caseMap.get(em.ParentId).To_Address__c == '')){
                                   caseMap.get(em.ParentId).To_Address__c = (parentMap.get(em.ParentId).ToAddress != null ? parentMap.get(em.ParentId).ToAddress.left(200) : '');
                                   flag = true;
                               }
                            system.debug('-----------------caseMap.get(em.ParentId).To_Address__c-------------' + caseMap.get(em.ParentId).To_Address__c);
                            if(em.CCAddress != null && em.CCAddress != '' && parentMap.containsKey(em.ParentId) && 
                               (caseMap.get(em.ParentId).CC_Address__c == null || caseMap.get(em.ParentId).CC_Address__c == '')){
                                   caseMap.get(em.ParentId).CC_Address__c = (parentMap.get(em.ParentId).CCAddress != null ? parentMap.get(em.ParentId).CCAddress.left(200) : '');
                                   flag = true;
                               }
                        }
                        system.debug('-----------------caseMap.get(em.ParentId).CC_Address__c-------------' + caseMap.get(em.ParentId).CC_Address__c);
                        system.debug('-----------------caseMap.get(em.ParentId).status_reason__c-------------' + caseMap.get(em.ParentId).status_reason__c);
                        String statusReason = (caseMap.get(em.ParentId).status_reason__c == null ? '' : caseMap.get(em.ParentId).status_reason__c);
                        if(!statusReason.contains('Escalated')){
                            // TT 128466 - Fix - Condition to not change the Case owner as unassigned if assigned to a Case Owner 
                            //- Condition Added below - <!String.valueOf(caseMap.get(em.ParentId).OwnerId).startswith('500')> - Ankur
                            
                            if(caseMap.get(em.ParentId).Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type && caseMap.get(em.ParentId).Status != 'Closed' &&
                               (existingCaseIds.contains(em.ParentId) || firstInboundMsg) && !String.valueOf(caseMap.get(em.ParentId).OwnerId).startswith('500')){
                                   caseMap.get(em.ParentId).Status = 'Open';
                                   caseMap.get(em.ParentId).status_reason__c = 'New Unassigned';
                                   flag = true;
                               }else if(caseMap.get(em.ParentId).Record_Type_Name__c == Label.GCCM_Support_Case_Record_Type && caseMap.get(em.ParentId).Status != 'Closed' &&
                                        !existingCaseIds.contains(em.ParentId)){
                                            caseMap.get(em.ParentId).Status = 'Open';
                                            caseMap.get(em.ParentId).status_reason__c = 'Assigned to Analyst';    
                                            flag = true;
                                        }
                        }
                        system.debug('-----------------caseMap.get(em.ParentId).status_reason__c-------------' + caseMap.get(em.ParentId).status_reason__c);
                        caseMap.get(em.ParentId).Bypass_Validation__c = (caseMap.get(em.ParentId).Bypass_Validation__c == 'true' ? 'false' : 'true');
                    }
                }
                
                system.debug(flag + '--------------'+caseMap);
                if(caseMap.size() > 0 && flag){
                    launchControl.put('setToAddress',launchControl.get('setToAddress') + 1);
                    system.debug('--------------'+CaseHandler.launchControl.get('Case24HoursNotification'));
                    CaseHandler.setLaunchControl();
                    CaseHandler.launchControl.put('Case24HoursNotification',0);
                    system.debug(flag + '--------------'+caseMap);
                    update caseMap.values();   
                    
                    
                }
            }
        }
    }
}