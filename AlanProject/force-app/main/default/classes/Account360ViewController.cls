/*
Srini - 10/17 updated Duration field to Formula and updated to String value in below code
Srini - 10/17 updated End Date with Expire Date
*/
public class Account360ViewController {
    public Id accountId{get;set;} 
    public string accountFCHPartyId{get;set;} 
    public transient string assetList;
    public transient string entitlementList;
    public transient string entitlementListFilter;
    public transient string Headerdetail;
    public transient string CaseList;
    public transient string OrderList;
    public transient string CustomerHistory;
    public transient string SelectedEntitlementID{get;set;}
    public string EntitlementIdSet{get;set;}
    public transient string Validationresult{get;set;}
    public Account Acc;
    public string assetOracleIds{get;set;}
    private static JSONGenerator gen;
    public boolean loadPanel1{get;set;}
    public boolean loadPanel2{get;set;}
    public boolean loadPanel3{get;set;}
    public boolean showAllRecord{get;set;}
    public Map<String,String> currencySymbol;
    public Account360ViewController(){
        assetOracleIds = '';
        loadPanel1 = false;
        loadPanel2 = false;
        loadPanel3 = false;
        accountId = Apexpages.currentPage().getParameters().get('Id');
        showAllRecord = false;
        if(Apexpages.currentPage().getParameters().containsKey('showAllRecord'))
            showAllRecord = (Apexpages.currentPage().getParameters().get('showAllRecord') == 'All');
        Acc = [select id,Name,Phone,EBS_Account_Number__c,Sub_Type__c,Type,FCH_Party_Id__c from Account where id=:accountId];
        accountFCHPartyId = acc.FCH_Party_ID__c;
        
        currencySymbol = new Map<String,String>();
        for(Currency_Config__mdt curr :  [select DeveloperName,Symbol__c from Currency_Config__mdt]){
            currencySymbol.put(curr.DeveloperName,curr.Symbol__c);
        }
    }
    
    public void resetLoadPanel1(){
        loadPanel1 = true;
    }
    
    public void resetLoadPanel2(){
        loadPanel2 = true;
    }
    
    public void resetLoadPanel3(){
        loadPanel3 = true;
    }
    
    public pageReference showAllRecord(){
        Pagereference pageRef;
        if(!showAllRecord)
            pageRef = new pagereference('/apex/Account360View6?showAllRecord=All&Id=' + accountId);
        else
            pageRef = new pagereference('/apex/Account360View6?Id=' + accountId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public string getHeaderdetail(){
        List<Credit_Details_Tab_Customer_Account__c> creditList = new List<Credit_Details_Tab_Customer_Account__c>(
            [select id,Available_Credit_Line_ACL__c,Overdue_Payment_OD__c,Currency__c,Account__c from Credit_Details_Tab_Customer_Account__c
             where Account__c =:accountId order by lastmodifieddate DESC]);
        List<Contact> ContListMatch = new List<Contact>([select id,FirstName,LastName,Job_Role__c from contact where 
                                                         Phone=:Acc.Phone and AccountId =: accountId]);
        
        gen = JSON.createGenerator(true);
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('Id', Acc.Id);
        gen.writeStringField('Name', Acc.Name);
        gen.writeStringField('Type', string.isNotBlank(Acc.Type)? Acc.Type: '');
        gen.writeStringField('SubType', string.isNotBlank(Acc.Sub_Type__c)? Acc.Sub_Type__c: '');
        gen.writeStringField('OAC', (string.isNotBlank(Acc.EBS_Account_Number__c) ? Acc.EBS_Account_Number__c : ''));
        if(creditList.size()>0){
            gen.writeNumberField('ACL', (creditList.get(0).Available_Credit_Line_ACL__c != Null ? Integer.valueof(creditList.get(0).Available_Credit_Line_ACL__c): 0));
            gen.writeNumberField('OD',  (creditList.get(0).Overdue_Payment_OD__c != Null ? Integer.valueof(creditList.get(0).Overdue_Payment_OD__c): 0));
            gen.writeStringField('Currency',  (currencySymbol.containsKey(creditList.get(0).Currency__c) ? currencySymbol.get(creditList.get(0).Currency__c) : creditList.get(0).Currency__c));
        }else{
            gen.writeStringField('ACL','');
            gen.writeStringField('OD', '');
        }
        
       /* if(ContListMatch.size()>0){
            gen.writeStringField('ContactName', ContListMatch.get(0).FirstName + ' ' + ContListMatch.get(0).LastName);
            gen.writeStringField('ContactRole', String.valueof(ContListMatch.get(0).Job_Role__c != null ? ContListMatch.get(0).Job_Role__c : ''));
        }else{
            if(ContListMatch.size()>0){
                gen.writeStringField('ContactName', ' ');
                gen.writeStringField('ContactRole', ' ');
            }
        }*/
        
        gen.writeEndObject();
        gen.writeEndArray();
        return gen.getAsString(); 
    }
    
    public string getEntitlementListFilter(){
        Integer expireNextDateRange = 0;
        Integer expirePastDateRange = 0;
        set<string> excludeNames = new set<string>();
        for(X360_Dashboard_Setting__mdt dashboardSetting : [select ID,DeveloperName,Include_Number_of_Days__c,Exclude_Entitlement_Name__c from X360_Dashboard_Setting__mdt]){
            if(dashboardSetting.Exclude_Entitlement_Name__c != null && dashboardSetting.Exclude_Entitlement_Name__c != '')
                excludeNames.add(dashboardSetting.Exclude_Entitlement_Name__c);
            
            if(dashboardSetting.DeveloperName == 'Entitlement_Device_List_NEXT_Days' && dashboardSetting.Include_Number_of_Days__c != null)
                expireNextDateRange = Integer.valueOf(dashboardSetting.Include_Number_of_Days__c);
            
            if(dashboardSetting.DeveloperName == 'Entitlement_Device_List_LAST_Days' && dashboardSetting.Include_Number_of_Days__c != null)
                expirePastDateRange = Integer.valueOf(dashboardSetting.Include_Number_of_Days__c);
        }
        
        Date expireDate = Date.Today();
        expireDate = expireDate.addDays(expireNextDateRange);
        
        system.debug('-------expireDate--------' + expireDate);
        assetOracleIds = '';
        gen = JSON.createGenerator(true);
        gen.writeStartArray();
        
        string query = '';
        string futureEntitlementQuery = '';
        if(showAllRecord){
            query = 'select Subscription_ID__c,Renewal_Order_Number__c,Asset_Oracle_Number__c,Asset_s_Serial_Number__c,' +
                               'Serial_Number__c,Entitlement_Product__r.Name,Oracle_Unique_Identifier__c,Assetid,' +
                               'Asset_Effectivity__c,Duration__c,Days_Left__c,Hours_Used__c,Pricing_Region__c,Geofence_Region__c,' +
                               'ID,Name,Startdate,Enddate,Expire_Date__c,Status from Entitlement where AccountId =: accountId and Assetid!= Null order by Expire_Date__c ASC';
        }else{
            query = 'select Subscription_ID__c,Renewal_Order_Number__c,Asset_Oracle_Number__c,Asset_s_Serial_Number__c,' +
                               'Serial_Number__c,Entitlement_Product__r.Name,Oracle_Unique_Identifier__c,Assetid,' +
                               'Asset_Effectivity__c,Duration__c,Days_Left__c,Hours_Used__c,Pricing_Region__c,Geofence_Region__c,' +
                               'ID,Name,Startdate,Enddate,Expire_Date__c,Status from Entitlement where AccountId =: accountId and Assetid!=Null and ' + 
                               '(Expire_Date__c = NEXT_N_DAYS:' + expireNextDateRange + ' OR Expire_Date__c = LAST_N_DAYS:' + expirePastDateRange + 
                                             ') order by Expire_Date__c ASC';
            futureEntitlementQuery = 'select Serial_Number__c,Expire_Date__c from Entitlement where AccountId =: accountId and Assetid!=Null and ' + 
                               'Expire_Date__c >: expireDate order by Expire_Date__c ASC';
        }
        
        Map<String,Date> assetExpireDate = new Map<String,Date>();
        if(!showAllRecord){
            for(Entitlement ent : database.query(futureEntitlementQuery)){
                system.debug('-------ent--------' + ent);
                assetExpireDate.put(ent.Serial_Number__c,ent.Expire_Date__c);
            }
        }
        
        system.debug('-------assetExpireDate--------' + assetExpireDate);

        Map<string, Entitlement> entMap = new Map<string, Entitlement>();
        for(Entitlement ent : database.query(query)){
            // entMap.put(ent.Serial_Number__c, ent.Expire_Date__c);
            if(entMap.containsKey(ent.Serial_Number__c) ? ent.Expire_Date__c > entMap.get(ent.Serial_Number__c).Expire_Date__c : true){
                if(assetExpireDate.containsKey(ent.Serial_Number__c) ? assetExpireDate.get(ent.Serial_Number__c) <= ent.Expire_Date__c : true)
                    entMap.put(ent.Serial_Number__c, ent);
            }
        }
        
        for(Entitlement ent : entMap.values()){
            boolean skip = false;
            for(String str : excludeNames){            
                if(ent.Name.containsIgnoreCase(str))skip = true;
            }
            if(!skip){
                gen.writeStartObject();
                gen.writeStringField('POSID', (string.isNotBlank(ent.Serial_Number__c) ? ent.Serial_Number__c: ''));
                gen.writeStringField('Service', (string.isNotBlank(ent.Entitlement_Product__r.Name) ? ent.Entitlement_Product__r.Name: ''));
                gen.writeStringField('Status', (string.isNotBlank(ent.Asset_Effectivity__c) ? ent.Asset_Effectivity__c: ''));
                gen.writeStringField('StartDate', (ent.Startdate == null ? '' : ent.Startdate.format()));
                gen.writeStringField('Duration', String.valueof((ent.Duration__c == null) ? 0 : ent.Duration__c));
                if(ent.Days_Left__c > 0){
                    gen.writeStringField('DaysLeft', String.valueof((ent.Days_Left__c== null ? 0 : ent.Days_Left__c)));
                }else{
                    gen.writeStringField('DaysLeft', '-');
                }
                gen.writeStringField('HoursUsed', (string.isNotBlank(ent.Hours_Used__c) ? ent.Hours_Used__c: ''));
                gen.writeStringField('PricingRegion', (string.isNotBlank(ent.Pricing_Region__c) ? ent.Pricing_Region__c: ''));
                gen.writeStringField('GeofenceRegion', (string.isNotBlank(ent.Geofence_Region__c) ? ent.Geofence_Region__c: ''));
                gen.writeStringField('Id', (string.isNotBlank(ent.Id) ? ent.Id : ''));
                if(ent.AssetId != null)
                    gen.writeStringField('AssetId', ent.AssetId);
                else
                    gen.writeStringField('AssetId', '');gen.writeStringField('Name', (string.isNotBlank(ent.Name) ? ent.Name : ''));
                gen.writeStringField('ExpireDate', (ent.Expire_Date__c == null ? '' : ent.Expire_Date__c.format()));
                gen.writeStringField('OracleUniqueIdentifier', (string.isNotBlank(ent.Oracle_Unique_Identifier__c) ? ent.Oracle_Unique_Identifier__c: ''));
                gen.writeStringField('AssetOracleID', (string.isNotBlank(ent.Asset_Oracle_Number__c) ? ent.Asset_Oracle_Number__c: ''));
                
                assetOracleIds = assetOracleIds + ',' + (string.isNotBlank(ent.Asset_Oracle_Number__c) ? ent.Asset_Oracle_Number__c: '');
                                       
                gen.writeStringField('RenewalOrderNumber', (string.isNotBlank(ent.Renewal_Order_Number__c) ? ent.Renewal_Order_Number__c: ''));
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        assetOracleIds = (assetOracleIds.length() > 0 ? assetOracleIds.right(assetOracleIds.length() - 1) : '');
        
        return gen.getAsString(); 
    }
    
    public string getOrderList(){
        system.debug('------assetOracleIds--------' + assetOracleIds);
        set<Id> OrderIds = new set<Id>();
        for(Order_Line_Item__c OrderLiTm : [select Order__c from Order_Line_Item__c where 
                              Order__r.Account__c=: accountId and Asset_Oracle_Id__c in : assetOracleIds.split(',') and Order__c != null]){
            OrderIds.add(OrderLiTm.Order__c);
        }
        
        String AssetoracleId='';
        gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for(Order__c Order : [select ID,Name,Order_Type__c,Ordered_by__c,CreatedBy.Email,Order_Date__c,Sold_To__r.Name,Account__r.Name,
                              PO_Number__c,Oracle_Order_Number__c,Order_Status__c,(Select id,Asset_Oracle_Id__c from Order_Line_Items__r where Asset_Oracle_Id__c in : assetOracleIds.split(',')) from 
                              Order__c where Account__c=: accountId and Id in : OrderIds order by Order_Date__c DESC]){
            gen.writeStartObject();
            gen.writeStringField('Id', (string.isNotBlank(Order.Id) ? Order.Id : ''));
            gen.writeStringField('Name', (string.isNotBlank(Order.Name) ? Order.Name : ''));
            gen.writeStringField('OrderType', (string.isNotBlank(Order.Order_Type__c) ? Order.Order_Type__c: ''));
            gen.writeStringField('CreatedBy', (string.isNotBlank(Order.Ordered_by__c) ? Order.Ordered_by__c: ''));
            gen.writeStringField('EndCustomer', (string.isNotBlank(Order.Account__r.Name) ? Order.Account__r.Name: ''));
            gen.writeStringField('InvoiceTo', (string.isNotBlank(Order.Sold_To__r.Name) ? Order.Sold_To__r.Name: ''));
            gen.writeStringField('PONumber', (string.isNotBlank(Order.PO_Number__c) ? Order.PO_Number__c: ''));
            gen.writeStringField('oracleOrderNumber', (string.isNotBlank(Order.Oracle_Order_Number__c) ? Order.Oracle_Order_Number__c: ''));
            gen.writeStringField('Status', (string.isNotBlank(Order.Order_Status__c) ? Order.Order_Status__c: ''));
            gen.writeStringField('OrderDate', (Order.Order_Date__c == null ? '' : Order.Order_Date__c.format('dd-MMM-yyyy HH:mm:ss')));
            for(Order_Line_Item__c Orderline : Order.Order_Line_Items__r){
                AssetoracleId = AssetoracleId + ','+ Orderline.Asset_Oracle_Id__c;
            }
                                  
            system.debug(Order.Id + '------AssetOracleID--------' + AssetOracleID);
            gen.writeStringField('AssetOracleID', AssetoracleId);
            AssetoracleId='';
            gen.writeEndObject();
        }
        OrderIds.clear();
        gen.writeEndArray();
        return gen.getAsString();
    }
    
    public string getAssets(){
        gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for(Asset Asst : [select ID,Name,Auto_Renewal__c,InstallDate,TAP_CURR_OWNER_TRX_DATE__c,SerialNumber,Asset_Oracle_ID__c,Pos_Type__c,
                          Manufacturer__c,Model__c,Bill_To_Account__r.Name,Ship_To_Account__r.Name from Asset where 
                          Accountid=: accountId]){
            gen.writeStartObject();
            gen.writeStringField('Id', (string.isNotBlank(Asst.Id) ? Asst.Id : ''));
            gen.writeStringField('Name', (string.isNotBlank(Asst.Name) ? Asst.Name : ''));
            gen.writeStringField('POSID', (string.isNotBlank(Asst.SerialNumber) ? Asst.SerialNumber: ''));
            gen.writeStringField('POSType', (string.isNotBlank(Asst.Pos_Type__c) ? Asst.Pos_Type__c: ''));
            gen.writeStringField('Manufacturer', (string.isNotBlank(Asst.Manufacturer__c) ? Asst.Manufacturer__c: ''));
            gen.writeStringField('Model', (string.isNotBlank(Asst.Model__c) ? Asst.Model__c: ''));
            gen.writeStringField('EndCustomer', (string.isNotBlank(Asst.Bill_To_Account__r.Name) ? Asst.Bill_To_Account__r.Name: ''));
            gen.writeStringField('InvoiceTo', (string.isNotBlank(Asst.Ship_To_Account__r.Name) ? Asst.Ship_To_Account__r.Name: ''));
            gen.writeStringField('AssetOracleID', (string.isNotBlank(Asst.Asset_Oracle_ID__c) ? Asst.Asset_Oracle_ID__c: ''));
            gen.writeStringField('TransactionDate', (Asst.TAP_CURR_OWNER_TRX_DATE__c == null? (Asst.InstallDate != null ? Asst.InstallDate.format() : '') : Asst.TAP_CURR_OWNER_TRX_DATE__c.format()));
            gen.writeBooleanField('AutoRenewal', Asst.Auto_Renewal__c);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        return gen.getAsString();
    }
    
    public string getEntitlementList(){
        set<string> excludeNames = new set<string>();
        for(X360_Dashboard_Setting__mdt dashboardSetting : [select ID,DeveloperName,Include_Number_of_Days__c,Exclude_Entitlement_Name__c from X360_Dashboard_Setting__mdt]){
            if(dashboardSetting.Exclude_Entitlement_Name__c != null && dashboardSetting.Exclude_Entitlement_Name__c != '')
                excludeNames.add(dashboardSetting.Exclude_Entitlement_Name__c);
            
        }
        
        system.debug('------assetOracleIds--------' + assetOracleIds);
        gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for(Entitlement ent : [select Subscription_ID__c,Renewal_Order_Number__c,Asset_Oracle_Number__c,Asset_s_Serial_Number__c,
                               Serial_Number__c,Entitlement_Product__r.Name,Oracle_Unique_Identifier__c,Assetid,
                               Asset_Effectivity__c,Duration__c,Days_Left__c,Hours_Used__c,Pricing_Region__c,Geofence_Region__c, 
                               ID,Name,Startdate,Enddate,Expire_Date__c,Status from Entitlement where AccountId =: accountId and Assetid!=Null and 
                               Asset_Oracle_Number__c in : assetOracleIds.split(',') order by Expire_Date__c DESC]){
            boolean skip = false;
            for(String str : excludeNames){            
                if(ent.Name.containsIgnoreCase(str))skip = true;
            }
            
            if(!skip){
                gen.writeStartObject();
                gen.writeStringField('POSID', (string.isNotBlank(ent.Serial_Number__c) ? ent.Serial_Number__c: ''));
                gen.writeStringField('Service', (string.isNotBlank(ent.Entitlement_Product__r.Name) ? ent.Entitlement_Product__r.Name: ''));
                gen.writeStringField('Status', (string.isNotBlank(ent.Asset_Effectivity__c) ? ent.Asset_Effectivity__c: ''));
                gen.writeStringField('StartDate', (ent.Startdate == null ? '' : ent.Startdate.format()));
                 gen.writeStringField('Duration', String.valueof((ent.Duration__c == null) ? 0 : ent.Duration__c));
                if(ent.Days_Left__c > 0){
                    gen.writeStringField('DaysLeft', String.valueof((ent.Days_Left__c== null ? 0 : ent.Days_Left__c)));
                }else{
                    gen.writeStringField('DaysLeft', '-');
                }
                gen.writeStringField('HoursUsed', (string.isNotBlank(ent.Hours_Used__c) ? ent.Hours_Used__c: ''));
                gen.writeStringField('PricingRegion', (string.isNotBlank(ent.Pricing_Region__c) ? ent.Pricing_Region__c: ''));
                gen.writeStringField('GeofenceRegion', (string.isNotBlank(ent.Geofence_Region__c) ? ent.Geofence_Region__c: ''));
                gen.writeStringField('Id', (string.isNotBlank(ent.Id) ? ent.Id : ''));
                if(ent.AssetId != null)
                    gen.writeStringField('AssetId', ent.AssetId);
                else
                    gen.writeStringField('AssetId', '');
                gen.writeStringField('Name', (string.isNotBlank(ent.Name) ? ent.Name : ''));
                gen.writeStringField('ExpireDate', (ent.Expire_Date__c == null ? '' : ent.Expire_Date__c.format()));
                gen.writeStringField('OracleUniqueIdentifier', (string.isNotBlank(ent.Oracle_Unique_Identifier__c) ? ent.Oracle_Unique_Identifier__c: ''));
                gen.writeStringField('AssetOracleID', (string.isNotBlank(ent.Asset_Oracle_Number__c) ? ent.Asset_Oracle_Number__c: ''));
                gen.writeStringField('RenewalOrderNumber', (string.isNotBlank(ent.Renewal_Order_Number__c) ? ent.Renewal_Order_Number__c: ''));
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        return gen.getAsString(); 
    }
    
    public string getiStoreNotes(){
        gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for(iStore_Note__c iNote : [select ID,Name,Account__c,Notes__c,Asset__r.Asset_Oracle_ID__c,Note_Created_By__c,Note_ID__c,NOTE_CREATION_DATE__c,Active__c
                                    from iStore_Note__c where Account__c =: accountId or Asset__r.AccountId =: accountId order by NOTE_CREATION_DATE__c DESC]){
            gen.writeStartObject();
            gen.writeStringField('Id', (string.isNotBlank(iNote.Id) ? iNote.Id : ''));
            gen.writeStringField('AssetOracleID', (string.isNotBlank(iNote.Asset__r.Asset_Oracle_ID__c) ? iNote.Asset__r.Asset_Oracle_ID__c: ''));
            if(iNote.Account__c != null)
                gen.writeStringField('AccountId', iNote.Account__c);
            else
                gen.writeStringField('AccountId', '');
            
            gen.writeStringField('Notes', (string.isNotBlank(iNote.Notes__c) ? iNote.Notes__c: ''));
           // gen.writeStringField('NoteId', (string.isNotBlank(iNote.Note_ID__c) ? iNote.Note_ID__c : ''));
            gen.writeStringField('CreateDate', (iNote.NOTE_CREATION_DATE__c == null ? '' : iNote.NOTE_CREATION_DATE__c.format('dd-MMM-yyyy HH:mm:ss')));
            gen.writeBooleanField('Active', iNote.Active__c);
            gen.writeStringField('CreatedBy', (string.isNotBlank(iNote.Note_Created_By__c) ? iNote.Note_Created_By__c: ''));
            gen.writeEndObject();
        }
        gen.writeEndArray();
        return gen.getAsString();
    }
    
    public string getCaseList(){
        gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for(Case cs : [select ID,CaseNumber,owner.LastName,Status,Priority,Type from Case where AccountId =: accountId and RecordType.Name = 'TAP - Customer Support']){
            gen.writeStartObject(); 
            gen.writeStringField('Id', (string.isNotBlank(cs.Id) ? cs.Id : ''));
            gen.writeStringField('CaseNumber', (string.isNotBlank(cs.CaseNumber) ? cs.CaseNumber : ''));
            gen.writeStringField('OwnerLastName', (string.isNotBlank(cs.owner.LastName) ? cs.owner.LastName : ''));
            gen.writeStringField('Status', (string.isNotBlank(cs.Status) ? cs.Status : ''));
            gen.writeStringField('Priority', (string.isNotBlank(cs.Priority) ? cs.Priority: ''));
            gen.writeStringField('Type', (string.isNotBlank(cs.Type) ? cs.Type: ''));
            gen.writeStringField('Style', (cs.Priority == 'Level 1: Escalation' ? 'color:red' : ''));
            gen.writeEndObject();
        }
        gen.writeEndArray();
        return gen.getAsString();
    }
    
    public string getActivityList(){
        gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for(Task et : [select ID,who.Name,Subject,Type,ActivityDate,Status from Task where (whoid=: accountId or 
                       whatid =:accountid) and Owner.Profile.Name like 'TAP%' and ActivityDate = LAST_N_Days:14]){
            gen.writeStartObject();
            gen.writeStringField('Id', (string.isNotBlank(et.Id) ? et.Id : ''));
            gen.writeStringField('Name', (string.isNotBlank(et.Subject) ? et.Subject : ''));
            gen.writeStringField('Type', (string.isNotBlank(et.Type) ? et.Type : ''));
            gen.writeStringField('ActivityDate', (et.ActivityDate == null ? '' : et.ActivityDate.format()));
            gen.writeStringField('Status', (string.isNotBlank(et.Status) ? et.Status : ''));
            gen.writeStringField('Style', ((et.ActivityDate < System.today() && et.Status != 'Completed') ? 'color:red' : ''));
            gen.writeEndObject();
        }
        
        for(Event et : [select ID,who.Name,Subject,Type,ActivityDate from Event where (whoid=: accountId or 
                        whatid =:accountid) and Owner.Profile.Name like 'TAP%' and ActivityDate = LAST_N_Days:14]){
            gen.writeStartObject();
            gen.writeStringField('Id', (string.isNotBlank(et.Id) ? et.Id : ''));
            gen.writeStringField('Name', (string.isNotBlank(et.Subject) ? et.Subject : ''));
            gen.writeStringField('Type', (string.isNotBlank(et.Type) ? et.Type : ''));
            gen.writeStringField('ActivityDate', (et.ActivityDate == null ? '' : et.ActivityDate.format()));
            gen.writeStringField('Status','');
            gen.writeStringField('Style', (et.ActivityDate > System.today() ? 'color:red' : ''));
            gen.writeEndObject();
        }
        
        
        gen.writeEndArray();
        return gen.getAsString();
    }
    
    public pageReference returnToAccount(){
        system.debug('------------' + accountId);
        return new pageReference('/' + accountId);
    }
    
    public PageReference newOrder(){
        pagereference Pg = new Pagereference('http://usd-am-isa-345.trimblecorp.net:8000/OA_HTML/tnvo_ibeSalesfoceIntermediatePage.jsp');
        Pg.setredirect(true);
        return Pg;
        
    }
    
    Public void customvalidations()
    {
        Set<String>PosType = new Set<String>();
        Set<String>RenewlOrderNum = new Set<String>();
        Set<String>AutoRenwal = new Set<String>();
        Set<String>EntitlementId = new Set<String>();
        List<String>EntitlementIdTemp = new List<String>();
        EntitlementIdTemp = EntitlementIdSet.split('\\|');
        EntitlementId.addAll(EntitlementIdTemp);
        
        
        for(Entitlement Ent  : [Select id,Asset.Pos_Type__c,Asset.Auto_Renewal__c,Renewal_Order_Number__c from Entitlement where 
                                Oracle_unique_Identifier__c in: EntitlementId])
        {
            if(Ent.Asset.Pos_Type__c != Null) PosType.add(Ent.Asset.Pos_Type__c);
            if(Ent.Renewal_Order_Number__c != Null) RenewlOrderNum.add(Ent.Renewal_Order_Number__c);
            if(Ent.Asset.Auto_Renewal__c == True) AutoRenwal.add(Ent.id);
        }
        
        system.debug('>>>>>>>>>>>>>'+PosType);
        system.debug('>>>>>>>>>>>>>'+RenewlOrderNum);
        if((PosType.Contains('OMNI') && PosType.Contains('RTX')) || (PosType.Contains('OMNI') && PosType.Contains('VRS')))
            Validationresult = 'Please select Subscriptions with same POS Type';
       /* else if(RenewlOrderNum.size()>0)
            Validationresult ='Please select Subscriptions without Renewal Order';
        else if(AutoRenwal.size()>0)
            Validationresult ='This subscription cannot be manually renewed because it is set to auto-renew';*/
        else 
            Validationresult = 'Success';
        
        
    }
}