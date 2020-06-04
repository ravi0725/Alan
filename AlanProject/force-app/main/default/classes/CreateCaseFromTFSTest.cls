/*****************************************************************************************
Name    : CreateCaseFromTFSTest 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
P M Mamata       04/08/2015          Created
******************************************************************************************/
@isTest(seealldata=true)

private class CreateCaseFromTFSTest {
    static testmethod void createCaseMeth(){
        CaseHandler.launchControl.put('callTFS',1);
        AttachmentListner.launchControl.put('callTFS', 1);
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();
        GenerateTestData.createdefectCase();
        GenerateTestData.createCase();        
        GenerateTestData.createcaseAttachment();
        CreateCaseFromTFS.RequestCaseData rcd = new CreateCaseFromTFS.RequestCaseData();
        List<CreateCaseFromTFS.RequestCaseData> caseList = new List<CreateCaseFromTFS.RequestCaseData>();
        rcd.TFSId = '12345';
        rcd.Status = 'test';
        rcd.CaseNumber = 'test case number';   
        rcd.AssignTo = 'test assign to';
        rcd.AssignedDate = date.today() + '';
        rcd.Notes = 'test notes';
        rcd.ResolutionType = 'test resolution type';
        rcd.ResolutionNotes = 'test resolution notes';
        rcd.PrivateNotes = 'test private notes';
        rcd.FixedInBuild = 'test fixedin build';
        rcd.Subject = 'test subject';
        rcd.Type = 'test type';
                        
        caseList.add(rcd);        
       
        CreateCaseFromTFS cs = new CreateCaseFromTFS();
        CreateCaseFromTFS.test_bl = true;
        CreateCaseFromTFS.CreateCase(caseList);  
        CreateCaseFromTFS.test_bl = false;
        CreateCaseFromTFS.CreateCase(caseList);  
        
        
    }
    
    static testmethod void createCaseMeth1(){
        CaseHandler.launchControl.put('callTFS',1);
        AttachmentListner.launchControl.put('callTFS', 1);
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();
        GenerateTestData.createdefectCase();
        GenerateTestData.createCase();        
        GenerateTestData.createcaseAttachment();
        CreateCaseFromTFS.RequestCaseData rcd = new CreateCaseFromTFS.RequestCaseData();
        List<CreateCaseFromTFS.RequestCaseData> caseList = new List<CreateCaseFromTFS.RequestCaseData>();
        rcd.TFSId = null;
        rcd.Status = 'test';
        System.debug('=========GenerateTestData.dcs.Id=========='+GenerateTestData.dcs.Id);
        rcd.CaseNumber = [SELECT CaseNumber FROM Case WHERE Id =: GenerateTestData.dcs.Id].CaseNumber; 
        System.debug('=========rcd.CaseNumber============'+rcd.CaseNumber);
        rcd.AssignTo = 'test assign to';
        rcd.AssignedDate = date.today() + '';
        rcd.Notes = 'test notes';
        rcd.ResolutionType = 'test resolution type';
        rcd.ResolutionNotes = 'test resolution notes';
        rcd.PrivateNotes = 'test private notes';
        rcd.FixedInBuild = 'test fixedin build';
        rcd.Subject = 'test subject';
        rcd.Type = 'test type';
        rcd.attribute1 = 'test1';
        rcd.attribute2 = 'test1';
        rcd.attribute3 = 'test1';
        rcd.attribute4 = 'test1';
        rcd.attribute5 = 'test1';
        rcd.attribute6 = 'test1';
        rcd.attribute7 = 'test1';
        rcd.attribute8 = 'test1';
        rcd.attribute9 = 'test1';
        rcd.attribute10 = 'test1';          
        caseList.add(rcd);        
       
        CreateCaseFromTFS cs = new CreateCaseFromTFS();
        CreateCaseFromTFS.test_bl = true;
        CreateCaseFromTFS.CreateCase(caseList);  
        CreateCaseFromTFS.test_bl = false;
        CreateCaseFromTFS.CreateCase(caseList);  
        
        
    }
    
    static testmethod void createCaseMeth2(){
        CaseHandler.launchControl.put('callTFS',1);
        AttachmentListner.launchControl.put('callTFS', 1);
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();
        GenerateTestData.createdefectCase();
        GenerateTestData.createCase();        
        GenerateTestData.createcaseAttachment();
        CreateCaseFromTFS.RequestCaseData rcd = new CreateCaseFromTFS.RequestCaseData();
        List<CreateCaseFromTFS.RequestCaseData> caseList = new List<CreateCaseFromTFS.RequestCaseData>();
        rcd.TFSId = '';
        rcd.Status = 'test';
        System.debug('=========GenerateTestData.dcs.Id=========='+GenerateTestData.dcs.Id);
        rcd.CaseNumber = null;
        System.debug('=========rcd.CaseNumber============'+rcd.CaseNumber);
        rcd.AssignTo = 'test assign to';
        rcd.AssignedDate = date.today() + '';
        rcd.Notes = 'test notes';
        rcd.ResolutionType = 'test resolution type';
        rcd.ResolutionNotes = 'test resolution notes';
        rcd.PrivateNotes = 'test private notes';
        rcd.FixedInBuild = 'test fixedin build';
        rcd.Subject = 'test subject';
        rcd.Type = 'test type';
                       
        caseList.add(rcd);        
       
        CreateCaseFromTFS cs = new CreateCaseFromTFS();
        CreateCaseFromTFS.test_bl = false;
        CreateCaseFromTFS.CreateCase(caseList);  
        CreateCaseFromTFS.test_bl = true;
        CreateCaseFromTFS.CreateCase(caseList);  
        
        
    }
    
    
    static testmethod void testcallout(){
        CaseHandler.launchControl.put('callTFS',1);
        AttachmentListner.launchControl.put('callTFS', 1);
        GenerateTestData.createAccount();
        GenerateTestData.createContact();
        GenerateTestData.createParentCase();
        GenerateTestData.createdefectCase();
        GenerateTestData.createCase();        
        GenerateTestData.createcaseAttachment();
        
        CreateCaseFromTFS.RequestAttachmentData rad = new CreateCaseFromTFS.RequestAttachmentData();
        rad.TFSId = '12345';
        rad.AttachmentName = 'testattachmentname.nametestattachment';
        rad.AttachmentBody = 'attachmentbody';
        rad.ContentType = 'test contenttype';
        rad.AttachmentDescription = 'test attachment description';
        
        
        CreateCaseFromTFS.CreateAttachment(rad);
        
        rad = new CreateCaseFromTFS.RequestAttachmentData();
        rad.TFSId = '11-899';
        rad.AttachmentName = 'testattachmentname.nametestattachment';
        rad.AttachmentBody = 'attachmentbody';
        rad.ContentType = 'test contenttype';
        rad.AttachmentDescription = 'test attachment description';
        CreateCaseFromTFS.CreateAttachment(rad);
    }
    
        
}