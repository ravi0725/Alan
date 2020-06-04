/*
*****************************************************************************************
Name        : TestImportData 

---------------------------------------------------------------------------
Developer              Date            Description
Ankur Patel           2/1/2016          Created
*****************************************************************************************
*/

@isTest(seeAllData=true)
private class TestImportData {
    static testmethod void TestImportData1(){
        GenerateTestData.createAccountImportData();
        GenerateTestData.importDataAccAttachment();
        
        apexpages.currentpage().getparameters().put('id' , GenerateTestData.idcAcc.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(GenerateTestData.idcAcc);
        ImportDataController idCtrl= new ImportDataController(sc);
        idCtrl.attachmentId = GenerateTestData.impDtAccAttach.Id;
        idCtrl.validateHeader();
        idCtrl.resetStatus();
    }
    
    static testmethod void TestImportData2(){
        GenerateTestData.createAddressImportData();
        GenerateTestData.importDataAdrsAttachment();
        
        apexpages.currentpage().getparameters().put('id' , GenerateTestData.idcAdrs.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(GenerateTestData.idcAdrs);
        ImportDataController idCtrl= new ImportDataController(sc);
        idCtrl.attachmentId = GenerateTestData.impDtAdrsAttach.Id;
        idCtrl.validateHeader();
        idCtrl.resetStatus();
    }
    
    static testmethod void TestImportData(){
        GenerateTestData.createAccountImportData();
        GenerateTestData.importDataAccAttachment();
        Attachment att = GenerateTestData.impDtAccAttach;
        att.body = Blob.valueOf('Test__c,'+att.body.toString());
        update att;
        
        apexpages.currentpage().getparameters().put('id' , GenerateTestData.idcAcc.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(GenerateTestData.idcAcc);
        ImportDataController idCtrl= new ImportDataController(sc);
        idCtrl.attachmentId = att.Id;
        idCtrl.validateHeader();
        idCtrl.resetStatus();
    }
    
    static testmethod void TestImportData4(){
        GenerateTestData.createAccountImportData();
        Import_Data__c imp = GenerateTestData.idcAcc;
        imp.Operation__c = 'Update';
        update imp;
        GenerateTestData.importDataAccAttachment();
        
        apexpages.currentpage().getparameters().put('id' , imp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(imp);
        ImportDataController idCtrl= new ImportDataController(sc);
        idCtrl.attachmentId = GenerateTestData.impDtAccAttach.Id;
        idCtrl.validateHeader();
        idCtrl.resetStatus();
    }
    
    static testmethod void TestImportData5(){
        GenerateTestData.createAccountImportData();
        Import_Data__c imp = GenerateTestData.idcAcc;
        imp.Operation__c = 'Delete';
        update imp;
        GenerateTestData.importDataAccAttachment();
        
        apexpages.currentpage().getparameters().put('id' , imp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(imp);
        ImportDataController idCtrl= new ImportDataController(sc);
        idCtrl.attachmentId = GenerateTestData.impDtAccAttach.Id;
        idCtrl.validateHeader();
        idCtrl.resetStatus();
    } 
    
    /*static testmethod void TestImportData5(){
        GenerateTestData.createImportData();
        Import_Data__c imp = GenerateTestData.idc;
        imp.Operation__c = 'Upsert';
        update imp;
        GenerateTestData.importDataAttachment();
        
        apexpages.currentpage().getparameters().put('id' , imp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(imp);
        ImportDataController idCtrl= new ImportDataController(sc);
        idCtrl.attachmentId = GenerateTestData.impDtAttach.Id;
        idCtrl.validateHeader();
        idCtrl.resetStatus();
    }*/
}