/*****************************************************************************************
    Name    : CustomProposalGenerateController
    Desc    : Used as controller class for the Page CustomProposalGenerate to enable the users to land on Email Tempates based on there Profiles and Business Division.
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo         29/03/2015          Created
******************************************************************************************/
public class CustomProposalGenerateController{
    public String sessionId{get;set;}
    public String quoteId{get;set;}
    public String oppid;
    public decimal taxAmount;
    public boolean taxFlag{get;set;}
    public String selectedTemplate{get;set;}
    public List<String> docNameList{get;set;}
    Public List<AttachmentWrapper> AttWrapList{get;set;}
    Apttus_Proposal__Proposal__c proposal;
    User ur;
    Proposal_Template_Config__c proposalConfigObj;
    public String userDivsion {get;set;}

    public CustomProposalGenerateController(){
        ur = [select Division__c from User where Id =: userinfo.getUserId()];
        userDivsion = ur.Division__c;
        selectedTemplate = '';
        quoteId = System.currentPageReference().getParameters().get('id');
        proposal = [select Id, Name, Pricelist_Name__c from Apttus_Proposal__Proposal__c where Id =: quoteId];
        if(proposal.Pricelist_Name__c != NULL && proposal.Pricelist_Name__c.contains('CH') && userDivsion == 'MEP'){
            userDivsion += 'CH';
        }
        List<Attachment> attachlist=new List<Attachment>();
        attachlist=[select id,Name,ContentType,Body,BodyLength,LastModifieddate from attachment where Parentid =: quoteId];
        AttWrapList = new List<AttachmentWrapper>();
        for(Attachment a : attachlist){
            AttachmentWrapper attObj = new AttachmentWrapper();
            attObj.att = a;
            attObj.attID = a.ID;
            AttWrapList.add(attObj);
        }
        try{
            //Code for Decryption
            Blob b64decoded=EncodingUtil.base64Decode(Admin_User_Config__c.getAll().get('Admin').Token__c);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', blob.valueOf('12345678912345678912345678912345'),b64decoded);
            system.debug('----Decryption------'+decryptedData.tostring());
        
            partnerSoapSforceCom_v1 temp = new partnerSoapSforceCom_v1();
            partnerSoapSforceCom_v1.Soap soap = new partnerSoapSforceCom_v1.soap();
            partnerSoapSforceCom_v1.LoginResult result =  soap.login(Admin_User_Config__c.getAll().get('Admin').User_Name__c,decryptedData.tostring());
            system.debug('---------------' + result.sessionId);
            sessionId = result.sessionId;
        }catch(Exception ex){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage());
            ApexPages.addMessage(msg); 
        }
        system.debug('---------------' + sessionId);
    }
    
    public void assignSessionId(){
        system.debug('------sessionId---------' + sessionId);
    }
    Public Pagereference gotoPresent(){
        if(Proposal_Template_Config__c.getAll().get(userDivsion) != null){
            proposalConfigObj = Proposal_Template_Config__c.getAll().get(userDivsion);
            List<Document> docList = new List<Document>();
            docNameList = new List<String>();
            Document doc;
            integer cnt = 1;
            for(AttachmentWrapper ass : AttWrapList){
                if(ass.checked){
                    String str = (proposalConfigObj.Temp_Document_Prefix__c == null ? 'Proposal_' : proposalConfigObj.Temp_Document_Prefix__c + '_')  + generateRandomNumber() + '_' + cnt;
                    doc = new Document();
                    doc.AuthorId = userinfo.getUserId();
                    doc.DeveloperName = str;
                    if(ass.att.Name.length() <= 80){
                        doc.Name = ass.att.Name;
                    }else{
                        doc.Name = ass.att.Name.subString(0,78) + '..';
                    }
                    docNameList.add(proposalConfigObj.Temp_Folder_for_Document__c + '/' + str);
                    doc.FolderId = [select Id from Folder where DeveloperName =: proposalConfigObj.Temp_Folder_for_Document__c].Id;
                    doc.Body = ass.att.Body;
                    doc.contentType = ass.att.contentType;
                    cnt++;
                    docList.add(doc);
                }
            }
            boolean flag = false;
            try{
                Database.insert(doclist);
            }catch(Exception ex){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage());
                ApexPages.addMessage(msg); 
            }
    
        
        }else{
            //proposalConfigObj = Proposal_Template_Config__c.getAll().get('Default');
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Please set User Division value in User Personal setting.');
            ApexPages.addMessage(msg);
        }
                
        return null;
    }
    
    public String generateRandomNumber(){
        return date.today().year() + '' + date.today().month() + '' + date.today().day() + '' + system.now().hour() + '' + system.now().minute() + '' + system.now().second();
    }
    
    public boolean errorFlag{get;set;}
    public pagereference createEmailTemplate(){
        system.debug('---------------' + sessionId);
        String templateName = (proposalConfigObj.Temp_Email_Template_Prefix__c == null ? 'Proposal_' : proposalConfigObj.Temp_Email_Template_Prefix__c + '_')  + generateRandomNumber();
        MetadataServiceExamples.sessionId = sessionId;
        MetadataServiceExamples.createEmailTemplate(proposalConfigObj.Email_Template__c,templateName, 
                 proposalConfigObj.Temp_Folder_for_Email_Template__c ,proposalConfigObj.Letterhead__c ,docNameList);
        Id templateId;
        for(EmailTemplate temp : [select Id from EmailTemplate where DeveloperNAme =: templateName limit 1]){
            templateId = temp.Id;
        }
        Pagereference pg;
        if(templateId != null){
            String toAddress = (proposalConfigObj.To_Address__c == null ? '' : proposalConfigObj.To_Address__c);
            String ccAddress = (proposalConfigObj.CC_Address__c == null ? '' : proposalConfigObj.CC_Address__c);
            pg = new Pagereference('/_ui/core/email/author/EmailAuthor?new_template=1&p3_lkid=' + quoteId 
                                             + '&tempEmailTemplateId=' + templateId + '&template_id=' + templateId 
                                            + '&p24=' + toAddress + '&p4=' +  ccAddress 
                                            + '&retURL=/apex/apttus_proposal__proposalpresentconfirm?id=' + quoteId +'%26tempEmailTemplateId='+templateId);
            errorFlag = false;
            proposal.Id = quoteId;
            proposal.Apttus_Proposal__Approval_Stage__c = 'Presented';
            update proposal;
        }else{
            pg = null; 
            errorFlag = true;
        }
        return pg;
    }
   public class AttachmentWrapper{
       public Boolean checked{ get; set; }
       public Attachment att{ get; set; }
       Public ID attID{get;set;} 
   }
}