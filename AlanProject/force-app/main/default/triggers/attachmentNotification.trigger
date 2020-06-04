trigger attachmentNotification on Attachment (after insert) {
    if(userinfo.getName() != 'Data Administrator'){
        if(staticRecursiveHandler.runOnetime == true || (Test.isRunningTest())){
            // grab the email template for external communicatins
            List<EmailTemplate> etList = [SELECT Id FROM EmailTemplate WHERE Name = 'RE&WS - AttachmentNotification' LIMIT 1];
            
            // gather parentIds to query their related case date
            // gather creator Ids so we know who to send an email to
            List<Id> parentIds = new List<Id>();
            List<Id> creators = new List<Id>();
            for(Attachment a : trigger.new){
                parentIds.add(a.ParentId);
                creators.add(a.CreatedById);
            }
            
            // if an attachment is a related to a case the case will show up in this map
            // by checking if an attachment's parent id is in the caseMap we can know whether
            // or not the attachment is related to a case 
            Map<Id,Case> caseMap = new Map<Id,Case>([SELECT Id, Record_Creator_s_User_Division__c,recordtype.id, recordtype.developername, OwnerId, Owner.email, contactId, Subject, CaseNumber FROM Case WHERE Id IN :parentIds AND recordtype.developername='Support']); //RE&WS Record type has developer name = 'Support', so included only for RE&WS Cases. Record type condition added. [Prasad - 16July15]
            // gather all the Ids for all the contacts related to each case
            List<Id> caseContactIds = new List<Id>();
            for(Case c : caseMap.values()){
                caseContactIds.add(c.ContactId);
            }
            
            // gather the user ids of both the contacts and internal users
            Map<Id,User> userMap = new Map<Id,User>([SELECT Id, UserType, ContactId FROM User WHERE Id IN :creators OR ContactId IN :caseContactIds]);
            Map<Id,User> userMapByContactId = new Map<Id,User>();
            for(User u : userMap.values()){
                userMapByContactId.put(u.ContactId, u); 
            }
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            for(Attachment a : trigger.new){             
                system.debug('Checkin boolean variable trigger starts>>>>>'+staticRecursiveHandler.runOnetime);
                if(caseMap.containsKey(a.ParentId) && // check if this attachment is related to a case
                   userMap.containsKey(a.CreatedById) && // check that attachment is not a SSP case 
                   etList.size() > 0){ // check that the email template exists
                       
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       
                       // if the user type is standard we know it's an internal user
                       // and we need to notify the customer portal contact
                       if(userMap.get(a.CreatedById).UserType == 'Standard'){
                           // we can use the email template for external contacts  
                           mail.setTemplateId(etList[0].Id);
                           mail.setWhatId(a.ParentId);
                           mail.setTargetObjectId(caseMap.get(a.ParentId).ContactId);
                           messageList.add(mail);
                       }else {
                           // if the owner is a queue, don't send an email
                           String ownerId = caseMap.get(a.ParentId).ownerId;
                           if(!ownerId.startsWith('00G')) {              
                               // otherwise we need to notify the case owner
                               // We can't use templates since you can't specify whatId if the target object is 
                               // a user and not a contact.  Instead hardcode the email body. 
                               mail.setTargetObjectId(caseMap.get(a.ParentId).OwnerId);
                               mail.setSubject('An attachment has been added to Case # ' + caseMap.get(a.ParentId).CaseNumber);
                               // mail.setPlainTextBody('--This is an automated email. PLEASE DO NOT REPLY. Access the support case via Manhattan\'s Support Portal to add your comments and/or attachments.--' + '\r \r' + 'Hello-' + '\r \r' + 'An attachment has been added to Case # ' + caseMap.get(a.ParentId).CaseNumber + ', Subject: ' + caseMap.get(a.ParentId).Subject + '.  Please click the link below to access the support case and view the attachment. \r \r' +  System.URL.getSalesforceBaseUrl() + '/'+ caseMap.get(a.ParentId).Id + ' \r \rRegards, \r \r Trimble Client Services');
                               mail.setPlainTextBody('--This is an automated email. PLEASE DO NOT REPLY.' + '\r \r' + 'Hello-' + '\r \r' + 'An attachment has been added to Case # ' + caseMap.get(a.ParentId).CaseNumber + ', Subject: ' + caseMap.get(a.ParentId).Subject + '.  Please click the link below to access the support case and view the attachment. \r \r' + Label.Internal_UAT_url+'/'+caseMap.get(a.ParentId).Id + ' \r \rRegards, \r \r Trimble Support Services');                                       
                               mail.setSenderDisplayName('Attachment Notification');
                               mail.setSaveAsActivity(false);
                               messageList.add(mail);
                               System.debug('>>>>>>>'+System.URL.getSalesforceBaseUrl());
                           }   
                       }
                       
                   }
            }      
            // send the mail
            if(messageList.size() > 0){
                try{
                    Messaging.sendEmail(messageList);
                }catch(Exception e){
                    system.debug('######Oops Something goes wrong...'+e);
                }
                
            }
            staticRecursiveHandler.runOnetime = false;
            system.debug('Checkin boolean variable trigger end>>>>>'+staticRecursiveHandler.runOnetime);    
        } 
        
        if(trigger.isInsert && trigger.isAfter){
            List<Id> attIdList = new List<Id>();
            Map<Id,set<Id>> parentIdMap = new Map<Id,set<Id>>();
            for(Attachment att : trigger.new){
                System.debug('-------------------'+String.valueOf(att.ParentId).subString(0,3));
                if(Schema.getGlobalDescribe().get('Case').getDescribe().getKeyPrefix() == String.valueOf(att.ParentId).subString(0,3)){
                    if(!parentIdMap.containsKey(att.ParentId))
                        parentIdMap.put(att.ParentId,new set<Id>());    
                    parentIdMap.get(att.ParentId).add(att.Id);
                }
            }
            System.debug('-------------------'+parentIdMap);
            if(parentIdMap.size() > 0){
                for(Case cs : [Select ID from Case where Id in : parentIdMap.keySet() and 
                               (Record_Type_Name__c =: Label.GCCM_Support_Issue_Record_Type/* or Record_Type_Name__c =: Label.RE_WS_Proliance_Support_Issue_Record_Type*/)]){
                                   attIdList.addAll(parentIdMap.get(cs.ID));
                               }
                
                if(attIdList.size() == 1 && AttachmentListner.launchControl.Get('callTFS') == 0){
                    AttachmentListner.launchControl.put('callTFS', 1);
                    AttachmentListner.callTFS(attIdList);
                }
            }
            //AttachmentListner.AddAttachmentToCase(trigger.new);
        }
    }
}