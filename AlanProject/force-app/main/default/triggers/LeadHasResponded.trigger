/*****************************************************************************************
    Name    : LeadHasResponded 
    Desc    : After update trigger to update leads with Lead (Marketing) Record Type
    Project ITEM: ITEM-00804
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       5/21/2013          Created
Ruben Thomas          7/9/2013           Updated 
******************************************************************************************/

trigger LeadHasResponded on Lead (before update, after update, before insert, after insert) {
        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Lead.SObjectType);
        System.debug('RecursiveTriggerUtility.isTriggerExecute != true: '+RecursiveTriggerUtility.isTriggerExecute);
        
        if(Trigger.isBefore && Trigger.isUpdate && RecursiveTriggerUtility.isTriggerExecute != true && RecursiveTriggerUtility.isBatchExecute){
            List<Group> groupList = new List<Group>();
            groupList = [Select Id from Group where DeveloperName =: Label.Nurture_Lead_Queue];
            
            /* Query the profile of the lead owner, to check if it belongs to Partner Profile  
             * This is to assign the 48 hour time stamp to lead, to ensure that if the no action 
             * is taken by the partner then reassign the lead Leads to Reassign Queue. 
             */
            Profile profile = [Select Id from Profile where Name =: Label.Partner_Portal_Profile_Name];
            Set<Id> ownerIdSet = new Set<Id>();
            for(Lead lead : trigger.new){
                ownerIdSet.add(lead.OwnerId);
            }
            List<User> userList = new List<User>();
            userList = [Select Id, ProfileId from User where Id IN: ownerIdSet];
            Map<Id, Id> profileMap = new Map<Id, Id>();
            for(User user : userList){
                profileMap.put(user.Id, user.ProfileId);
            }           
            boolean flag = true;
            List<Id> leadIsList = new List<id>(); 
            Datetime CurrentDate = system.Now();
            Datetime Case48HoursTimeStamp;
            BusinessHours stdBusinessHours = [select id from BusinessHours where Name =: Label.GCCM_24_5_Support];
            //23 hours = 82800000 milliseconds and 24 hours == 86400000 milliseconds            
            Case48HoursTimeStamp = BusinessHours.addGmt(stdBusinessHours.id, CurrentDate, 172800000);
            DateTime dt = Case48HoursTimeStamp; // assign 48 hours time stamp to lead record
            for(Lead lead : trigger.new){
                try{
                    Lead oldLead = System.Trigger.oldMap.get(lead.Id);
                    if(lead.Street != null){
                        String Line1, Line2, Line3, Line4;
                        String[] lines = lead.Street.split('\r\n');
                        Line1 = lines[0];                        
                        if (lines.size() > 1){
                           Line2 = lines[1];
                        }           
                        if (lines.size() > 2){
                           Line3 = lines[2];
                        }                    
                        if (lines.size() > 3){
                          Line4 = lines[3];
                        }                
                        lead.Address1__c = Line1; 
                        lead.Address2__c = Line2;
                        lead.Address3__c = Line3;
                        lead.Address4__c = Line4;
                    }
                    if(lead.OwnerId != oldLead.OwnerId && profileMap.get(lead.OwnerId) == profile.Id){                        
                        flag = false;
                        lead.Qualified_By__c = UserInfo.getUserId();
                        lead.Notify_Owner__c = true;
                        lead.RecordTypeId = recordTypeMap.get(Label.Lead_Accept_Reject_Record_Type);
                        lead.Lead_Assign_TimeStamp__c = System.now();
                        lead.isPartnerReject__c = false;
                        if(Case48HoursTimeStamp.minute() > 30){
                            dt = DateTime.newInstance(Case48HoursTimeStamp.year(), Case48HoursTimeStamp.month(), Case48HoursTimeStamp.day(), Case48HoursTimeStamp.hour()+1, 0, 0);                   
                        }else{
                            dt = DateTime.newInstance(Case48HoursTimeStamp.year(), Case48HoursTimeStamp.month(), Case48HoursTimeStamp.day(), Case48HoursTimeStamp.hour(), 0, 0);
                        }
                        lead.Lead_Accept_TimeStamp__c = dt;                        
                    }else{
                        //check if the lead has the status nurture and record type of Customer record type
                        flag = true;
                        if (lead.IsConverted == false && oldLead.Status != Label.Lead_Status_Nurture && lead.Status == Label.Lead_Status_Nurture && lead.RecordTypeId == recordTypeMap.get(Label.Lead_Customer_Record_Type)){
                            leadIsList.add(lead.Id);
                        }
                        if(groupList.size() > 0){
                            Group gr = groupList.get(0);
                            if(lead.Status == Label.Lead_Status_Nurture && lead.RecordTypeId == recordTypeMap.get(Label.Lead_Customer_Record_Type) && oldLead.OwnerId == gr.Id){
                                lead.Status = Label.Lead_Status_Inquiry_Engaged_in_Nurture;
                             /**lead.Status = Label.Lead_Status_Suspect;
                                lead.Status = Label.Lead_Status_Inquiry_Engaged_in_Nurture;
                                lead.Status = Label.Lead_Status_MQL_Marketing_Qualified_Leads;
                                lead.Status = Label.Lead_Status_SQL_Convert_to_Opportunity;
                                lead.Status = Label.Lead_Status_SQL_Inquiry_Send_to_Partner;
                                lead.Status = Label.Lead_Status_Closed_Not_Converted; **/
                                
                                
                            }
                        }
                    }
                }catch(Exception e){
                    lead.addError(e.getMessage());
                }
            }
            if(!flag){
                RecursiveTriggerUtility.isTriggerExecute =  true;
            }
            if (AssignLeads.assignAlreadyCalled()==FALSE && leadIsList.size()>0 && flag){
                RecursiveTriggerUtility.isTriggerExecute =  true;
                //add all the matching Leads to be assigned to a assignment rule in AssignLeads class
                AssignLeads.Assign(leadIsList);
            }
        }
        
        
        if(Trigger.isBefore && Trigger.isInsert){
            for(Lead lead : trigger.new){
                String Line1, Line2, Line3, Line4;
                if(lead.Street != null){
                    String[] lines = lead.Street.split('\r\n');
                    Line1 = lines[0];
                    if (lines.size() > 1){
                       Line2 = lines[1];
                    }           
                    if (lines.size() > 2){
                       Line3 = lines[2];
                    }                    
                    if (lines.size() > 3){
                      Line4 = lines[3];
                    }                
                    lead.Address1__c = Line1; 
                    lead.Address2__c = Line2;
                    lead.Address3__c = Line3;
                    lead.Address4__c = Line4;                   
                }
            }
        }
        
        if(Trigger.isAfter && Trigger.isUpdate || (Trigger.isInsert)){
            if(RecursiveTriggerUtility.isBatchExecute && RecursiveTriggerUtility.isTriggerExecute != true){
                List<CampaignMember> updateCampaignMemberList = new List<CampaignMember>();
                List<Id> leadIdList = new List<id>();
                List<Id> updatedLeadIdList = new List<id>();
                Set<Id> leadIdSet = new Set<Id>();
               
                List<Lead> updateLeadList  = new List<Lead>();
                //To update Campaign Member with  Status fields     
                List<CampaignMember> campaignMemberList = new List<CampaignMember>();
                for(Lead lead : Trigger.new){
                    updatedLeadIdList.add(lead.Id);
                }
               campaignMemberList = [Select CampaignId, HasResponded, LeadId, Status FROM CampaignMember WHERE LeadId !=Null AND LeadId IN: updatedLeadIdList];
                for(Lead lead : Trigger.new){
                    try{
                        for(CampaignMember cmpMem : campaignMemberList){
                            if(cmpMem.LeadId == lead.Id){ 
                               if((lead.Status == Label.Lead_Status_Inquiry_Engaged_in_Nurture || lead.Status == Label.Lead_Status_Suspect || 
                                   lead.Status == Label.Lead_Status_MQL_Marketing_Qualified_Leads || lead.Status == Label.Lead_Status_SQL_Convert_to_Opportunity || 
                                   lead.Status == Label.Lead_Status_SQL_Inquiry_Send_to_Partner || lead.Status == Label.Lead_Status_Closed_Not_Converted ) 
                                                 && lead.RecordTypeId == recordTypeMap.get(Label.Lead_Marketing_Record_Type)
                                                 && cmpMem.Status != Label.CampMember_Status_Responded && cmpMem.LeadId != null) 
                                  {       
                                  cmpMem.Status = Label.CampMember_Status_Responded;
                                  updateCampaignMemberList.add(cmpMem); 
                                  leadIdSet.add(lead.Id);
                                  leadIdList.add(lead.Id);                          
                               }
                           
                                         
                            }
                        }
                      if(lead.Status == Label.Lead_Status_Inquiry && updateCampaignMemberList.size()==0 && lead.RecordTypeId == recordTypeMap.get(Label.Lead_Marketing_Record_Type)){
                            lead.addError(Label.Lead_Campaign_Mandatory); 
                        } 
                        /**** Logic added for checking the Status as Nurture on a Lead record creation ***/
                        /*if(Trigger.isInsert){
                           for(Lead le1 : Trigger.new){
                              if(le1.Status == Label.Lead_Status_Nurture){
                                leadIdList.add(le1.Id);
                              }
                           }
                        }*/
                        /**********************/ 
                    }
                catch(Exception e)
                {
                        lead.addError(e.getMessage());
                    }   
                } 
                //To check the condition lead status and leadrecortype and fill the list leadIdList
                try{    
                    if(updateCampaignMemberList.size()>0){
                        update updateCampaignMemberList;
                        
                        if(RecursiveTriggerUtility.isLeadUpdateExecute == false){
                            
                            for(Lead lead : [SELECT Id,Status, RecordTypeId, IsConverted FROM Lead WHERE Id IN: leadIdSet]){
                                //check to validate the old status value to be targeted and new value to be inquiry
                                if((Trigger.oldMap.get(lead.Id).Status == Label.Lead_Status_Targeted) && lead.IsConverted==False && lead.Status == Label.Lead_Status_Inquiry_Engaged_in_Nurture && lead.RecordTypeId == recordTypeMap.get(Label.Lead_Marketing_Record_Type)){
                                    lead.Status = Label.Lead_Status_Inquiry_Engaged_in_Nurture; 
                                    lead.RecordTypeId = recordTypeMap.get(Label.Lead_Customer_Record_Type);
                                    updateLeadList.add(lead);
                                    leadIdList.add(lead.Id);
                                }
                            }
                            update(updateLeadList);
                            RecursiveTriggerUtility.isLeadUpdateExecute = true;
                        }
                    }
                    RecursiveTriggerUtility.isTriggerExecute = true;
                    //To call the method to trigger lead assignment rule
                    if (AssignLeads.assignAlreadyCalled() == false && leadIdList.size() > 0){
                       AssignLeads.Assign(leadIdList);
                    }
                }catch(Exception e){
                    System.debug(e.getMessage());
                }
            }
            /* 
             * This block of code is executed for after update event
             * When a lead is converted, the competitor assets related records on a lead, 
             * needs to be mapped to corresponding Account record. 
             */
            /*if(Trigger.isAfter && Trigger.isUpdate){
                boolean competitorFlag = false, convertedFlag = false;
                 
                Map<Id, List<Competitor_Owned_Assets__c>> competitorAssetsMap = new Map<Id, List<Competitor_Owned_Assets__c>>();
                List<Competitor_Owned_Assets__c> competitorAssetsList = new List<Competitor_Owned_Assets__c>();
                List<Competitor_Owned_Assets__c> updatedCompetitorAssetsList = new List<Competitor_Owned_Assets__c>();
                
                //query all the Competitor Assets record related to the converted Lead record. 
                competitorAssetsList = [Select Id, Account__c, Lead__c from Competitor_Owned_Assets__c where Lead__c IN: Trigger.newMap.keySet()];
                
                //Create a map of Lead and associated List of Competitor Assets records to avoid multiple for loops.
                for(Competitor_Owned_Assets__c competitor : competitorAssetsList){
                    if(System.Trigger.oldMap.get(competitor.Lead__c).isConverted == false && System.Trigger.newMap.get(competitor.Lead__c).isConverted){
                        convertedFlag = true;
                    }
                    if(!competitorAssetsMap.keySet().contains(competitor.Lead__c))
                        competitorAssetsMap.put(competitor.Lead__c, new List<Competitor_Owned_Assets__c>());
                    competitorAssetsMap.get(competitor.Lead__c).add(competitor);
                }
                if(convertedFlag){ 
                    for(Lead lead : trigger.new){
                       try{
                          Lead oldLead = System.Trigger.oldMap.get(lead.Id);
                          if(oldLead.isConverted == false && lead.isConverted == true){ //check if the lead was really converted.
                             // if a new account was created
                             if (lead.ConvertedAccountId != null){
                                if(competitorAssetsMap.containsKey(lead.Id)){
                                   if(competitorAssetsMap.get(lead.Id).size() > 0){
                                      competitorFlag = true;
                                      for(Competitor_Owned_Assets__c comp : competitorAssetsMap.get(lead.Id)){
                                          comp.Account__c = lead.ConvertedAccountId;
                                      }
                                      updatedCompetitorAssetsList.addAll(competitorAssetsMap.get(lead.Id));
                                   }
                                }
                             }
                          }
                       }catch(Exception e){
                          lead.addError(e.getMessage());
                       }       
                    }
                } 
                if(updatedCompetitorAssetsList.size() > 0 && competitorFlag){
                   update updatedCompetitorAssetsList;
                }   
            }*/
        }  
}