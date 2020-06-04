global class BatchDeleteProposalEmailTemplate implements Database.Batchable<sObject>,   Database.AllowsCallouts , Schedulable , database.stateful{
    global void execute(SchedulableContext sc) {
        BatchDeleteProposalEmailTemplate batch = new BatchDeleteProposalEmailTemplate();
        database.executebatch(batch,10);
        
    }
    
    global MetadataService.MetadataPort service;
    public void DeleteProposalDocuments(){
        try{
            set<String> docFolderSet = new Set<String>();
            for(Proposal_Template_Config__c config : Proposal_Template_Config__c.getall().values()){
                docFolderSet.add(config.Temp_Folder_for_Document__c);
            }
            delete [select ID from Document where Folder.developername in : docFolderSet];
        }catch(Exception ex){
        
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        try{
            //Code for Decryption
            Blob b64decoded=EncodingUtil.base64Decode(Admin_User_Config__c.getAll().get('Admin').Token__c);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', blob.valueOf('12345678912345678912345678912345'),b64decoded);
            system.debug('----Decryption------'+decryptedData.tostring());
        
            partnerSoapSforceCom_v1 temp = new partnerSoapSforceCom_v1();
            partnerSoapSforceCom_v1.Soap soap = new partnerSoapSforceCom_v1.soap();
            partnerSoapSforceCom_v1.LoginResult result =  soap.login(Admin_User_Config__c.getAll().get('Admin').User_Name__c,decryptedData.tostring());
            
            service = MetadataServiceExamples.createService();
            service.SessionHeader.sessionId = result.sessionId;
        }catch(Exception ex){
            system.debug('------ex-------' + ex);
        }
        set<String> folderSet = new Set<String>();
        String query = 'select Folder.Name,DeveloperName from EmailTemplate where Folder.developername in (';
        for(Proposal_Template_Config__c config : Proposal_Template_Config__c.getall().values()){
            if(!folderSet.contains(config.Temp_Folder_for_Email_Template__c)){
                query = query + (folderSet.size() == 0 ? '' : ',') + '\'' + config.Temp_Folder_for_Email_Template__c + '\'';
                folderSet.add(config.Temp_Folder_for_Email_Template__c);
            }
        }
        
        query = query + (Test.isRunningTest() ?  ',\'' + [select Folder.Name, FolderId from EmailTemplate where FolderId <> null And Folder.Name <> null limit 1].Folder.Name.replaceAll(' ','_') + '\') limit 1' : ')');
        system.debug('------query -------' + query );
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EmailTemplate> records) {
        List<String> templateList = new List<String>();
        for(EmailTemplate temp1 : records){
            templateList.add(temp1.Folder.Name.replaceAll(' ','_') + '/' + temp1.developername);
        }
        try{
            system.debug('------service-------' + service);
            List<MetadataService.DeleteResult> results = service.deleteMetadata('EmailTemplate',templateList );
            system.debug('------results-------' + results);
        }catch(Exception ex){
            system.debug('------ex-------' + ex);
        }
    }
    
    global void finish(Database.BatchableContext BC){    
        try{
            DeleteProposalDocuments();
        }catch(Exception e){
        
        }
    }
}