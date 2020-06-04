/*****************************************************************************************
    Name    : CreateCaseFromTFS
    Desc    : Used to do a call out from TFS and Insert / Update data to SFDC tabels Case and Attachment.
                                          
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel           29/06/2015          Created 
******************************************************************************************/
global class CreateCaseFromTFS{

     /*
     * Method name  : CreateCase
     * Description  : Method to Create an Cases with related List of Attachment from TFS
     * Return Type  : list<ResponseWrapper>
     * Parameter    : RequestCaseData 
     */
    public static boolean test_bl = false;
    webService static List<ResponseWrapper> CreateCase(List<RequestCaseData> caseList){
        
        List<ResponseWrapper> responseList = new List<ResponseWrapper>();
        
        Map<String,Case> issueIdMap = new Map<String,Case>();
        Map<String,RequestCaseData> caseNumberMap = new Map<String,RequestCaseData>();
        Map<String,Case> caseMap = new Map<String,Case>();
        Set<String> fountData = new set<String>();
        List<Case> UpdateCase = new List<Case>();
        List<Case> InsertCase = new List<Case>();
        
        
        for(RequestCaseData ReqData : CaseList){
            system.debug('---------------ReqData---------'+ReqData);
            /*if(ReqData.TFSId != null && ReqData.TFSId != '' && ReqData.Division != 'PROLIANCE'){
                issueIdMap.put(ReqData.TFSId , null);
            }*/
            if(ReqData.CaseNumber != null && ReqData.CaseNumber != '' /*&& ReqData.Division == 'PROLIANCE'*/)
                caseNumberMap.put(ReqData.CaseNumber,ReqData);
        }

        for(Case cs : [select Id,Product__c,TFS_Status__c,Assigned_To__c,Confirmed_in_Build__c,Assigned_Date__c,Severity_c__c,TFS_Id__c,CaseNumber 
                from Case where (TFS_Id__c in: issueIdMap.keySet() and TFS_Id__c != null) or CaseNumber in: caseNumberMap.keyset()]){
            /*for(RequestCaseData ReqData : CaseList){
                if(TFS_Project_Config__c.getAll().containsKey(cs.Product__c) ? 
                   TFS_Project_Config__c.getAll().get(cs.Product__c).Division__c == ReqData.Division && cs.TFS_Id__c == ReqData.TFSId : 
                   false)
                     issueIdMap.put(cs.TFS_Id__c,cs);
            }*/
            caseMap.put(cs.CaseNumber, cs);
        }
		system.debug('---------------caseMap---------'+caseMap);
        try{
            Case cs = new Case();
            for(RequestCaseData ReqData : CaseList){
                cs = new Case();
                //system.debug('---------------issueIdMap.get(ReqData.TFSId)---------'+issueIdMap.get(ReqData.TFSId));
                system.debug('---------------caseMap.put(cs.CaseNumber)---------'+caseMap.get(ReqData.CaseNumber));
                DateTime assignedDate = null;
                DateTime closedDate = null;
                /*if(issueIdMap.get(ReqData.TFSId) != null){
                    cs = issueIdMap.get(ReqData.TFSId);
                    if(ReqData.AssignedDate != null && ReqData.AssignedDate != ''){
                        if(issueIdMap.get(ReqData.TFSId).Assigned_To__c != ReqData.AssignTo)assignedDate = DateTime.Valueof(ReqData.AssignedDate);
                        if(issueIdMap.get(ReqData.TFSId).TFS_Status__c != ReqData.Status && ReqData.Status == 'Closed')closedDate = DateTime.Valueof(ReqData.AssignedDate);
                    }
                    
                    UpdateCase.add(cs);
                }else */if(caseMap.get(ReqData.CaseNumber) != null){
                    cs = caseMap.get(ReqData.CaseNumber);
					if(ReqData.AssignedDate != null && ReqData.AssignedDate != ''){
                        if(caseMap.get(ReqData.CaseNumber).Assigned_To__c != ReqData.AssignTo)assignedDate = DateTime.Valueof(ReqData.AssignedDate);
                        if(caseMap.get(ReqData.CaseNumber).TFS_Status__c != ReqData.Status && ReqData.Status == 'Closed')closedDate = DateTime.Valueof(ReqData.AssignedDate);
                    }
                    UpdateCase.add(cs);
                }else{
                    cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.GCCM_Support_Issue_Record_Type).getRecordTypeId();
                    InsertCase.add(cs);
                }
                system.debug('---------------ReqData.TFSId---------'+ReqData.TFSId);
                cs.TFS_Id__c = ReqData.TFSId;
                system.debug('---------------ReqData.Status---------'+ReqData.Status);
                cs.TFS_Status__c = ReqData.Status;
                system.debug('---------------ReqData.ResolutionNotes---------'+ReqData.ResolutionNotes);
                if(ReqData.ResolutionNotes != null){
                    cs.Resolution__c = (ReqData.ResolutionNotes.length() > 32768 ? ReqData.ResolutionNotes.subString(0,32768) : ReqData.ResolutionNotes);
                }
                system.debug('---------------ReqData.AssignedDate---------'+ReqData.AssignedDate);
                if(assignedDate != null)cs.Assigned_Date__c = assignedDate;
                if(closedDate != null)cs.TFS_Close_Date__c = closedDate.date();
                system.debug('---------------ReqData.AssignTo---------'+ReqData.AssignTo);
                cs.Assigned_To__c = ReqData.AssignTo;
                if(ReqData.Notes != null){
                    cs.Notes__c = (ReqData.Notes.length() > 131072 ? ReqData.Notes.subString(0,131072) : ReqData.Notes);
                }
                system.debug('---------------ReqData.FixedInBuild---------'+ReqData.FixedInBuild);
                cs.Fixed_in_Build__c = ReqData.FixedInBuild;
                cs.Confirmed_in_Build__c = ReqData.ConfirmInBuild;
                system.debug('---------------ReqData.ResolutionType---------'+ReqData.ResolutionType);
                cs.Reason__c = ReqData.ResolutionType;
                system.debug('---------------ReqData.Subject---------'+ReqData.Subject);
                cs.Subject = ReqData.Subject;
                system.debug('---------------ReqData.PrivateNotes---------'+ReqData.PrivateNotes);
                if(ReqData.PrivateNotes != null){
                    cs.Private_Notes__c = (ReqData.PrivateNotes.length() > 131072 ? ReqData.PrivateNotes.subString(0,131072) : ReqData.PrivateNotes);
                }
                cs.Integration_Exception_Message__c = 'Success';
            }
            system.debug('---------------UpdateCase---------'+UpdateCase);
            if(UpdateCase.size()>0){
                Integer index = 0;
                caseHandler.launchControl.put('validateBeforeTFSCallout',1);
                for(Database.SaveResult result : Database.update(updateCase,false)){
                    system.debug('---------------result.isSuccess()---------'+result.isSuccess());
                    ResponseWrapper response = new ResponseWrapper();
                    if(result.isSuccess() && !test_bl){
                        response.TFSId = updateCase[index].TFS_Id__c;
                        response.SFDCID = updateCase[index].id;
                        response.Status = 'Success';
                    }else{
                        response.TFSId = updateCase[index].TFS_Id__c;
                        response.SFDCID = updateCase[index].id;
                        response.Status = 'Fail';
                        String msg = '';
                        for (Database.Error er : result.getErrors()) {
                            msg += 'Error (' +  er.getStatusCode() + '):' + er.getMessage();
                            msg += '\r\n';
                        }
                        response.ErrorMessage = msg;
                    }
                    responseList.add(response);
                    index++;
                }
            }
          
            /*if(InsertCase.size()>0){
                Integer index = 0;
                caseHandler.launchControl.put('callTFS',1);
                for(Database.SaveResult result : Database.insert(InsertCase,false)){
                    ResponseWrapper response = new ResponseWrapper();
                    if(result.isSuccess()  && !test_bl){
                        response.TFSId = InsertCase[index].TFS_Id__c;
                        response.SFDCID = InsertCase[index].id;
                        response.Status = 'Success';
                    }else{
                        response.TFSId = InsertCase[index].TFS_Id__c;
                        response.SFDCID = '';
                        response.Status = 'Fail';
                        String msg = '';
                        for (Database.Error er : result.getErrors()) {
                            msg += 'Error (' +  er.getStatusCode() + '):' + er.getMessage();
                            msg += '\r\n';
                        }
                        response.ErrorMessage = msg;
                    }
                    responseList.add(response);
                    index++;
                }
            }*/
        }catch(Exception ex){
            Inbound_Outbound_Callouts__c errorLog = new Inbound_Outbound_Callouts__c();
            errorLog.Callout_Type__c = 'Outbound';
            errorLog.Destination_System__c = 'TFS';
            errorLog.Source_System__c ='SFDC';
            errorLog.Integration_Module__c =  'SFDC-TFS Case Integration';
            errorLog.Error_Message__c = ex.getMessage();
            insert errorLog;
            
            ResponseWrapper response = new ResponseWrapper();
            response.TFSId = '';
            response.SFDCID = '';
            response.Status = 'Failed';
            response.ErrorCode = '';
            response.ErrorMessage = ex.getMessage();
        }
        
        return responseList;
    }
    
    webService static ResponseWrapper CreateAttachment(RequestAttachmentData requestParam){
        ResponseWrapper response = new ResponseWrapper();
        boolean flag = false;
        try{
            system.debug('---------------requestParam---------'+requestParam);
            system.debug('---------------requestParam---------'+requestParam.Division);
            
            /*set<String> prdSet = new set<String>();
            for(TFS_Project_Config__c temp : TFS_Project_Config__c.getAll().values()){
                if(temp.Division__c == requestParam.Division){
                    prdSet.add(temp.Name);
                }
            }*/
            
            List<Case> csList = [select Id from Case where CaseNumber =: requestParam.CaseNumber/* and Product__c in : prdSet*/];
            system.debug('---------------csList---------'+csList);
            if(csList.size() > 0){
                Attachment att = new Attachment();
                /*for(Attachment attObj : [select Id from Attachment where Name =: requestParam.AttachmentName and 
                    parentId =: csList.get(0).Id]){
                    flag = true;
                    break;
                }*/
                //if(!flag){
                    att.Name = requestParam.AttachmentName;
                    att.Body = EncodingUtil.base64Decode(requestParam.AttachmentBody);
                    att.ContentType = requestParam.ContentType;
                    att.Description = requestParam.AttachmentDescription;
                    att.ParentID = csList.get(0).Id;
                    AttachmentListner.launchControl.put('callTFS',1);
                    insert att;
               // }
                response.TFSId = requestParam.TFSId;
                response.SFDCID = att.Id;
                response.Status = 'Success';
                response.ErrorCode = '';
                response.ErrorMessage = '';
            }else{
                response.TFSId = requestParam.TFSId;
                response.SFDCID = '';
                response.Status = 'Failed';
                response.ErrorCode = '';
                response.ErrorMessage = 'No Issue found with TFS ID ' + requestParam.TFSId;
            }
        }catch(Exception ex){
            response.TFSId = requestParam.TFSId;
            response.SFDCID = '';
            response.Status = 'Failed';
            response.ErrorCode = '';
            response.ErrorMessage = ex.getMessage();
        }
        return response;
    }
    
    global class RequestCaseData{
        webservice String TFSId{get;set;}      
        webservice String Status{get;set;}  
        webservice String CaseNumber{get;set;}    
        webservice String AssignTo{get;set;}        
        webservice String AssignedDate{get;set;}                      
        webservice String Notes{get;set;}        
        webservice String ResolutionType{get;set;}
        webservice String ResolutionNotes{get;set;}          
        webservice String PrivateNotes{get;set;}        
        webservice String FixedInBuild{get;set;} 
        webservice String Subject{get;set;}
        webservice String Type{get;set;}
        webservice String AssignedBy{get;set;}
        webservice String DevelopmentNotes{get;set;}
        webservice String MRBundle{get;set;}
        webservice String Division{get;set;}
        webservice String ConfirmInBuild{get;set;}
        webservice String attribute1{get;set;}
        webservice String attribute2{get;set;}
        webservice String attribute3{get;set;}
        webservice String attribute4{get;set;}
        webservice String attribute5{get;set;}
        webservice String attribute6{get;set;}
        webservice String attribute7{get;set;}
        webservice String attribute8{get;set;}
        webservice String attribute9{get;set;}
        webservice String attribute10{get;set;}
    }
    
    global class RequestAttachmentData{
        webservice String TFSId{get;set;}    
        webservice String AttachmentName{get;set;}    
        webservice String AttachmentBody{get;set;}
        webservice String ContentType{get;set;}
        webservice String Division{get;set;}
        webservice String AttachmentDescription{get;set;}
        webservice String CaseNumber{get;set;} 
    }
    
    global class ResponseWrapper{
        webservice String TFSId{get;set;}        
        webservice String SFDCID{get;set;}     
        webservice String Status{get;set;}
        webservice String ErrorCode{get;set;}
        webservice String ErrorMessage{get;set;}
    }
}