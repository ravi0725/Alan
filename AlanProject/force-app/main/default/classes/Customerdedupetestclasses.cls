/*****************************************************************************************
  Name    : Customerdedupetestclasses
  Desc    : Test class for all Customer dedupe related classes 
 
  Modification Log :
  ---------------------------------------------------------------------------
  Developer              Date            Description
  ---------------------------------------------------------------------------
  Prince Leo           03/04/2018          Created
 ******************************************************************************************/
@isTest
public class Customerdedupetestclasses{
    static testmethod void CustomerdedupetestclassesMeth(){
        
        //Create Dedupe Master 
        Dedupe_Master__c Dm = new Dedupe_Master__c();
        Dm.Save_Point__c =2;
        insert Dm;
        
        //Create Dedupe Account 
        Dedupe_Account__c DAcc = new Dedupe_Account__c();
        DAcc.Dedupe_Master__c = Dm.id;
        DAcc.Bill_To_Cust_Invoice_Count__c = 75;
        DAcc.Cust_Account_ID__c ='Test1234';
        DAcc.Customer_Name__c ='Test123';
        DAcc.Customer_Name_Match_Percentage__c =100;
        DAcc.Gen_Cust_Customer_ID__c ='Test123';
        DAcc.Legacy_Customer_ID__c = 'Test123';
        DAcc.Oracle_Account_Number__c ='Test123';
        DAcc.Oracle_Customer_Name__c ='Test123'; 
        DAcc.Party_ID__c = 'Test123';
        DAcc.Payment_Term__c = 'Test123';
        DAcc.Process_Flag__c ='X';
        DAcc.Profile_Amount__c ='Test123';
        DAcc.Record_ID__c ='12345';
        DAcc.Request_ID__c = 'Test123';
        DAcc.Addl_Column_1__c ='Test123';
        DAcc.Addl_Column_2__c ='Test123';
        DAcc.Addl_Column_3__c = 'Test123';
        DAcc.Addl_Column_4__c = 'Test123';
        DAcc.Addl_Column_5__c = 'Test123';
        DAcc.Addl_Column_6__c = 'Test123';
        DAcc.Addl_Column_7__c = 'Test123';
        DAcc.Addl_Column_8__c = 'Test123';
        DAcc.Addl_Column_9__c = 'Test123';
        DAcc.Addl_Column_10__c = 'Test123';
        DAcc.Addl_Column_11__c = 'Test123';
        DAcc.Addl_Column_12__c = 'Test123';
        DAcc.Addl_Column_13__c = 'Test123';
        DAcc.Addl_Column_14__c = 'Test123';
        DAcc.Addl_Column_15__c = 'Test123';
        DAcc.Addl_Column_16__c = 'Test123';
        DAcc.Addl_Column_17__c = 'Test123';
        DAcc.Addl_Column_18__c = 'Test123';
        DAcc.Addl_Column_19__c = 'Test123';
        insert DAcc;
        
        //Create Dedupe Address
        Dedupe_Address__c DArr = new Dedupe_Address__c();
        DArr.Dedupe_Master__c = Dm.id;
        DArr.Bill_To_Addr_Invoice_Count__c = 75;
        DArr.Cust_Account_ID__c = 'Test1234';
        DArr.Cust_Acct_Site_ID__c = 'Test1234';
        DArr.Customer_Addr_Match_Percentage__c =100;
        DArr.Gen_Cust_Address_ID__c ='Test1234';
        DArr.Gen_Cust_Customer_ID__c = 'Test1234';
        DArr.Legacy_Address_ID__c = 'Test1234';
        DArr.Legacy_Customer_ID__c = 'Test1234';
        DArr.Location_ID__c = 'Test1234';
        DArr.Oracle_address1__c = 'Test1234';
        DArr.Oracle_Address2__c = 'Test1234';
        DArr.Oracle_Address3__c = 'Test1234';
        DArr.Oracle_Address4__c = 'Test1234';
        DArr.Oracle_City__c = 'Test1234';
        DArr.Oracle_Country__c = 'Test1234';
        DArr.Oracle_County__c = 'Test1234';
        DArr.Oracle_Postal_Code__c = 'Test1234';
        DArr.Oracle_State__c = 'Test1234';
        DArr.Org_Id__c = 'Test1234';
        DArr.Party_Site_ID__c = 'Test1234';
        DArr.Party_Site_Number__c = 'Test1234';
        DArr.Process_Flag__c = 'X';
        DArr.Record_ID__c ='12345';
        DArr.Request_ID__c = 'Test1234';
        DArr.Addl_Column_1__c = 'Test1234';
        DArr.Addl_Column_2__c = 'Test1234';
        DArr.Addl_Column_3__c = 'Test1234';
        DArr.Addl_Column_4__c = 'Test1234';
        DArr.Addl_Column_5__c = 'Test1234';
        DArr.Addl_Column_6__c = 'Test1234';
        DArr.Addl_Column_7__c = 'Test1234';
        DArr.Addl_Column_8__c = 'Test1234';
        DArr.Addl_Column_9__c = 'Test1234';
        DArr.Addl_Column_10__c = 'Test1234';
        DArr.Addl_Column_11__c = 'Test1234';
        DArr.Addl_Column_12__c = 'Test1234';
        DArr.Addl_Column_13__c = 'Test1234';
        DArr.Addl_Column_14__c = 'Test1234';
        DArr.Addl_Column_15__c = 'Test1234';
        DArr.Addl_Column_16__c = 'Test1234';
        DArr.Addl_Column_17__c = 'Test1234';
        DArr.Addl_Column_18__c = 'Test1234';
        DArr.Addl_Column_19__c = 'Test1234';
        DArr.Addl_Column_20__c = 'Test1234';
        insert DArr;
        
        //Create Customer Dedupe
        Customer_Dup_Check__c Cdc = new Customer_Dup_Check__c();
        Cdc.Dedupe_Master__c = Dm.id;
        cdc.Record_ID__c ='12345';
        Cdc.Address_1__c = 'Test1234';
        Cdc.Address_2__c ='Test1234';
        Cdc.Address_3__c = 'Test1234';
        Cdc.Address_4__c = 'Test1234';
        Cdc.City__c = 'Test1234';
        Cdc.Country__c = 'Test1234';
        Cdc.County__c = 'Test1234';
        Cdc.Customer_Name__c ='Test1234';
        Cdc.Dedup_Program_Request_ID__c ='Test1234'; 
        Cdc.Derived_Org_ID__c ='Test1234';
        Cdc.File_Name__c = 'Test1234';
        Cdc.Gen_Cust_Address_ID__c = 'Test1234';
        Cdc.Gen_Cust_Customer_ID__c = 'Test1234';
        Cdc.Legacy_Address_ID__c = 'Test1234';
        Cdc.Legacy_Customer_ID__c = 'Test1234';
        Cdc.Load_Request_ID__c = 'Test1234';
        Cdc.New_Oracle_Account_Number__c = 'Test1234';
        Cdc.New_Oracle_Address_1__c = 'Test1234';
        Cdc.New_Oracle_Address_2__c = 'Test1234';
        Cdc.New_Oracle_City__c = 'Test1234';
        Cdc.New_Oracle_Country__c = 'Test1234';
        Cdc.New_Oracle_County__c =  'Test1234';
        Cdc.New_Oracle_Customer_Name__c = 'Test1234';
        Cdc.New_Oracle_Postal_Code__c = 'Test1234';
        Cdc.New_Oracle_State__c = 'Test1234';
        Cdc.Postal_Code__c = 'Test1234';
        Cdc.Process_Flag__c ='X';
        Cdc.Project_Name__c = 'Test1234';
        Cdc.State__c = 'Test1234';
        
        insert cdc;
        
        PageReference pageRef = Page.AutoFillPage;

        pageRef.getparameters().put('id', Dm.id);  

        Test.setCurrentPage(pageRef);

        Apexpages.StandardController sc = new Apexpages.StandardController(Dm);

        AutofillValues ext = new  AutofillValues(sc);         

        ext.UpdateDedupemaster();      

        
       /* ApexPages.StandardController sc = new ApexPages.StandardController(Dm);
        AutofillValues apc = new AutofillValues(sc);
        System.currentPageReference().getParameters().put('id', Dm.Id);
        //AutofillValues apc = new AutofillValues();
        
        apc.UpdateDedupemaster();*/
        
        AutofillValuesSpecialScenario avss = new AutofillValuesSpecialScenario(sc);
        System.currentPageReference().getParameters().put('id', Dm.Id); 
        avss.UpdateDedupemaster();
        
        Attachment attach= new Attachment();   
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.ParentId = Dm.id;  
        insert attach;
        
        ReadDedupeCsvController rdcc = new ReadDedupeCsvController(sc);
        ReadDedupeCsvController.blobToString(attach.Body, 'ISO-8859-1');
        rdcc.validateHeader();
        
        ReadCsvBulkModeController rcbmc = new ReadCsvBulkModeController(sc);
        rcbmc.attachmentId = attach.Id;
        rcbmc.validateHeader();
        rcbmc.DeleteAll();
        rcbmc.Done();
        
    }
    
    static testmethod void CustomerdedupetestclassesMeth2(){
        
        //Create Dedupe Master 
        Dedupe_Master__c Dm = new Dedupe_Master__c();
        Dm.Save_Point__c =2;
        insert Dm;
        
        //Create Dedupe Account 
        Dedupe_Account__c DAcc = new Dedupe_Account__c();
        DAcc.Dedupe_Master__c = Dm.id;
        DAcc.Bill_To_Cust_Invoice_Count__c = 75;
        DAcc.Cust_Account_ID__c ='Test123';
        DAcc.Customer_Name__c ='Test123';
        DAcc.Customer_Name_Match_Percentage__c =100;
        DAcc.Gen_Cust_Customer_ID__c ='Test123';
        DAcc.Legacy_Customer_ID__c = 'Test123';
        DAcc.Oracle_Account_Number__c ='Test123';
        DAcc.Oracle_Customer_Name__c ='Test123'; 
        DAcc.Party_ID__c = 'Test123';
        DAcc.Payment_Term__c = 'Test123';
        DAcc.Process_Flag__c ='X';
        DAcc.Profile_Amount__c ='Test123';
        DAcc.Record_ID__c ='12345';
        DAcc.Request_ID__c = 'Test123';
        DAcc.Addl_Column_1__c ='Test123';
        DAcc.Addl_Column_2__c ='Test123';
        DAcc.Addl_Column_3__c = 'Test123';
        DAcc.Addl_Column_4__c = 'Test123';
        DAcc.Addl_Column_5__c = 'Test123';
        DAcc.Addl_Column_6__c = 'Test123';
        DAcc.Addl_Column_7__c = 'Test123';
        DAcc.Addl_Column_8__c = 'Test123';
        DAcc.Addl_Column_9__c = 'Test123';
        DAcc.Addl_Column_10__c = 'Test123';
        DAcc.Addl_Column_11__c = 'Test123';
        DAcc.Addl_Column_12__c = 'Test123';
        DAcc.Addl_Column_13__c = 'Test123';
        DAcc.Addl_Column_14__c = 'Test123';
        DAcc.Addl_Column_15__c = 'Test123';
        DAcc.Addl_Column_16__c = 'Test123';
        DAcc.Addl_Column_17__c = 'Test123';
        DAcc.Addl_Column_18__c = 'Test123';
        DAcc.Addl_Column_19__c = 'Test123';
        insert DAcc;
        
        //Create Dedupe Address
        Dedupe_Address__c DArr = new Dedupe_Address__c();
        DArr.Dedupe_Master__c = Dm.id;
        DArr.Bill_To_Addr_Invoice_Count__c = 75;
        DArr.Cust_Account_ID__c = 'Test1234';
        DArr.Cust_Acct_Site_ID__c = 'Test1234';
        DArr.Customer_Addr_Match_Percentage__c =100;
        DArr.Gen_Cust_Address_ID__c ='Test1234';
        DArr.Gen_Cust_Customer_ID__c = 'Test1234';
        DArr.Legacy_Address_ID__c = 'Test1234';
        DArr.Legacy_Customer_ID__c = 'Test1234';
        DArr.Location_ID__c = 'Test1234';
        DArr.Oracle_address1__c = 'Test1234';
        DArr.Oracle_Address2__c = 'Test1234';
        DArr.Oracle_Address3__c = 'Test1234';
        DArr.Oracle_Address4__c = 'Test1234';
        DArr.Oracle_City__c = 'Test1234';
        DArr.Oracle_Country__c = 'Test1234';
        DArr.Oracle_County__c = 'Test1234';
        DArr.Oracle_Postal_Code__c = 'Test1234';
        DArr.Oracle_State__c = 'Test1234';
        DArr.Org_Id__c = 'Test1234';
        DArr.Party_Site_ID__c = 'Test1234';
        DArr.Party_Site_Number__c = 'Test1234';
        DArr.Process_Flag__c = 'X';
        DArr.Record_ID__c ='12345';
        DArr.Request_ID__c = 'Test1234';
        DArr.Addl_Column_1__c = 'Test1234';
        DArr.Addl_Column_2__c = 'Test1234';
        DArr.Addl_Column_3__c = 'Test1234';
        DArr.Addl_Column_4__c = 'Test1234';
        DArr.Addl_Column_5__c = 'Test1234';
        DArr.Addl_Column_6__c = 'Test1234';
        DArr.Addl_Column_7__c = 'Test1234';
        DArr.Addl_Column_8__c = 'Test1234';
        DArr.Addl_Column_9__c = 'Test1234';
        DArr.Addl_Column_10__c = 'Test1234';
        DArr.Addl_Column_11__c = 'Test1234';
        DArr.Addl_Column_12__c = 'Test1234';
        DArr.Addl_Column_13__c = 'Test1234';
        DArr.Addl_Column_14__c = 'Test1234';
        DArr.Addl_Column_15__c = 'Test1234';
        DArr.Addl_Column_16__c = 'Test1234';
        DArr.Addl_Column_17__c = 'Test1234';
        DArr.Addl_Column_18__c = 'Test1234';
        DArr.Addl_Column_19__c = 'Test1234';
        DArr.Addl_Column_20__c = 'Test1234';
        insert DArr;
        
        //Create Customer Dedupe
        Customer_Dup_Check__c Cdc = new Customer_Dup_Check__c();
        Cdc.Dedupe_Master__c = Dm.id;
        cdc.Record_ID__c ='12345';
        Cdc.Address_1__c = 'Test1234';
        Cdc.Address_2__c ='Test1234';
        Cdc.Address_3__c = 'Test1234';
        Cdc.Address_4__c = 'Test1234';
        Cdc.City__c = 'Test1234';
        Cdc.Country__c = 'Test1234';
        Cdc.County__c = 'Test1234';
        Cdc.Customer_Name__c ='Test1234';
        Cdc.Dedup_Program_Request_ID__c ='Test1234'; 
        Cdc.Derived_Org_ID__c ='Test1234';
        Cdc.File_Name__c = 'Test1234';
        Cdc.Gen_Cust_Address_ID__c = 'Test1234';
        Cdc.Gen_Cust_Customer_ID__c = 'Test1234';
        Cdc.Legacy_Address_ID__c = 'Test1234';
        Cdc.Legacy_Customer_ID__c = 'Test1234';
        Cdc.Load_Request_ID__c = 'Test1234';
        Cdc.New_Oracle_Account_Number__c = 'Test1234';
        Cdc.New_Oracle_Address_1__c = 'Test1234';
        Cdc.New_Oracle_Address_2__c = 'Test1234';
        Cdc.New_Oracle_City__c = 'Test1234';
        Cdc.New_Oracle_Country__c = 'Test1234';
        Cdc.New_Oracle_County__c =  'Test1234';
        Cdc.New_Oracle_Customer_Name__c = 'Test1234';
        Cdc.New_Oracle_Postal_Code__c = 'Test1234';
        Cdc.New_Oracle_State__c = 'Test1234';
        Cdc.Postal_Code__c = 'Test1234';
        Cdc.Process_Flag__c ='X';
        Cdc.Project_Name__c = 'Test1234';
        Cdc.State__c = 'Test1234';
        Cdc.Cust_Account_ID__c = DAcc.Cust_Account_ID__c;
        Cdc.Cust_Acct_Site_ID__c = DArr.Cust_Acct_Site_ID__c;
        insert Cdc;
        
        Customer_Dup_Check__c Cdc1 = new Customer_Dup_Check__c();
        Cdc1.Dedupe_Master__c = Dm.id;
        cdc1.Record_ID__c ='12345';
        Cdc1.Address_1__c = 'Test1234';
        Cdc1.Address_2__c ='Test1234';
        Cdc1.Address_3__c = 'Test1234';
        Cdc1.Address_4__c = 'Test1234';
        Cdc1.City__c = 'Test1234';
        Cdc1.Country__c = 'Test1234';
        Cdc1.County__c = 'Test1234';
        Cdc1.Customer_Name__c ='Test1234';
        Cdc1.Dedup_Program_Request_ID__c ='Test1234'; 
        Cdc1.Derived_Org_ID__c ='Test1234';
        Cdc1.File_Name__c = 'Test1234';
        Cdc1.Gen_Cust_Address_ID__c = 'Test1234';
        Cdc1.Gen_Cust_Customer_ID__c = 'Test1234';
        Cdc1.Legacy_Address_ID__c = 'Test1234';
        Cdc1.Legacy_Customer_ID__c = 'Test1234';
        Cdc1.Load_Request_ID__c = 'Test1234';
        Cdc1.New_Oracle_Account_Number__c = 'Test1234';
        Cdc1.New_Oracle_Address_1__c = 'Test1234';
        Cdc1.New_Oracle_Address_2__c = 'Test1234';
        Cdc1.New_Oracle_City__c = 'Test1234';
        Cdc1.New_Oracle_Country__c = 'Test1234';
        Cdc1.New_Oracle_County__c =  'Test1234';
        Cdc1.New_Oracle_Customer_Name__c = 'Test1234';
        Cdc1.New_Oracle_Postal_Code__c = 'Test1234';
        Cdc1.New_Oracle_State__c = 'Test1234';
        Cdc1.Postal_Code__c = 'Test1234';
        Cdc1.Process_Flag__c ='X';
        Cdc1.Project_Name__c = 'Test1234';
        Cdc1.State__c = 'Test1234';
        Cdc1.Cust_Account_ID__c = DAcc.Cust_Account_ID__c;
        Cdc1.Cust_Acct_Site_ID__c = DArr.Cust_Acct_Site_ID__c;
        insert cdc1;

        System.currentPageReference().getParameters().put('masterRecordId', Dm.Id);
        System.currentPageReference().getParameters().put('recordId', Cdc.Record_ID__c);
        
        CustomerDuplicateCheckController cdcc = new CustomerDuplicateCheckController();
        cdcc.SetSavePoint();
        cdcc.showaddress();
        cdcc.previous();
        cdcc.next();
        cdcc.save();
        cdcc.setSelectedValue();
        
        /*CustomerDuplicateCheckWithSavepointCtrl  cdcwspc = new CustomerDuplicateCheckWithSavepointCtrl();
        cdcwspc.SetSavePoint();
        cdcwspc.showaddress();
        cdcwspc.previous();
        cdcwspc.next();
        cdcwspc.save();
        cdcwspc.setSelectedValue();*/
    }
    
    static testmethod void CustomerdedupetestclassesMeth3(){
        
        //Create Dedupe Master 
        Dedupe_Master__c Dm = new Dedupe_Master__c();
        Dm.Save_Point__c =2;
        insert Dm;
        
        //Create Dedupe Account 
        Dedupe_Account__c DAcc = new Dedupe_Account__c();
        DAcc.Dedupe_Master__c = Dm.id;
        DAcc.Bill_To_Cust_Invoice_Count__c = 75;
        DAcc.Cust_Account_ID__c ='Test123';
        DAcc.Customer_Name__c ='Test123';
        DAcc.Customer_Name_Match_Percentage__c =100;
        DAcc.Gen_Cust_Customer_ID__c ='Test123';
        DAcc.Legacy_Customer_ID__c = 'Test123';
        DAcc.Oracle_Account_Number__c ='Test123';
        DAcc.Oracle_Customer_Name__c ='Test123'; 
        DAcc.Party_ID__c = 'Test123';
        DAcc.Payment_Term__c = 'Test123';
        DAcc.Process_Flag__c ='X';
        DAcc.Profile_Amount__c ='Test123';
        DAcc.Record_ID__c ='12345';
        DAcc.Request_ID__c = 'Test123';
        DAcc.Addl_Column_1__c ='Test123';
        DAcc.Addl_Column_2__c ='Test123';
        DAcc.Addl_Column_3__c = 'Test123';
        DAcc.Addl_Column_4__c = 'Test123';
        DAcc.Addl_Column_5__c = 'Test123';
        DAcc.Addl_Column_6__c = 'Test123';
        DAcc.Addl_Column_7__c = 'Test123';
        DAcc.Addl_Column_8__c = 'Test123';
        DAcc.Addl_Column_9__c = 'Test123';
        DAcc.Addl_Column_10__c = 'Test123';
        DAcc.Addl_Column_11__c = 'Test123';
        DAcc.Addl_Column_12__c = 'Test123';
        DAcc.Addl_Column_13__c = 'Test123';
        DAcc.Addl_Column_14__c = 'Test123';
        DAcc.Addl_Column_15__c = 'Test123';
        DAcc.Addl_Column_16__c = 'Test123';
        DAcc.Addl_Column_17__c = 'Test123';
        DAcc.Addl_Column_18__c = 'Test123';
        DAcc.Addl_Column_19__c = 'Test123';
        insert DAcc;
        
        //Create Dedupe Address
        Dedupe_Address__c DArr = new Dedupe_Address__c();
        DArr.Dedupe_Master__c = Dm.id;
        DArr.Bill_To_Addr_Invoice_Count__c = 75;
        DArr.Cust_Account_ID__c = 'Test1234';
        DArr.Cust_Acct_Site_ID__c = 'Test1234';
        DArr.Customer_Addr_Match_Percentage__c =100;
        DArr.Gen_Cust_Address_ID__c ='Test1234';
        DArr.Gen_Cust_Customer_ID__c = 'Test1234';
        DArr.Legacy_Address_ID__c = 'Test1234';
        DArr.Legacy_Customer_ID__c = 'Test1234';
        DArr.Location_ID__c = 'Test1234';
        DArr.Oracle_address1__c = 'Test1234';
        DArr.Oracle_Address2__c = 'Test1234';
        DArr.Oracle_Address3__c = 'Test1234';
        DArr.Oracle_Address4__c = 'Test1234';
        DArr.Oracle_City__c = 'Test1234';
        DArr.Oracle_Country__c = 'Test1234';
        DArr.Oracle_County__c = 'Test1234';
        DArr.Oracle_Postal_Code__c = 'Test1234';
        DArr.Oracle_State__c = 'Test1234';
        DArr.Org_Id__c = 'Test1234';
        DArr.Party_Site_ID__c = 'Test1234';
        DArr.Party_Site_Number__c = 'Test1234';
        DArr.Process_Flag__c = 'X';
        DArr.Record_ID__c ='12345';
        DArr.Request_ID__c = 'Test1234';
        DArr.Addl_Column_1__c = 'Test1234';
        DArr.Addl_Column_2__c = 'Test1234';
        DArr.Addl_Column_3__c = 'Test1234';
        DArr.Addl_Column_4__c = 'Test1234';
        DArr.Addl_Column_5__c = 'Test1234';
        DArr.Addl_Column_6__c = 'Test1234';
        DArr.Addl_Column_7__c = 'Test1234';
        DArr.Addl_Column_8__c = 'Test1234';
        DArr.Addl_Column_9__c = 'Test1234';
        DArr.Addl_Column_10__c = 'Test1234';
        DArr.Addl_Column_11__c = 'Test1234';
        DArr.Addl_Column_12__c = 'Test1234';
        DArr.Addl_Column_13__c = 'Test1234';
        DArr.Addl_Column_14__c = 'Test1234';
        DArr.Addl_Column_15__c = 'Test1234';
        DArr.Addl_Column_16__c = 'Test1234';
        DArr.Addl_Column_17__c = 'Test1234';
        DArr.Addl_Column_18__c = 'Test1234';
        DArr.Addl_Column_19__c = 'Test1234';
        DArr.Addl_Column_20__c = 'Test1234';
        insert DArr;
        
        //Create Customer Dedupe
        Customer_Dup_Check__c Cdc = new Customer_Dup_Check__c();
        Cdc.Dedupe_Master__c = Dm.id;
        cdc.Record_ID__c ='12345';
        Cdc.Address_1__c = 'Test1234';
        Cdc.Address_2__c ='Test1234';
        Cdc.Address_3__c = 'Test1234';
        Cdc.Address_4__c = 'Test1234';
        Cdc.City__c = 'Test1234';
        Cdc.Country__c = 'Test1234';
        Cdc.County__c = 'Test1234';
        Cdc.Customer_Name__c ='Test1234';
        Cdc.Dedup_Program_Request_ID__c ='Test1234'; 
        Cdc.Derived_Org_ID__c ='Test1234';
        Cdc.File_Name__c = 'Test1234';
        Cdc.Gen_Cust_Address_ID__c = 'Test1234';
        Cdc.Gen_Cust_Customer_ID__c = 'Test1234';
        Cdc.Legacy_Address_ID__c = 'Test1234';
        Cdc.Legacy_Customer_ID__c = 'Test1234';
        Cdc.Load_Request_ID__c = 'Test1234';
        Cdc.New_Oracle_Account_Number__c = 'Test1234';
        Cdc.New_Oracle_Address_1__c = 'Test1234';
        Cdc.New_Oracle_Address_2__c = 'Test1234';
        Cdc.New_Oracle_City__c = 'Test1234';
        Cdc.New_Oracle_Country__c = 'Test1234';
        Cdc.New_Oracle_County__c =  'Test1234';
        Cdc.New_Oracle_Customer_Name__c = 'Test1234';
        Cdc.New_Oracle_Postal_Code__c = 'Test1234';
        Cdc.New_Oracle_State__c = 'Test1234';
        Cdc.Postal_Code__c = 'Test1234';
        Cdc.Process_Flag__c ='X';
        Cdc.Project_Name__c = 'Test1234';
        Cdc.State__c = 'Test1234';
        Cdc.Cust_Account_ID__c = DAcc.Cust_Account_ID__c;
        Cdc.Cust_Acct_Site_ID__c = DArr.Cust_Acct_Site_ID__c;
        insert Cdc;
        
        Customer_Dup_Check__c Cdc1 = new Customer_Dup_Check__c();
        Cdc1.Dedupe_Master__c = Dm.id;
        cdc1.Record_ID__c ='12345';
        Cdc1.Address_1__c = 'Test1234';
        Cdc1.Address_2__c ='Test1234';
        Cdc1.Address_3__c = 'Test1234';
        Cdc1.Address_4__c = 'Test1234';
        Cdc1.City__c = 'Test1234';
        Cdc1.Country__c = 'Test1234';
        Cdc1.County__c = 'Test1234';
        Cdc1.Customer_Name__c ='Test1234';
        Cdc1.Dedup_Program_Request_ID__c ='Test1234'; 
        Cdc1.Derived_Org_ID__c ='Test1234';
        Cdc1.File_Name__c = 'Test1234';
        Cdc1.Gen_Cust_Address_ID__c = 'Test1234';
        Cdc1.Gen_Cust_Customer_ID__c = 'Test1234';
        Cdc1.Legacy_Address_ID__c = 'Test1234';
        Cdc1.Legacy_Customer_ID__c = 'Test1234';
        Cdc1.Load_Request_ID__c = 'Test1234';
        Cdc1.New_Oracle_Account_Number__c = 'Test1234';
        Cdc1.New_Oracle_Address_1__c = 'Test1234';
        Cdc1.New_Oracle_Address_2__c = 'Test1234';
        Cdc1.New_Oracle_City__c = 'Test1234';
        Cdc1.New_Oracle_Country__c = 'Test1234';
        Cdc1.New_Oracle_County__c =  'Test1234';
        Cdc1.New_Oracle_Customer_Name__c = 'Test1234';
        Cdc1.New_Oracle_Postal_Code__c = 'Test1234';
        Cdc1.New_Oracle_State__c = 'Test1234';
        Cdc1.Postal_Code__c = 'Test1234';
        Cdc1.Process_Flag__c ='X';
        Cdc1.Project_Name__c = 'Test1234';
        Cdc1.State__c = 'Test1234';
        Cdc1.Cust_Account_ID__c = DAcc.Cust_Account_ID__c;
        Cdc1.Cust_Acct_Site_ID__c = DArr.Cust_Acct_Site_ID__c;
        insert cdc1;

        System.currentPageReference().getParameters().put('masterRecordId', Dm.Id);
        System.currentPageReference().getParameters().put('SavePoint', '1');
        
        CustomerDuplicateCheckWithSavepointCtrl  cdcwspc = new CustomerDuplicateCheckWithSavepointCtrl();
        cdcwspc.SetSavePoint();
        cdcwspc.showaddress();
        cdcwspc.previous();
        cdcwspc.next();
        cdcwspc.save();
        cdcwspc.setSelectedValue();
        
        
        string str1='select id,name from Dedupe_Address__c where Id = \'' + DArr.id + '\'';
        BatchMassDeleteRecs bmdr = new BatchMassDeleteRecs(str1);
        database.executebatch(bmdr); 
    }
    
    static testmethod void CustomerdedupetestclassesMeth4(){
        
        //Create Dedupe Master 
        Dedupe_Master__c Dm = new Dedupe_Master__c();
        Dm.Save_Point__c =2;
        insert Dm;
        
        //Create Dedupe Account 
        Dedupe_Account__c DAcc = new Dedupe_Account__c();
        DAcc.Dedupe_Master__c = Dm.id;
        DAcc.Bill_To_Cust_Invoice_Count__c = 75;
        DAcc.Cust_Account_ID__c ='Test123';
        DAcc.Customer_Name__c ='Test123';
        DAcc.Customer_Name_Match_Percentage__c =100;
        DAcc.Gen_Cust_Customer_ID__c ='Test123';
        DAcc.Legacy_Customer_ID__c = 'Test123';
        DAcc.Oracle_Account_Number__c ='Test123';
        DAcc.Oracle_Customer_Name__c ='Test123'; 
        DAcc.Party_ID__c = 'Test123';
        DAcc.Payment_Term__c = 'Test123';
        DAcc.Process_Flag__c ='X';
        DAcc.Profile_Amount__c ='Test123';
        DAcc.Record_ID__c ='12345';
        DAcc.Request_ID__c = 'Test123';
        DAcc.Addl_Column_1__c ='Test123';
        DAcc.Addl_Column_2__c ='Test123';
        DAcc.Addl_Column_3__c = 'Test123';
        DAcc.Addl_Column_4__c = 'Test123';
        DAcc.Addl_Column_5__c = 'Test123';
        DAcc.Addl_Column_6__c = 'Test123';
        DAcc.Addl_Column_7__c = 'Test123';
        DAcc.Addl_Column_8__c = 'Test123';
        DAcc.Addl_Column_9__c = 'Test123';
        DAcc.Addl_Column_10__c = 'Test123';
        DAcc.Addl_Column_11__c = 'Test123';
        DAcc.Addl_Column_12__c = 'Test123';
        DAcc.Addl_Column_13__c = 'Test123';
        DAcc.Addl_Column_14__c = 'Test123';
        DAcc.Addl_Column_15__c = 'Test123';
        DAcc.Addl_Column_16__c = 'Test123';
        DAcc.Addl_Column_17__c = 'Test123';
        DAcc.Addl_Column_18__c = 'Test123';
        DAcc.Addl_Column_19__c = 'Test123';
        insert DAcc;
        
        //Create Dedupe Address
        Dedupe_Address__c DArr = new Dedupe_Address__c();
        DArr.Dedupe_Master__c = Dm.id;
        DArr.Bill_To_Addr_Invoice_Count__c = 75;
        DArr.Cust_Account_ID__c = 'Test1234';
        DArr.Cust_Acct_Site_ID__c = 'Test1234';
        DArr.Customer_Addr_Match_Percentage__c =100;
        DArr.Gen_Cust_Address_ID__c ='Test1234';
        DArr.Gen_Cust_Customer_ID__c = 'Test1234';
        DArr.Legacy_Address_ID__c = 'Test1234';
        DArr.Legacy_Customer_ID__c = 'Test1234';
        DArr.Location_ID__c = 'Test1234';
        DArr.Oracle_address1__c = 'Test1234';
        DArr.Oracle_Address2__c = 'Test1234';
        DArr.Oracle_Address3__c = 'Test1234';
        DArr.Oracle_Address4__c = 'Test1234';
        DArr.Oracle_City__c = 'Test1234';
        DArr.Oracle_Country__c = 'Test1234';
        DArr.Oracle_County__c = 'Test1234';
        DArr.Oracle_Postal_Code__c = 'Test1234';
        DArr.Oracle_State__c = 'Test1234';
        DArr.Org_Id__c = 'Test1234';
        DArr.Party_Site_ID__c = 'Test1234';
        DArr.Party_Site_Number__c = 'Test1234';
        DArr.Process_Flag__c = 'X';
        DArr.Record_ID__c ='12345';
        DArr.Request_ID__c = 'Test1234';
        DArr.Addl_Column_1__c = 'Test1234';
        DArr.Addl_Column_2__c = 'Test1234';
        DArr.Addl_Column_3__c = 'Test1234';
        DArr.Addl_Column_4__c = 'Test1234';
        DArr.Addl_Column_5__c = 'Test1234';
        DArr.Addl_Column_6__c = 'Test1234';
        DArr.Addl_Column_7__c = 'Test1234';
        DArr.Addl_Column_8__c = 'Test1234';
        DArr.Addl_Column_9__c = 'Test1234';
        DArr.Addl_Column_10__c = 'Test1234';
        DArr.Addl_Column_11__c = 'Test1234';
        DArr.Addl_Column_12__c = 'Test1234';
        DArr.Addl_Column_13__c = 'Test1234';
        DArr.Addl_Column_14__c = 'Test1234';
        DArr.Addl_Column_15__c = 'Test1234';
        DArr.Addl_Column_16__c = 'Test1234';
        DArr.Addl_Column_17__c = 'Test1234';
        DArr.Addl_Column_18__c = 'Test1234';
        DArr.Addl_Column_19__c = 'Test1234';
        DArr.Addl_Column_20__c = 'Test1234';
        insert DArr;
        
        //Create Customer Dedupe
        Customer_Dup_Check__c Cdc = new Customer_Dup_Check__c();
        Cdc.Dedupe_Master__c = Dm.id;
        cdc.Record_ID__c ='12345';
        Cdc.Address_1__c = 'Test1234';
        Cdc.Address_2__c ='Test1234';
        Cdc.Address_3__c = 'Test1234';
        Cdc.Address_4__c = 'Test1234';
        Cdc.City__c = 'Test1234';
        Cdc.Country__c = 'Test1234';
        Cdc.County__c = 'Test1234';
        Cdc.Customer_Name__c ='Test1234';
        Cdc.Dedup_Program_Request_ID__c ='Test1234'; 
        Cdc.Derived_Org_ID__c ='Test1234';
        Cdc.File_Name__c = 'Test1234';
        Cdc.Gen_Cust_Address_ID__c = 'Test1234';
        Cdc.Gen_Cust_Customer_ID__c = 'Test1234';
        Cdc.Legacy_Address_ID__c = 'Test1234';
        Cdc.Legacy_Customer_ID__c = 'Test1234';
        Cdc.Load_Request_ID__c = 'Test1234';
        Cdc.New_Oracle_Account_Number__c = 'Test1234';
        Cdc.New_Oracle_Address_1__c = 'Test1234';
        Cdc.New_Oracle_Address_2__c = 'Test1234';
        Cdc.New_Oracle_City__c = 'Test1234';
        Cdc.New_Oracle_Country__c = 'Test1234';
        Cdc.New_Oracle_County__c =  'Test1234';
        Cdc.New_Oracle_Customer_Name__c = 'Test1234';
        Cdc.New_Oracle_Postal_Code__c = 'Test1234';
        Cdc.New_Oracle_State__c = 'Test1234';
        Cdc.Postal_Code__c = 'Test1234';
        Cdc.Process_Flag__c ='X';
        Cdc.Project_Name__c = 'Test1234';
        Cdc.State__c = 'Test1234';
        Cdc.Cust_Account_ID__c = DAcc.Cust_Account_ID__c;
        Cdc.Cust_Acct_Site_ID__c = DArr.Cust_Acct_Site_ID__c;
        insert Cdc;
        
        Customer_Dup_Check__c Cdc1 = new Customer_Dup_Check__c();
        Cdc1.Dedupe_Master__c = Dm.id;
        cdc1.Record_ID__c ='12345';
        Cdc1.Address_1__c = 'Test1234';
        Cdc1.Address_2__c ='Test1234';
        Cdc1.Address_3__c = 'Test1234';
        Cdc1.Address_4__c = 'Test1234';
        Cdc1.City__c = 'Test1234';
        Cdc1.Country__c = 'Test1234';
        Cdc1.County__c = 'Test1234';
        Cdc1.Customer_Name__c ='Test1234';
        Cdc1.Dedup_Program_Request_ID__c ='Test1234'; 
        Cdc1.Derived_Org_ID__c ='Test1234';
        Cdc1.File_Name__c = 'Test1234';
        Cdc1.Gen_Cust_Address_ID__c = 'Test1234';
        Cdc1.Gen_Cust_Customer_ID__c = 'Test1234';
        Cdc1.Legacy_Address_ID__c = 'Test1234';
        Cdc1.Legacy_Customer_ID__c = 'Test1234';
        Cdc1.Load_Request_ID__c = 'Test1234';
        Cdc1.New_Oracle_Account_Number__c = 'Test1234';
        Cdc1.New_Oracle_Address_1__c = 'Test1234';
        Cdc1.New_Oracle_Address_2__c = 'Test1234';
        Cdc1.New_Oracle_City__c = 'Test1234';
        Cdc1.New_Oracle_Country__c = 'Test1234';
        Cdc1.New_Oracle_County__c =  'Test1234';
        Cdc1.New_Oracle_Customer_Name__c = 'Test1234';
        Cdc1.New_Oracle_Postal_Code__c = 'Test1234';
        Cdc1.New_Oracle_State__c = 'Test1234';
        Cdc1.Postal_Code__c = 'Test1234';
        Cdc1.Process_Flag__c ='X';
        Cdc1.Project_Name__c = 'Test1234';
        Cdc1.State__c = 'Test1234';
        Cdc1.Cust_Account_ID__c = DAcc.Cust_Account_ID__c;
        Cdc1.Cust_Acct_Site_ID__c = DArr.Cust_Acct_Site_ID__c;
        insert cdc1;

        string str2='select id,Cust_Account_ID__c,Dedupe_Master__c,Oracle_Site_Reference__C,Process_Flag__c,Cust_Acct_Site_ID__c,Record_ID__c,New_Oracle_Address_1__c,New_Oracle_Address_2__c,New_Oracle_City__c,New_Oracle_Country__c,New_Oracle_County__c,New_Oracle_Customer_Name__c,New_Oracle_Postal_Code__c,New_Oracle_State__c,New_Oracle_Account_Number__c from Customer_Dup_Check__c where Process_Flag__c =\''+'X'+'\' and Dedupe_Master__c = \'' +  Dm.Id + '\'';
        BatchSpecialScenarioAutoFill bdt2=new BatchSpecialScenarioAutoFill(str2);
        Database.executeBatch(bdt2);  
        
        BatchAutofill btch = new BatchAutofill(str2);
        Database.executeBatch(btch); 
        
        Attachment attach= new Attachment();   
        attach.Name = 'CUSTOMERS_DUP_CHECK';
        Blob bodyBlob = Blob.valueOf('"Col1","Col2","col3","col4","col5","col6","col7","col8","col9","col10","col11","col12","col13","col14","col15","col16","col17","col18","col19","col20","Col1","Col2","col3","col4","col5","col6","col7","col8","col9","col10","col11","col12","col13","col14","col15","col16","col17","col18","col19","col20"\r\n"Col1","Col2","col3","col4","col5","col6","col7","col8","col9","col10","col11","col12","col13","col14","col15","col16","col17","col18","col19","col20","Col1","Col2","col3","col4","col5","col6","col7","col8","col9","col10","col11","col12","col13","col14","col15","col16","col17","col18","col19","col20"');
        attach.body = bodyBlob;
        attach.ParentId = Dm.id;  
        insert attach;
        BatchReadCSVDedupFile brcdf = new BatchReadCSVDedupFile(bodyBlob.toString(), Dm, 'CUSTOMERS_DUP_CHECK');
        Database.executeBatch(brcdf);
        
    }
    
    static testmethod void CustomerdedupetestclassesMeth5(){
        
        //Create Dedupe Master 
        Dedupe_Master__c Dm = new Dedupe_Master__c();
        Dm.Save_Point__c =2;
        insert Dm;
        
        //Create Dedupe Account 
        Dedupe_Account__c DAcc = new Dedupe_Account__c();
        DAcc.Dedupe_Master__c = Dm.id;
        DAcc.Bill_To_Cust_Invoice_Count__c = 75;
        DAcc.Cust_Account_ID__c ='Test1234';
        DAcc.Customer_Name__c ='Test123';
        DAcc.Customer_Name_Match_Percentage__c =100;
        DAcc.Gen_Cust_Customer_ID__c ='Test123';
        DAcc.Legacy_Customer_ID__c = 'Test123';
        DAcc.Oracle_Account_Number__c ='Test123';
        DAcc.Oracle_Customer_Name__c ='Test123'; 
        DAcc.Party_ID__c = 'Test123';
        DAcc.Payment_Term__c = 'Test123';
        DAcc.Process_Flag__c ='X';
        DAcc.Profile_Amount__c ='Test123';
        DAcc.Record_ID__c ='12345';
        DAcc.Request_ID__c = 'Test123';
        DAcc.Addl_Column_1__c ='Test123';
        DAcc.Addl_Column_2__c ='Test123';
        DAcc.Addl_Column_3__c = 'Test123';
        DAcc.Addl_Column_4__c = 'Test123';
        DAcc.Addl_Column_5__c = 'Test123';
        DAcc.Addl_Column_6__c = 'Test123';
        DAcc.Addl_Column_7__c = 'Test123';
        DAcc.Addl_Column_8__c = 'Test123';
        DAcc.Addl_Column_9__c = 'Test123';
        DAcc.Addl_Column_10__c = 'Test123';
        DAcc.Addl_Column_11__c = 'Test123';
        DAcc.Addl_Column_12__c = 'Test123';
        DAcc.Addl_Column_13__c = 'Test123';
        DAcc.Addl_Column_14__c = 'Test123';
        DAcc.Addl_Column_15__c = 'Test123';
        DAcc.Addl_Column_16__c = 'Test123';
        DAcc.Addl_Column_17__c = 'Test123';
        DAcc.Addl_Column_18__c = 'Test123';
        DAcc.Addl_Column_19__c = 'Test123';
        insert DAcc;
        
        //Create Dedupe Address
        Dedupe_Address__c DArr = new Dedupe_Address__c();
        DArr.Dedupe_Master__c = Dm.id;
        DArr.Bill_To_Addr_Invoice_Count__c = 75;
        DArr.Cust_Account_ID__c = 'Test1234';
        DArr.Cust_Acct_Site_ID__c = 'Test1234';
        DArr.Customer_Addr_Match_Percentage__c =100;
        DArr.Gen_Cust_Address_ID__c ='Test1234';
        DArr.Gen_Cust_Customer_ID__c = 'Test1234';
        DArr.Legacy_Address_ID__c = 'Test1234';
        DArr.Legacy_Customer_ID__c = 'Test1234';
        DArr.Location_ID__c = 'Test1234';
        DArr.Oracle_address1__c = 'Test1234';
        DArr.Oracle_Address2__c = 'Test1234';
        DArr.Oracle_Address3__c = 'Test1234';
        DArr.Oracle_Address4__c = 'Test1234';
        DArr.Oracle_City__c = 'Test1234';
        DArr.Oracle_Country__c = 'Test1234';
        DArr.Oracle_County__c = 'Test1234';
        DArr.Oracle_Postal_Code__c = 'Test1234';
        DArr.Oracle_State__c = 'Test1234';
        DArr.Org_Id__c = 'Test1234';
        DArr.Party_Site_ID__c = 'Test1234';
        DArr.Party_Site_Number__c = 'Test1234';
        DArr.Process_Flag__c = 'X';
        DArr.Record_ID__c ='12345';
        DArr.Request_ID__c = 'Test1234';
        DArr.Addl_Column_1__c = 'Test1234';
        DArr.Addl_Column_2__c = 'Test1234';
        DArr.Addl_Column_3__c = 'Test1234';
        DArr.Addl_Column_4__c = 'Test1234';
        DArr.Addl_Column_5__c = 'Test1234';
        DArr.Addl_Column_6__c = 'Test1234';
        DArr.Addl_Column_7__c = 'Test1234';
        DArr.Addl_Column_8__c = 'Test1234';
        DArr.Addl_Column_9__c = 'Test1234';
        DArr.Addl_Column_10__c = 'Test1234';
        DArr.Addl_Column_11__c = 'Test1234';
        DArr.Addl_Column_12__c = 'Test1234';
        DArr.Addl_Column_13__c = 'Test1234';
        DArr.Addl_Column_14__c = 'Test1234';
        DArr.Addl_Column_15__c = 'Test1234';
        DArr.Addl_Column_16__c = 'Test1234';
        DArr.Addl_Column_17__c = 'Test1234';
        DArr.Addl_Column_18__c = 'Test1234';
        DArr.Addl_Column_19__c = 'Test1234';
        DArr.Addl_Column_20__c = 'Test1234';
        insert DArr;
        
        //Create Customer Dedupe
        Customer_Dup_Check__c Cdc = new Customer_Dup_Check__c();
        Cdc.Dedupe_Master__c = Dm.id;
        cdc.Record_ID__c ='12345';
        Cdc.Address_1__c = 'Test1234';
        Cdc.Address_2__c ='Test1234';
        Cdc.Address_3__c = 'Test1234';
        Cdc.Address_4__c = 'Test1234';
        Cdc.City__c = 'Test1234';
        Cdc.Country__c = 'Test1234';
        Cdc.County__c = 'Test1234';
        Cdc.Customer_Name__c ='Test1234';
        Cdc.Dedup_Program_Request_ID__c ='Test1234'; 
        Cdc.Derived_Org_ID__c ='Test1234';
        Cdc.File_Name__c = 'Test1234';
        Cdc.Gen_Cust_Address_ID__c = 'Test1234';
        Cdc.Gen_Cust_Customer_ID__c = 'Test1234';
        Cdc.Legacy_Address_ID__c = 'Test1234';
        Cdc.Legacy_Customer_ID__c = 'Test1234';
        Cdc.Load_Request_ID__c = 'Test1234';
        Cdc.New_Oracle_Account_Number__c = 'Test1234';
        Cdc.New_Oracle_Address_1__c = 'Test1234';
        Cdc.New_Oracle_Address_2__c = 'Test1234';
        Cdc.New_Oracle_City__c = 'Test1234';
        Cdc.New_Oracle_Country__c = 'Test1234';
        Cdc.New_Oracle_County__c =  'Test1234';
        Cdc.New_Oracle_Customer_Name__c = 'Test1234';
        Cdc.New_Oracle_Postal_Code__c = 'Test1234';
        Cdc.New_Oracle_State__c = 'Test1234';
        Cdc.Postal_Code__c = 'Test1234';
        Cdc.Process_Flag__c ='X';
        Cdc.Project_Name__c = 'Test1234';
        Cdc.State__c = 'Test1234';
        Cdc.Cust_Account_ID__c = DAcc.Cust_Account_ID__c;
        Cdc.Cust_Acct_Site_ID__c = DArr.Cust_Acct_Site_ID__c;
        insert Cdc;
        
        Customer_Dup_Check__c Cdc1 = new Customer_Dup_Check__c();
        Cdc1.Dedupe_Master__c = Dm.id;
        cdc1.Record_ID__c ='12345';
        Cdc1.Address_1__c = 'Test1234';
        Cdc1.Address_2__c ='Test1234';
        Cdc1.Address_3__c = 'Test1234';
        Cdc1.Address_4__c = 'Test1234';
        Cdc1.City__c = 'Test1234';
        Cdc1.Country__c = 'Test1234';
        Cdc1.County__c = 'Test1234';
        Cdc1.Customer_Name__c ='Test1234';
        Cdc1.Dedup_Program_Request_ID__c ='Test1234'; 
        Cdc1.Derived_Org_ID__c ='Test1234';
        Cdc1.File_Name__c = 'Test1234';
        Cdc1.Gen_Cust_Address_ID__c = 'Test1234';
        Cdc1.Gen_Cust_Customer_ID__c = 'Test1234';
        Cdc1.Legacy_Address_ID__c = 'Test1234';
        Cdc1.Legacy_Customer_ID__c = 'Test1234';
        Cdc1.Load_Request_ID__c = 'Test1234';
        Cdc1.New_Oracle_Account_Number__c = 'Test1234';
        Cdc1.New_Oracle_Address_1__c = 'Test1234';
        Cdc1.New_Oracle_Address_2__c = 'Test1234';
        Cdc1.New_Oracle_City__c = 'Test1234';
        Cdc1.New_Oracle_Country__c = 'Test1234';
        Cdc1.New_Oracle_County__c =  'Test1234';
        Cdc1.New_Oracle_Customer_Name__c = 'Test1234';
        Cdc1.New_Oracle_Postal_Code__c = 'Test1234';
        Cdc1.New_Oracle_State__c = 'Test1234';
        Cdc1.Postal_Code__c = 'Test1234';
        Cdc1.Process_Flag__c ='X';
        Cdc1.Project_Name__c = 'Test1234';
        Cdc1.State__c = 'Test1234';
        //Cdc1.Cust_Account_ID__c = DAcc.Cust_Account_ID__c;
        //Cdc1.Cust_Acct_Site_ID__c = DArr.Cust_Acct_Site_ID__c;
        insert cdc1;

        string str2='select id,Cust_Account_ID__c,Dedupe_Master__c,Oracle_Site_Reference__C,Process_Flag__c,Cust_Acct_Site_ID__c,Record_ID__c,New_Oracle_Address_1__c,New_Oracle_Address_2__c,New_Oracle_City__c,New_Oracle_Country__c,New_Oracle_County__c,New_Oracle_Customer_Name__c,New_Oracle_Postal_Code__c,New_Oracle_State__c,New_Oracle_Account_Number__c from Customer_Dup_Check__c where Process_Flag__c =\''+'X'+'\' and Dedupe_Master__c = \'' +  Dm.Id + '\'';
        BatchSpecialScenarioAutoFill bdt2=new BatchSpecialScenarioAutoFill(str2);
        Database.executeBatch(bdt2);  
        
        BatchAutofill btch = new BatchAutofill(str2);
        Database.executeBatch(btch); 
        
        Attachment attach= new Attachment();   
        attach.Name = 'CUST_DEDUP_IDEN_CUSTOMER';
        Blob bodyBlob = Blob.valueOf('"Col1","Col2","col3","col4","col5","col6","col7","col8","col9","col10","col11","col12","col13","col14","col15","col16","col17","col18"\r\n"Col1","Col2","col3","col4","20.2","col6","col7","col8","col9","20.2","col11","col12","col13","col14","col15","col16","col17","col18"');
        attach.body = bodyBlob;
        attach.ParentId = Dm.id;  
        insert attach;
        BatchReadCSVDedupFile brcdf = new BatchReadCSVDedupFile(bodyBlob.toString(), Dm, 'CUST_DEDUP_IDEN_CUSTOMER');
        Database.executeBatch(brcdf);
        
    }
    
    static testmethod void CustomerdedupetestclassesMeth6(){
        
        //Create Dedupe Master 
        Dedupe_Master__c Dm = new Dedupe_Master__c();
        Dm.Save_Point__c =2;
        insert Dm;
        
        //Create Dedupe Account 
        Dedupe_Account__c DAcc = new Dedupe_Account__c();
        DAcc.Dedupe_Master__c = Dm.id;
        DAcc.Bill_To_Cust_Invoice_Count__c = 75;
        DAcc.Cust_Account_ID__c ='Test123';
        DAcc.Customer_Name__c ='Test123';
        DAcc.Customer_Name_Match_Percentage__c =100;
        DAcc.Gen_Cust_Customer_ID__c ='Test123';
        DAcc.Legacy_Customer_ID__c = 'Test123';
        DAcc.Oracle_Account_Number__c ='Test123';
        DAcc.Oracle_Customer_Name__c ='Test123'; 
        DAcc.Party_ID__c = 'Test123';
        DAcc.Payment_Term__c = 'Test123';
        DAcc.Process_Flag__c ='X';
        DAcc.Profile_Amount__c ='Test123';
        DAcc.Record_ID__c ='12345';
        DAcc.Request_ID__c = 'Test123';
        DAcc.Addl_Column_1__c ='Test123';
        DAcc.Addl_Column_2__c ='Test123';
        DAcc.Addl_Column_3__c = 'Test123';
        DAcc.Addl_Column_4__c = 'Test123';
        DAcc.Addl_Column_5__c = 'Test123';
        DAcc.Addl_Column_6__c = 'Test123';
        DAcc.Addl_Column_7__c = 'Test123';
        DAcc.Addl_Column_8__c = 'Test123';
        DAcc.Addl_Column_9__c = 'Test123';
        DAcc.Addl_Column_10__c = 'Test123';
        DAcc.Addl_Column_11__c = 'Test123';
        DAcc.Addl_Column_12__c = 'Test123';
        DAcc.Addl_Column_13__c = 'Test123';
        DAcc.Addl_Column_14__c = 'Test123';
        DAcc.Addl_Column_15__c = 'Test123';
        DAcc.Addl_Column_16__c = 'Test123';
        DAcc.Addl_Column_17__c = 'Test123';
        DAcc.Addl_Column_18__c = 'Test123';
        DAcc.Addl_Column_19__c = 'Test123';
        insert DAcc;
        
        //Create Dedupe Address
        Dedupe_Address__c DArr = new Dedupe_Address__c();
        DArr.Dedupe_Master__c = Dm.id;
        DArr.Bill_To_Addr_Invoice_Count__c = 75;
        DArr.Cust_Account_ID__c = 'Test1234';
        DArr.Cust_Acct_Site_ID__c = 'Test1234';
        DArr.Customer_Addr_Match_Percentage__c =100;
        DArr.Gen_Cust_Address_ID__c ='Test1234';
        DArr.Gen_Cust_Customer_ID__c = 'Test1234';
        DArr.Legacy_Address_ID__c = 'Test1234';
        DArr.Legacy_Customer_ID__c = 'Test1234';
        DArr.Location_ID__c = 'Test1234';
        DArr.Oracle_address1__c = 'Test1234';
        DArr.Oracle_Address2__c = 'Test1234';
        DArr.Oracle_Address3__c = 'Test1234';
        DArr.Oracle_Address4__c = 'Test1234';
        DArr.Oracle_City__c = 'Test1234';
        DArr.Oracle_Country__c = 'Test1234';
        DArr.Oracle_County__c = 'Test1234';
        DArr.Oracle_Postal_Code__c = 'Test1234';
        DArr.Oracle_State__c = 'Test1234';
        DArr.Org_Id__c = 'Test1234';
        DArr.Party_Site_ID__c = 'Test1234';
        DArr.Party_Site_Number__c = 'Test1234';
        DArr.Process_Flag__c = 'X';
        DArr.Record_ID__c ='12345';
        DArr.Request_ID__c = 'Test1234';
        DArr.Addl_Column_1__c = 'Test1234';
        DArr.Addl_Column_2__c = 'Test1234';
        DArr.Addl_Column_3__c = 'Test1234';
        DArr.Addl_Column_4__c = 'Test1234';
        DArr.Addl_Column_5__c = 'Test1234';
        DArr.Addl_Column_6__c = 'Test1234';
        DArr.Addl_Column_7__c = 'Test1234';
        DArr.Addl_Column_8__c = 'Test1234';
        DArr.Addl_Column_9__c = 'Test1234';
        DArr.Addl_Column_10__c = 'Test1234';
        DArr.Addl_Column_11__c = 'Test1234';
        DArr.Addl_Column_12__c = 'Test1234';
        DArr.Addl_Column_13__c = 'Test1234';
        DArr.Addl_Column_14__c = 'Test1234';
        DArr.Addl_Column_15__c = 'Test1234';
        DArr.Addl_Column_16__c = 'Test1234';
        DArr.Addl_Column_17__c = 'Test1234';
        DArr.Addl_Column_18__c = 'Test1234';
        DArr.Addl_Column_19__c = 'Test1234';
        DArr.Addl_Column_20__c = 'Test1234';
        insert DArr;
        
        //Create Customer Dedupe
        Customer_Dup_Check__c Cdc = new Customer_Dup_Check__c();
        Cdc.Dedupe_Master__c = Dm.id;
        cdc.Record_ID__c ='12345';
        Cdc.Address_1__c = 'Test1234';
        Cdc.Address_2__c ='Test1234';
        Cdc.Address_3__c = 'Test1234';
        Cdc.Address_4__c = 'Test1234';
        Cdc.City__c = 'Test1234';
        Cdc.Country__c = 'Test1234';
        Cdc.County__c = 'Test1234';
        Cdc.Customer_Name__c ='Test1234';
        Cdc.Dedup_Program_Request_ID__c ='Test1234'; 
        Cdc.Derived_Org_ID__c ='Test1234';
        Cdc.File_Name__c = 'Test1234';
        Cdc.Gen_Cust_Address_ID__c = 'Test1234';
        Cdc.Gen_Cust_Customer_ID__c = 'Test1234';
        Cdc.Legacy_Address_ID__c = 'Test1234';
        Cdc.Legacy_Customer_ID__c = 'Test1234';
        Cdc.Load_Request_ID__c = 'Test1234';
        Cdc.New_Oracle_Account_Number__c = 'Test1234';
        Cdc.New_Oracle_Address_1__c = 'Test1234';
        Cdc.New_Oracle_Address_2__c = 'Test1234';
        Cdc.New_Oracle_City__c = 'Test1234';
        Cdc.New_Oracle_Country__c = 'Test1234';
        Cdc.New_Oracle_County__c =  'Test1234';
        Cdc.New_Oracle_Customer_Name__c = 'Test1234';
        Cdc.New_Oracle_Postal_Code__c = 'Test1234';
        Cdc.New_Oracle_State__c = 'Test1234';
        Cdc.Postal_Code__c = 'Test1234';
        Cdc.Process_Flag__c ='X';
        Cdc.Project_Name__c = 'Test1234';
        Cdc.State__c = 'Test1234';
        Cdc.Cust_Account_ID__c = DAcc.Cust_Account_ID__c;
        Cdc.Cust_Acct_Site_ID__c = DArr.Cust_Acct_Site_ID__c;
        insert Cdc;
        
        Customer_Dup_Check__c Cdc1 = new Customer_Dup_Check__c();
        Cdc1.Dedupe_Master__c = Dm.id;
        cdc1.Record_ID__c ='12345';
        Cdc1.Address_1__c = 'Test1234';
        Cdc1.Address_2__c ='Test1234';
        Cdc1.Address_3__c = 'Test1234';
        Cdc1.Address_4__c = 'Test1234';
        Cdc1.City__c = 'Test1234';
        Cdc1.Country__c = 'Test1234';
        Cdc1.County__c = 'Test1234';
        Cdc1.Customer_Name__c ='Test1234';
        Cdc1.Dedup_Program_Request_ID__c ='Test1234'; 
        Cdc1.Derived_Org_ID__c ='Test1234';
        Cdc1.File_Name__c = 'Test1234';
        Cdc1.Gen_Cust_Address_ID__c = 'Test1234';
        Cdc1.Gen_Cust_Customer_ID__c = 'Test1234';
        Cdc1.Legacy_Address_ID__c = 'Test1234';
        Cdc1.Legacy_Customer_ID__c = 'Test1234';
        Cdc1.Load_Request_ID__c = 'Test1234';
        Cdc1.New_Oracle_Account_Number__c = 'Test1234';
        Cdc1.New_Oracle_Address_1__c = 'Test1234';
        Cdc1.New_Oracle_Address_2__c = 'Test1234';
        Cdc1.New_Oracle_City__c = 'Test1234';
        Cdc1.New_Oracle_Country__c = 'Test1234';
        Cdc1.New_Oracle_County__c =  'Test1234';
        Cdc1.New_Oracle_Customer_Name__c = 'Test1234';
        Cdc1.New_Oracle_Postal_Code__c = 'Test1234';
        Cdc1.New_Oracle_State__c = 'Test1234';
        Cdc1.Postal_Code__c = 'Test1234';
        Cdc1.Process_Flag__c ='X';
        Cdc1.Project_Name__c = 'Test1234';
        Cdc1.State__c = 'Test1234';
        Cdc1.Cust_Account_ID__c = DAcc.Cust_Account_ID__c;
        //Cdc1.Cust_Acct_Site_ID__c = DArr.Cust_Acct_Site_ID__c;
        insert cdc1;

        string str2='select id,Cust_Account_ID__c,Dedupe_Master__c,Oracle_Site_Reference__C,Process_Flag__c,Cust_Acct_Site_ID__c,Record_ID__c,New_Oracle_Address_1__c,New_Oracle_Address_2__c,New_Oracle_City__c,New_Oracle_Country__c,New_Oracle_County__c,New_Oracle_Customer_Name__c,New_Oracle_Postal_Code__c,New_Oracle_State__c,New_Oracle_Account_Number__c from Customer_Dup_Check__c where Process_Flag__c =\''+'X'+'\' and Dedupe_Master__c = \'' +  Dm.Id + '\'';
        BatchSpecialScenarioAutoFill bdt2=new BatchSpecialScenarioAutoFill(str2);
        Database.executeBatch(bdt2);  
        
        BatchAutofill btch = new BatchAutofill(str2);
        Database.executeBatch(btch); 
        
        Attachment attach= new Attachment();   
        attach.Name = 'CUST_DEDUP_IDEN_ADDRESS';
        Blob bodyBlob = Blob.valueOf('"Col1","Col2","col3","col4","col5","col6","col7","col8","col9","col10","col11","col12","col13","col14","col15","col16","col17","col18","Col1","Col2","col3","col4","col5","col6","col7","col8","col9","col10","col11","col12","col13","col14","col15","col16","col17","col18"\r\n"Col1","Col2","20.2","col4","20.2","col6","col7","col8","col9","col10","col11","20.3","20.3","col14","col15","col16","col17","col18","Col1","Col2","20.2","col4","col5","col6","col7","col8","col9","col10","col11","20.3","20.3","col14","col15","col16","col17","col18"');
        attach.body = bodyBlob;
        attach.ParentId = Dm.id;  
        insert attach;
        BatchReadCSVDedupFile brcdf = new BatchReadCSVDedupFile(bodyBlob.toString(), Dm, 'CUST_DEDUP_IDEN_ADDRESS');
        Database.executeBatch(brcdf);
        
    }
    
    
}