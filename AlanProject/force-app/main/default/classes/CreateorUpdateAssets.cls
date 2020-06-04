/*****************************************************************************************
    Name    : CreateorUpdateAssets 
    Desc    : Used implementing the inbound to SFDC from Oracle EBS for Assets.
              
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       12/23/2013          Created
******************************************************************************************/
global class CreateorUpdateAssets {
public class soapexception extends exception{}
    
    webService static list<ResponseWraperClass> CreateInstallBase(list<requestdata> requesrwrapervar) {
        list<Asset> Assestlist = new list<Asset>();
        List<list<Database.UpsertResult>> MastersrList = new List<list<Database.UpsertResult>>();   
        
        integer count;
        boolean updateAsset = false;
        Asset assetvar;
        date installdate,usageenddate;
        date startdate,enddate;        
        boolean blnFinalResult = false;
        boolean blnSystemException = false;
        boolean throwEx = false;
        
        ResponseWraperClass respvar;
        list<ResponseWraperClass> respvarlist = new list<ResponseWraperClass>();
        
        map<string,asset> assetmap = new map<string,asset>(); 
        map<string,Account> accountmap = new map<string,Account>();
        map<string,Account> accountmap1 = new map<string,Account>();
        map<string,product2> productmap = new map<string,product2>();
        map<string,Address__c> Addressmap = new map<string,Address__c>();
        
        set<string> assetNamesSet = new set<string>(); 
        set<string> CustomerMasterIDSet = new set<string>();
        set<string> accountNamesSet = new set<string>();
        set<string> productNamesSet = new set<string>();
        set<string> AddressIDset = new Set<String>();
        Map<String,List<RequestNotesdata>> istoreNotesMap= new Map<String,List<RequestNotesdata>>(); 
       
        for(requestdata reqvar:requesrwrapervar){
          if(reqvar.AssetName == null || reqvar.AssetName == ''){
              
              respvar = new ResponseWraperClass();
              blnFinalResult = true;  
              respvar.result ='Failure';
              respvar.Errorcode = 'AT-ERR-107';
              respvar.ErrorMessage ='AssetName does not have a value. Please check the data';
              respvar.Asset_number = reqvar.AssetName;
              respvar.Customer_master_id = reqvar.CustomerMasterID;
              respvar.Item_number = reqvar.AssetProduct;
              respvar.TransactionNameAndValue = reqvar.AssetName;
              respvarlist.add(respvar);
              
              
            }
            else if(reqvar.CustomerMasterID == null || reqvar.CustomerMasterID ==''){
              respvar = new ResponseWraperClass();  
              blnFinalResult = true;  
              respvar.result ='Failure';
              respvar.Errorcode = 'AT-ERR-107';
              respvar.ErrorMessage = 'CustomerMasterID does not have a value. Please check the data ' + reqvar.AssetName;
              respvar.Asset_number = reqvar.AssetName;
              respvar.Customer_master_id = reqvar.CustomerMasterID;
              respvar.Item_number = reqvar.AssetProduct;
              respvar.TransactionNameAndValue = reqvar.CustomerMasterID;
              respvarlist.add(respvar);
              
              
              
            }
            else if(reqvar.OwnerAccountName == null || reqvar.OwnerAccountName == ''){
              respvar = new ResponseWraperClass();  
              blnFinalResult = true;  
              respvar.result ='Failure';
              respvar.Errorcode = 'AT-ERR-107';
              respvar.ErrorMessage = 'OwnerAccountName does not have a value. Please check the data ' + reqvar.AssetName;
              respvar.Asset_number = reqvar.AssetName;
              respvar.Customer_master_id = reqvar.CustomerMasterID;
              respvar.Item_number = reqvar.AssetProduct;
              respvar.TransactionNameAndValue = reqvar.OwnerAccountName;
              respvarlist.add(respvar);
              
              
              
            }
            else if(reqvar.AssetProduct == null || reqvar.AssetProduct == ''){
              respvar = new ResponseWraperClass(); 
              blnFinalResult = true;   
              respvar.result ='Failure';
              respvar.Errorcode = 'AT-ERR-107';
              respvar.ErrorMessage = 'AssetProduct does not have a value. Please check the data ' + reqvar.AssetName;
              respvar.Asset_number = reqvar.AssetName;
              respvar.Customer_master_id = reqvar.CustomerMasterID;
              respvar.Item_number = reqvar.AssetProduct;
              respvar.TransactionNameAndValue = reqvar.AssetProduct;
              respvarlist.add(respvar);
              
              
            }
          else {
            assetNamesSet.add(reqvar.AssetName.trim());
            CustomerMasterIDSet.add(reqvar.CustomerMasterID.trim());
            if(reqvar.BillToFCHPartyID!= Null && reqvar.BillToFCHPartyID!='') CustomerMasterIDSet.add(reqvar.BillToFCHPartyID.trim());
            if(reqvar.ShipToFCHPartyID!= Null && reqvar.ShipToFCHPartyID!='') CustomerMasterIDSet.add(reqvar.ShipToFCHPartyID.trim());
            if(reqvar.BillToFCHPartySiteID!= Null && reqvar.BillToFCHPartySiteID!='') AddressIdset.add(reqvar.BillToFCHPartySiteID.trim());
            if(reqvar.ShipToFCHPartySiteID!= Null && reqvar.ShipToFCHPartySiteID!='') AddressIdset.add(reqvar.ShipToFCHPartySiteID.trim());
            accountNamesSet.add(reqvar.OwnerAccountName.trim());
            productNamesSet.add(reqvar.AssetProduct.trim());
          }   
        }
        
        
        for(asset assetobj:[Select Id, ContactId, AccountId,License_Details__c,Expired_Quantity__c, Product2Id,Asset_Oracle_ID__c, IsCompetitorProduct, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsDeleted, CurrencyIsoCode, Name, SerialNumber, InstallDate, PurchaseDate, UsageEndDate, Status, Price, Quantity, Description, City__c, Country__c, Name__c, Product_Version__c, State__c, Street_Address__c, Zip_Code__c FROM Asset  where Asset_Oracle_ID__c in :assetNamesSet FOR UPDATE])
        {
          assetmap.put(assetobj.Asset_Oracle_ID__c,assetobj);
        }
        
        
        /*for(Account acc : [select id,oracle_id__c,Name,FCH_Party_ID__c from Account where FCH_Party_ID__c in : CustomerMasterIDSet and Name in : accountNamesSet])
        {
          accountmap.put(string.valueof(acc.FCH_Party_ID__c)+string.valueof(acc.name.trim()),acc);
          accountmap1.put(ACC.nAME,acc);
        }*/
        for(Account acc : [select id,oracle_id__c,Name,FCH_Party_ID__c from Account where FCH_Party_ID__c in : CustomerMasterIDSet FOR UPDATE])
        {
          accountmap.put(string.valueof(acc.FCH_Party_ID__c),acc);
          accountmap1.put(ACC.nAME,acc);
        }
        
        for(Address__c Add : [select id,FCH_Party_Site_ID__c from Address__c where FCH_Party_Site_ID__c in: AddressIdset FOR UPDATE])
        {
          Addressmap.put(string.valueof(Add.FCH_Party_Site_ID__c),Add);
        }
        
        for(product2 prodvar:[select id,Name,productcode,Product_Family_Description__c from product2 where productcode in : productNamesSet FOR UPDATE])
        {
          productmap.put(prodvar.productcode,prodvar);
          
        }
        
        try{
        for(requestdata reqvar:requesrwrapervar){
            //system.debug('reqvar====='+reqvar);
            try{
             
              if(reqvar.AssetName!=null && reqvar.AssetName!=''){
             String NoteId ='';
              if(reqvar.istoreNotes != Null && reqvar.istoreNotes.size()>0)
              {
                istoreNotesMap.put(reqvar.AssetName,reqvar.istoreNotes);
              }  
              system.debug('>>>>>>>>istoreNotesMap>>>>>>>>>>'+istoreNotesMap);
               
            }
            if(reqvar.AssetName!=null && reqvar.AssetName!='' && assetmap!=null && assetmap.size()>0 && assetmap.get(reqvar.AssetName)!=null)
            {//assetvar = [Select Id, ContactId, AccountId, Product2Id, IsCompetitorProduct, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsDeleted, CurrencyIsoCode, Name, SerialNumber, InstallDate, PurchaseDate, UsageEndDate, Status, Price, Quantity, Description, City__c, Country__c, Name__c, Product_Version__c, State__c, Street_Address__c, Zip_Code__c FROM Asset  where Name=:reqvar.AssetName limit 1];
              assetvar = assetmap.get(reqvar.AssetName);
              
            }
            else
            assetvar = new Asset();            
           
            /*if(reqvar.CustomerMasterID!=null && reqvar.CustomerMasterID!='' && reqvar.OwnerAccountName!=null && reqvar.OwnerAccountName!='' && accountmap!=null && accountmap.size()>0 && accountmap.get(reqvar.CustomerMasterID+reqvar.OwnerAccountName.trim())!=null)
            {
                Assetvar.Accountid = accountmap.get(reqvar.CustomerMasterID+reqvar.OwnerAccountName.trim()).id;                
                //system.debug('Assetvar.Accountid===='+Assetvar.Accountid);
            }*/
            Assetvar.Accountid = null;
            if(reqvar.CustomerMasterID!=null && reqvar.CustomerMasterID!='' && reqvar.OwnerAccountName!=null && reqvar.OwnerAccountName!='' && accountmap!=null && accountmap.size()>0 && accountmap.get(reqvar.CustomerMasterID)!=null)
            {
                Assetvar.Accountid = accountmap.get(reqvar.CustomerMasterID).id;                
                system.debug('Assetvar.Accountid===='+Assetvar.Accountid);
            }
            else
            {
               
                if(reqvar.OwnerAccountName!=null && reqvar.OwnerAccountName!='' && accountmap1!=null && accountmap1.get(reqvar.OwnerAccountName)!=null)               
                Assetvar.Accountid = accountmap1.get(reqvar.OwnerAccountName.trim()).id;                
            }
            
            //Bill To Account
            if(reqvar.BillToFCHPartyID != Null && reqvar.BillToFCHPartyID !='' && accountmap.get(reqvar.BillToFCHPartyID) != Null)
            AssetVar.Bill_To_Account__c = accountmap.get(reqvar.BillToFCHPartyID).id;
            
            if(reqvar.BillToFCHPartyID != Null && reqvar.BillToFCHPartyID !='')
            AssetVar.Bill_To_FCH_Party_ID__c = reqvar.BillToFCHPartyID;
            
            //Ship To Account
            if(reqvar.ShipToFCHPartyID != Null && reqvar.ShipToFCHPartyID !='' && accountmap.get(reqvar.ShipToFCHPartyID) != Null)
            AssetVar.Ship_To_Account__c = accountmap.get(reqvar.ShipToFCHPartyID).id;
            
            if(reqvar.ShipToFCHPartyID != Null && reqvar.ShipToFCHPartyID !='')
            AssetVar.Ship_To_FCH_Party_ID__c = reqvar.ShipToFCHPartyID;
            
            //Bill To Address
            if(reqvar.BillToFCHPartySiteID != Null && reqvar.BillToFCHPartySiteID!='' && addressmap.get(reqvar.BillToFCHPartySiteID) != Null)
            AssetVar.Bill_To_Address__c = addressmap.get(reqvar.BillToFCHPartySiteID).id;
            
            if(reqvar.BillToFCHPartySiteID != Null && reqvar.BillToFCHPartySiteID!='')
            AssetVar.Bill_To_FCH_Party_Site_ID__c = reqvar.BillToFCHPartySiteID;
            
            //Ship To Address
            if(reqvar.ShipToFCHPartySiteID != Null && reqvar.ShipToFCHPartySiteID!='' && addressmap.get(reqvar.ShipToFCHPartySiteID) != Null)
            AssetVar.Ship_To_Address__c = addressmap.get(reqvar.ShipToFCHPartySiteID).id;
            
            if(reqvar.ShipToFCHPartySiteID != Null && reqvar.ShipToFCHPartySiteID!='')
            AssetVar.Ship_To_FCH_Party_Site_ID__c = reqvar.ShipToFCHPartySiteID;
            
            
            Assetvar.Product2Id = null;
            if(productmap!=null && productmap.size()>0 && reqvar.AssetProduct!=null && reqvar.AssetProduct!='' && productmap.get(reqvar.AssetProduct)!=null){
            //Assetvar.product2.id = productmap.get(reqvar.AssetProduct).id;
             
              Assetvar.Product2Id = productmap.get(reqvar.AssetProduct).id;   
             
            }
            //system.debug('Assetvar.Accountid====='+Assetvar.Accountid);
            if(Assetvar.Accountid == null){
            
            respvar = new ResponseWraperClass(); 
            blnFinalResult = true;
            throwEx = true;   
            respvar.result ='Failure';
            respvar.Errorcode = 'AT-ERR-104';
            respvar.ErrorMessage = 'The related Account Data of '+reqvar.OwnerAccountName.trim()+' does not exists in SFDC .please check your data for';
            respvar.Asset_number = reqvar.AssetName;
            respvar.Customer_master_id = reqvar.CustomerMasterID;
            respvar.Item_number = reqvar.AssetProduct;
            respvar.TransactionNameAndValue = 'Asset: '+ reqvar.AssetName;
            respvarlist.add(respvar);
            
            
            }
            
            if(Assetvar.Product2Id == null){
                 respvar = new ResponseWraperClass();  
              respvar.result ='Failure';
              blnFinalResult = true;
              throwEx = true;  
              respvar.Errorcode = 'AT-ERR-105';
              respvar.ErrorMessage = 'The related product Data does not exists in SFDC .please check your data for';
              respvar.Asset_number = reqvar.AssetName;
              respvar.Customer_master_id = reqvar.CustomerMasterID;
              respvar.Item_number = reqvar.AssetProduct;
              respvar.TransactionNameAndValue = 'Asset: '+reqvar.AssetName;
              respvarlist.add(respvar);
              
              
            }
            
            
            if(reqvar.AssetName == null || reqvar.AssetName == ''){
              respvar = new ResponseWraperClass();  
              blnFinalResult = true; 
              throwEx = true; 
              respvar.result ='Failure';
              respvar.Errorcode = 'AT-ERR-101';
              respvar.ErrorMessage = 'Asset Name cannot be null. Please check the data';
              respvar.Asset_number = reqvar.AssetName;
              respvar.Customer_master_id = reqvar.CustomerMasterID;
              respvar.Item_number = reqvar.AssetProduct;
              respvar.TransactionNameAndValue = 'Asset: '+  reqvar.AssetName;
              respvarlist.add(respvar);
              
              
              
              
            }
            System.debug(reqvar.AssetSerialNumber);
            if(reqvar.AssetSerialNumber != null && reqvar.AssetSerialNumber.length()> 80) {
              respvar = new ResponseWraperClass(); 
              blnFinalResult = true; 
              throwEx = true;  
              respvar.result ='Failure';
              respvar.Errorcode = 'AT-ERR-102';
              respvar.ErrorMessage = 'Asset Serial Number should not be more than 80 characters. Please check the data';
              respvar.Asset_number = reqvar.AssetName;
              respvar.Customer_master_id = reqvar.CustomerMasterID;
              respvar.Item_number = reqvar.AssetProduct;
              respvar.TransactionNameAndValue = 'Asset: '+ reqvar.AssetSerialNumber;
              respvarlist.add(respvar);
              
              
              
            }
            System.debug(reqvar.AssetLicenseKey);
            if(reqvar.AssetLicenseKey != null && reqvar.AssetLicenseKey.length()> 50) {
              respvar = new ResponseWraperClass(); 
              blnFinalResult = true;  
              throwEx = true; 
              respvar.result ='Failure';
              respvar.Errorcode = 'AT-ERR-103';
              respvar.ErrorMessage = 'Asset License Key should not be more than 50 characters. Please check the data';
              respvar.Asset_number = reqvar.AssetName;
              respvar.Customer_master_id = reqvar.CustomerMasterID;
              respvar.Item_number = reqvar.AssetProduct;
              respvar.TransactionNameAndValue = 'Asset: '+ reqvar.AssetLicenseKey;
              respvarlist.add(respvar);
              
              
              
              
            }
            
            if(throwEx == true){
                throwEx = false;
                throw new soapexception('');
            }
            //Assetvar.Name = reqvar.AssetName;
            //system.debug('reqvar.AssetSerialNumber======='+reqvar.AssetSerialNumber);
            //Assetvar.Product_Family__c = reqvar.AssetProductFamily;
            Assetvar.SerialNumber = (reqvar.AssetSerialNumber!=null && reqvar.AssetSerialNumber!='')?reqvar.AssetSerialNumber: '';
            if(reqvar.AssetInstallDate!=null && reqvar.AssetInstallDate!=''){
                string str = reqvar.AssetInstallDate;
                list<string> li = str.split('T');
               
                installdate = date.valueof(li[0]);                
            }
            
            Assetvar.InstallDate = (reqvar.AssetInstallDate!=null && reqvar.AssetInstallDate!='')?installdate :null;
            Assetvar.Quantity = (reqvar.AssetQuantity!=null && reqvar.AssetQuantity!='')?integer.valueof(reqvar.AssetQuantity):0;
            Assetvar.Status = reqvar.AssetStatus;
            Assetvar.License_Key__c = reqvar.AssetLicenseKey;
            
            //system.debug('productmap====='+productmap.size()+'====reqvar.AssetProduct===='+reqvar.AssetProduct+'=====productmap.get(reqvar.AssetProduct)===='+productmap.get(reqvar.AssetProduct));
            //system.debug('Assetvar.product2.id===='+Assetvar.product2.id+'==========assetvar.product2id===='+assetvar.product2id);
            if(productmap!=null && productmap.size()>0 && reqvar.AssetProduct!=null && reqvar.AssetProduct!='' && productmap.get(reqvar.AssetProduct)!=null){
            //Assetvar.product2.id = productmap.get(reqvar.AssetProduct).id;
             // Assetvar.Product2Id = productmap.get(reqvar.AssetProduct).id;   
              Assetvar.Name = productmap.get(reqvar.AssetProduct).Name; 
              Assetvar.Product_Code__c = productmap.get(reqvar.AssetProduct).productcode;
              Assetvar.Product_Family__c = productmap.get(reqvar.AssetProduct).Product_Family_Description__c;
            }
            
            Assetvar.Product_Version__c = reqvar.AssetVersion;
            Assetvar.Asset_Oracle_ID__c = reqvar.AssetName;
            if(reqvar.CurrencyCode!=null && reqvar.CurrencyCode!='')
            Assetvar.CurrencyIsoCode = reqvar.CurrencyCode;
            Assetvar.Price = (reqvar.AssetPrice!=null && reqvar.AssetPrice!='')?Decimal.valueof(reqvar.AssetPrice):0.00;   
            // New Attribute Mapping
            Assetvar.License_Details__c  = (reqvar.attribute1 !=Null && reqvar.attribute1 !='')?reqvar.attribute1 : '';
            Assetvar.Expired_Quantity__c = (reqvar.attribute2 !=Null && reqvar.attribute2 !='')?reqvar.attribute2 : '';
            Assetvar.Industry__c = (reqvar.attribute3 !=Null && reqvar.attribute3 !='')?reqvar.attribute3 : '';
            
            //TAP Attributes mapping 
            Assetvar.POS_Type__c = (reqvar.TAP_POS_TYPE!=Null && reqvar.TAP_POS_TYPE!='')?reqvar.TAP_POS_TYPE: '';
            Assetvar.Firmware_Ver__c = (reqvar.TAP_FIRMWARE!=Null && reqvar.TAP_FIRMWARE!='')?reqvar.TAP_FIRMWARE: '';
            Assetvar.Model__c = (reqvar.TAP_MODEL!=Null && reqvar.TAP_MODEL!='')?reqvar.TAP_MODEL: '';
            Assetvar.Manufacturer__c = (reqvar.TAP_MANUFACTURER!=Null && reqvar.TAP_MANUFACTURER!='')?reqvar.TAP_MANUFACTURER: '';
            
           if(reqvar.TAP_SIM_INCLUDED!= Null && reqvar.TAP_SIM_INCLUDED!= '' && (reqvar.TAP_SIM_INCLUDED=='y' || reqvar.TAP_SIM_INCLUDED=='Y' || reqvar.TAP_SIM_INCLUDED=='Yes' || reqvar.TAP_SIM_INCLUDED=='yes' || reqvar.TAP_SIM_INCLUDED=='True' || reqvar.TAP_SIM_INCLUDED=='true'))
           Assetvar.Sim_Included__c = True;
           if(reqvar.TAP_SIM_INCLUDED== Null && reqvar.TAP_SIM_INCLUDED== '' || (reqvar.TAP_SIM_INCLUDED=='n' || reqvar.TAP_SIM_INCLUDED=='N' || reqvar.TAP_SIM_INCLUDED=='No' || reqvar.TAP_SIM_INCLUDED=='no' || reqvar.TAP_SIM_INCLUDED=='False' || reqvar.TAP_SIM_INCLUDED=='false'))
           Assetvar.Sim_Included__c = False;
           
           if(reqvar.TAP_AUTO_RENEWAL!= Null && reqvar.TAP_AUTO_RENEWAL!= '' && (reqvar.TAP_AUTO_RENEWAL=='Y' || reqvar.TAP_AUTO_RENEWAL=='y' || reqvar.TAP_AUTO_RENEWAL=='Yes' || reqvar.TAP_AUTO_RENEWAL=='yes' || reqvar.TAP_AUTO_RENEWAL=='True' || reqvar.TAP_AUTO_RENEWAL=='true'))
           Assetvar.Auto_Renewal__c = True;
           if(reqvar.TAP_AUTO_RENEWAL== Null && reqvar.TAP_AUTO_RENEWAL== '' || (reqvar.TAP_AUTO_RENEWAL=='N' || reqvar.TAP_AUTO_RENEWAL=='n' || reqvar.TAP_AUTO_RENEWAL=='No' || reqvar.TAP_AUTO_RENEWAL=='no' || reqvar.TAP_AUTO_RENEWAL=='False' || reqvar.TAP_AUTO_RENEWAL=='false'))
           Assetvar.Auto_Renewal__c = False;
           
            Assetvar.SIM_Number__c = (reqvar.TAP_SIM_NUMBER!=Null && reqvar.TAP_SIM_NUMBER!='')?reqvar.TAP_SIM_NUMBER: '';
            Assetvar.Carrier__c = (reqvar.TAP_CARRIER_NAME!=Null && reqvar.TAP_CARRIER_NAME!='')?reqvar.TAP_CARRIER_NAME: '';
            Assetvar.GSM_Number__c = (reqvar.TAP_GSM_NUMBER!=Null && reqvar.TAP_GSM_NUMBER!='')?reqvar.TAP_GSM_NUMBER: '';
            Assetvar.SSO_User_Email_Address__c = (reqvar.TAP_SSO_USER_EMAIL!=Null && reqvar.TAP_SSO_USER_EMAIL!='')?reqvar.TAP_SSO_USER_EMAIL: '';
            Assetvar.SIM_Status__c = (reqvar.TAP_SIM_STATUS!=Null && reqvar.TAP_SIM_STATUS!='')?reqvar.TAP_SIM_STATUS: '';
            Assetvar.Related_POS_ID__c = (reqvar.TAP_RELATED_POS_ID!=Null && reqvar.TAP_RELATED_POS_ID!='')?reqvar.TAP_RELATED_POS_ID: '';
            Assetvar.Related_POS_Type__c = (reqvar.TAP_RELATED_POS_TYPE !=Null && reqvar.TAP_RELATED_POS_TYPE!='')?reqvar.TAP_RELATED_POS_TYPE: '';
            Assetvar.SIM_Start_Date__c = (reqvar.TAP_SIM_CONTRACT_START_DATE!=Null && reqvar.TAP_SIM_CONTRACT_START_DATE!='')?reqvar.TAP_SIM_CONTRACT_START_DATE: '';
            Assetvar.SIM_End_Date__c = (reqvar.TAP_SIM_CONTRACT_END_DATE!=Null && reqvar.TAP_SIM_CONTRACT_END_DATE!='')?reqvar.TAP_SIM_CONTRACT_END_DATE: '';
            
            if(reqvar.TAP_CURR_OWNER_TRX_DATE != Null && reqvar.TAP_CURR_OWNER_TRX_DATE !='')
              {
              String Str='';
              str = reqvar.TAP_CURR_OWNER_TRX_DATE.replace('T',' ');
              str = str.replace('.000-07:00','');
              DateTime.Valueof(str);
              Assetvar.TAP_CURR_OWNER_TRX_DATE__c = DateTime.Valueof(str);
              }
      
            
          /*   if(reqvar.TAP_SIM_CONTRACT_START_DATE!=null && reqvar.TAP_SIM_CONTRACT_START_DATE!='')
            {
                string str = reqvar.TAP_SIM_CONTRACT_START_DATE;
                list<string> li = str.split('T');
               
                startdate = date.valueof(li[0]);
                Assetvar.SIM_Start_Date__c = date.valueof(li[0]);
            }
            
             if(reqvar.TAP_SIM_CONTRACT_END_DATE!=null && reqvar.TAP_SIM_CONTRACT_END_DATE!='')
            {
                string str = reqvar.TAP_SIM_CONTRACT_END_DATE;
                list<string> li = str.split('T');
               
                Enddate = date.valueof(li[0]);
                Assetvar.SIM_End_Date__c = date.valueof(li[0]);
            }*/
            
            
            if(reqvar.AssetEndDate!=null && reqvar.AssetEndDate!=''){
                string str = reqvar.AssetEndDate;
                list<string> li = str.split('T');               
                usageenddate = date.valueof(li[0]);                
            }
            Assetvar.UsageEndDate = (reqvar.AssetEndDate!=null && reqvar.AssetEndDate!='')?usageenddate:null;
            
            if(Assetvar.Accountid != null && Assetvar.Product2Id != null)
            Assestlist.add(Assetvar); 
            }catch(Exception ex){
               //Exception message already added in the response list so there is no need to handle any thing in this exception 
               blnFinalResult = true;  
          
            }
            //updateAsset = false;           
           
            /*if(reqvar.AssetProductCode!=null && reqvar.AssetProductCode!='')
            {
              Assetvar.Product_Code__c = reqvar.AssetProductCode;
            }*/
           
        } 
        
        
        set<id> succAssetIdSet = new set<id>(); 
        
        if(Assestlist !=null && Assestlist.size()>0){
            Database.UpsertResult[] srList;
            srList = Database.upsert(Assestlist,Asset.Fields.Id,false);
            MastersrList.add(srList);
            CreateorUpdateAssets ObjIns = new CreateorUpdateAssets();
            
            ObjIns.CreateIstoreNotes(istoreNotesMap);
        }
        
        for(list<Database.UpsertResult> srval : MastersrList) {
             for (Database.UpsertResult sr : srval){
                 succAssetIdSet.add(sr.getid());
              }
        
        
        
          }
          
          
            map<id,string> Asset_ID_AssetNum_Map = new map<id,string>();
            map<id,string> Asset_ID_ProductCode_Map = new map<id,string>();
            map<id,string> Asset_ID_EntMastID_Map = new map<id,string>();
            for(Asset asst : [Select ID,Name,Product_Code__c,asset.account.FCH_Party_ID__c,Asset_Oracle_ID__c from Asset where id IN:succAssetIdSet FOR UPDATE]){
              Asset_ID_AssetNum_Map.put(asst.id, asst.Asset_Oracle_ID__c);
              Asset_ID_ProductCode_Map.put(asst.id, asst.Product_Code__c);
              Asset_ID_EntMastID_Map.put(asst.id, asst.Account.FCH_Party_ID__c);
            }
            
         
         for(list<Database.UpsertResult> srval : MastersrList) {
         
             for (Database.UpsertResult sr : srval) {
               if (sr.isSuccess()) {
                     respvar = new ResponseWraperClass();
                      respvar.result ='Success';
                      respvar.Errorcode = 'AT-SUCC-111';
                    respvar.ErrorMessage = 'Transaction Successful';
                    respvar.TransactionNameAndValue = 'Asset: '+ sr.getId();
                    if(Asset_ID_AssetNum_Map.get(sr.getId())!=null){
                      respvar.Asset_number=Asset_ID_AssetNum_Map.get(sr.getId());
                    }
                    respvar.Sfdc_asset_number = sr.getId();
                    
                    if(Asset_ID_EntMastID_Map.get(sr.getId())!=null){
                      respvar.Customer_master_id = Asset_ID_EntMastID_Map.get(sr.getId());
                    }
                    if(Asset_ID_ProductCode_Map.get(sr.getId())!=null){
                      respvar.Item_number = Asset_ID_ProductCode_Map.get(sr.getId());
                    }  
                 
                      respvarlist.add(respvar);
                      
              }
              else {            
                  // Operation failed, so get all errors                
                  for(Database.Error err : sr.getErrors()) {
                      respvar = new ResponseWraperClass();
                      respvar.result ='Failure'; 
                      blnFinalResult = true;
                      respvar.Errorcode = 'AT-ERR-106:'+ err.getStatusCode();
                    respvar.ErrorMessage = 'Failure:'+ err.getMessage();
                    respvar.TransactionNameAndValue ='Asset: '+ sr.getid();
                    if(Asset_ID_AssetNum_Map.get(sr.getId())!=null){
                      respvar.Asset_number=Asset_ID_AssetNum_Map.get(sr.getId());
                    }
                    respvar.Sfdc_asset_number = sr.getId();
                    
                    if(Asset_ID_EntMastID_Map.get(sr.getId())!=null){
                      respvar.Customer_master_id = Asset_ID_EntMastID_Map.get(sr.getId());
                    }
                    if(Asset_ID_ProductCode_Map.get(sr.getId())!=null){
                      respvar.Item_number = Asset_ID_ProductCode_Map.get(sr.getId());
                    }     
                      respvarlist.add(respvar);
                  }
              }
            }
        
         }
        
        }catch(Exception ex){
            respvar = new ResponseWraperClass();  
            respvar.result ='Failure';
            blnFinalResult = true;
            blnSystemException = true;
            respvar.Errorcode = 'AT-ERR-108';
            respvar.ErrorMessage = string.valueof(ex);
            //respvar.TransactionNameAndValue = 'Asset:'+ sr.getid();
            respvarlist.add(respvar);
            
            system.debug('exception ====='+ex); 
            system.debug('exception ====='+ex.getStackTraceString());  
                     
              
                
        }
        
        if (blnFinalResult==true) {
          respvar = new ResponseWraperClass();
          respvar.FinalResult = 'Failure';
          respvarlist.add(respvar);
          
        }else{
          respvar = new ResponseWraperClass();
          respvar.FinalResult = 'Success';
          respvarlist.add(respvar);
        }
        
        
        return respvarlist;
    }
    
    Public void CreateIstoreNotes(Map<String,List<RequestNotesdata>> InputMap)
    {
    Set<String>NoteIDInterface = new Set<String>();
    Set<String>NoteIDSalesforce = new Set<String>();
    List<Asset> AssetList = new List<Asset>([select id,Name,Asset_Oracle_ID__c from Asset where Asset_Oracle_ID__c in :InputMap.keyset()]);
    List<iStore_Note__c> IstoreObj = new List<iStore_Note__c>();
    List<iStore_Note__c> IstoreObjCheck = new List<iStore_Note__c>();
    
    for(Asset Asst : AssetList)
    {
    for(RequestNotesdata reqNote : InputMap.get(Asst.Asset_Oracle_ID__c))
     {
      NoteIDInterface.add(reqNote.NOTE_ID);
     }
    }
     for(iStore_Note__c iNotes : [select id,Note_ID__c  from iStore_Note__c where Note_ID__c in: NoteIDInterface])
     {
      NoteIDSalesforce.add(iNotes.Note_ID__c);
     }
    for(Asset Asst : AssetList)
    {
     for(RequestNotesdata reqNote : InputMap.get(Asst.Asset_Oracle_ID__c))
     {
      if(!NoteIDSalesforce.contains(reqNote.NOTE_ID)){
      iStore_Note__c isn = new iStore_Note__c();
      isn.Name = Asst.Name+'_'+reqNote.NOTE_ID;
      isn.Asset__c = Asst.id;
      isn.Note_ID__c = reqNote.NOTE_ID;
      isn.Notes__c = reqNote.NOTE_TEXT;
      isn.Note_Created_By__c = reqNote.Note_Created_By;
      if(reqNote.NOTE_CREATION_DATE != Null && reqNote.NOTE_CREATION_DATE!='')
      {
      String Str='';
      str = reqNote.NOTE_CREATION_DATE.replace('T',' ');
      str = str.replace('.000-07:00','');
      DateTime.Valueof(str);
      isn.NOTE_CREATION_DATE__c = DateTime.Valueof(str);
      }
      IstoreObj.add(isn);
     }
    }
    }
    if(IstoreObj.size()>0) Insert IstoreObj;
    }
    
     global class requestdata { 
        //Asset data       
        webservice String CustomerMasterID;
        webservice String OwnerAccountName;
        webservice String AssetName;
        webservice String AssetProductFamily;
        webservice String AssetSerialNumber;
        webservice String AssetInstallDate;
        webservice String AssetQuantity;
        webservice String AssetStatus;
        webservice String AssetLicenseKey;
        webservice String AssetProduct;
        webservice String AssetVersion;
        webservice String AssetPrice;
        webservice String AssetEndDate;  
        webservice String CurrencyCode; 
        webservice String AssetProductId;   
        webservice String ShipToFCHPartyID;
        webservice String ShipToFCHPartySiteID;
        webservice String BillToFCHPartyID;
        webservice String BillToFCHPartySiteID;  
        
        //created for TAP
        webservice string TAP_POS_TYPE;
        webservice string TAP_MODEL;
        webservice string TAP_FIRMWARE;
        webservice string TAP_MANUFACTURER;
        webservice string TAP_SIM_INCLUDED;
        webservice string TAP_SIM_NUMBER;
        webservice string TAP_CARRIER_NAME;
        webservice string TAP_GSM_NUMBER;
        webservice string TAP_SSO_USER_EMAIL;
        webservice string TAP_SIM_STATUS;
        webservice string TAP_SIM_CONTRACT_START_DATE;
        webservice string TAP_SIM_CONTRACT_END_DATE;
        webservice string TAP_RELATED_POS_ID;
        webservice string TAP_RELATED_POS_TYPE;
        webservice string TAP_AUTO_RENEWAL;
        webservice string TAP_CURR_OWNER_TRX_DATE;
        Webservice List<RequestNotesdata> istoreNotes;

        
        webservice string attribute1;
        webservice string attribute2;
        webservice string attribute3;
        webservice string attribute4;
        webservice string attribute5;
        webservice string attribute6; 
        webservice string attribute7; 
        webservice string attribute8; 
        webservice string attribute9; 
        webservice string attribute10;
        webservice string attribute11;
        webservice string attribute12;
        webservice string attribute13;
        webservice string attribute14;
        webservice string attribute15;
        webservice string attribute16;
        webservice string attribute17;
        webservice string attribute18;
        webservice string attribute19;
        webservice string attribute20;
        
         webservice String NOTE_ID;
    } 
        
     global class ResponseWraperClass{     
        webservice String Result{get;set;}    
        webservice String FinalResult{get;set;}
        webservice String Errorcode{get;set;}    
        webservice String ErrorMessage{get;set;} 
        webservice String TransactionNameAndValue{get;set;}
        //webservice String TransactionValue{get;set;} 
        webservice String Asset_number{get;set;}   
        webservice String Sfdc_asset_number{get;set;}
        webservice String Customer_master_id{get;set;}
        webservice String Item_number{get;set;} 
    }
    
    global class RequestNotesdata{ 
        //Notes data       
        webservice String NOTE_ID;
        webservice String NOTE_TYPE;
        webservice String NOTE_REFERENCE;
        webservice String NOTE_CREATION_DATE;
        webservice String NOTE_TEXT;
        webservice String Note_Created_By;
        webservice String ATTRIBUTE1;
        webservice String ATTRIBUTE2;
        webservice String ATTRIBUTE3;
        webservice String ATTRIBUTE4;
        webservice String ATTRIBUTE5;
       }
}