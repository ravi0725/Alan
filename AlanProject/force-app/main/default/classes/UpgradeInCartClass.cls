/*****************************************************************************************
    Name    : UpgradeInCartClass
    Desc    : Used to display the Asset from Asset object. User can select Asset, the selected Terms.                              
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo          10/09/2014          Created
******************************************************************************************/
public class UpgradeInCartClass{
    public Id CartDetailView{get;set;}
    public ID configRequestId {get;set;}
    Public ID AccountID {get;set;}
    Public ID ProposalID {get;set;}
    Public ID cartId {get;set;} 
    Public List<AssetWrapper> AssWrapList{get;set;}
    Public List<asset> AssetLineItem {get;set;}
    Map<ID,Product2> ProdMap = new Map<Id,Product2>();
    Set<ID>ProdID = new Set<ID>();
    public Id selectedAssetId{get;set;}
    public boolean proposalTypeUpdateFlag = false;
    public set<Id> selectedAssetIDs;
    Public Decimal InputFieldValue {get;set;}
    public string flowUI;
    public Decimal UpdatedPricePublic {get;set;}
    public ID AssetIDPublic {get;set;}
    public UpgradeInCartClass(){
        selectedAssetIDs = new set<Id>();
        configRequestId = ApexPages.CurrentPage().getParameters().get('configRequestId');  
        cartId = ApexPages.CurrentPage().getParameters().get('id');
        flowUI = System.currentPageReference().getParameters().get('flow'); 
        system.debug('----------------cartId-----------------' + cartId);
        Apttus_Config2__TempObject__c Config = [Select id,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,
                            Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c from 
                                Apttus_Config2__TempObject__c where id =: configRequestId];
        ProposalID = Config.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c;
        AccountID = config.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c;
        fetchAsset();
    } 
    
    public void fetchAsset(){
        AssWrapList = new List<AssetWrapper>();
        /*for(Asset a : [Select id,Name,Product2.Name,Product2.id,Service_Contract_Start_Date__c,Service_Contract_End_Date__c,
                            Status,Asset_Oracle_ID__c,Quantity,IsCompetitorProduct,Product_Group__c,Product_Type__c from Asset 
                                where Accountid=:AccountID]){*/
     /*   AssetLineItem = [Select id,Name,Asset_Oracle_ID__c,Apttus_Config2__MustUpgrade__c ,Selling_Price__c,
                            Apttus_Config2__ListPrice__c,Apttus_Config2__ProductId__c,Apttus_Config2__NetPrice__c,Apttus_Config2__Quantity__c 
                                from Apttus_Config2__AssetLineItem__c where Apttus_Config2__AccountId__c=:AccountID and 
                                    Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c != 'Bundle']; */
        
        set<Id> existPrdIdSet = new Set<ID>();
        set<string> assetOracleIds = new set<String>();
        for(Apttus_Config2__LineItem__c lineItem : [select Id, Asset_Oracle_ID__c,Apttus_Config2__ProductId__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: cartID]){
            existPrdIdSet.add(lineItem.Apttus_Config2__ProductId__c);
            if(string.isNOTBlank(lineItem.Asset_Oracle_ID__c))assetOracleIds.add(lineItem.Asset_Oracle_ID__c);
        }
        
        for(Asset a : [Select id,Quantity_Disp__c,Available_Quantity__c,License_Key__c,Product2.Product_Category_Type__c,SerialNumber,Quantity_To_be_Upgraded__c,Product_Code__c,Price,Name,Updated_Price__c,Product2.ProductCode,Reason_Code__c,Product2Id,Product2.Name,Asset_Oracle_ID__c,
                       Quantity,Status from asset where Accountid =:AccountID and Product2.Product_Category_Type__c != 'Hardware' and Status != 'Cancelled' order by Asset_Oracle_ID__c NULLS LAST/*and PRoduct2Id not in : existPrdIdSet*/]){
        
            AssetWrapper assWrap = new AssetWrapper();
            if(!selectedAssetIDs.contains(a.Id))assWrap.UpdateButton = false;
            else assWrap.UpdateButton = true;
            if(assetOracleIds.contains(a.Asset_Oracle_ID__c) && a.Asset_Oracle_ID__c != null && a.Asset_Oracle_ID__c != '')
                assWrap.UpdateButton = true;
            assWrap.cat = a;
            a.Updated_Price__c = a.Price;
            if(assWrap.cat.Asset_Oracle_ID__c!=Null && assWrap.cat.Asset_Oracle_ID__c!='')
            assWrap.AssetOracleID = true;
            else
            assWrap.AssetOracleID = false;
            asswrap.UpdatedPrice = a.Updated_Price__c;
            asswrap.Reasoncode  = a.Reason_Code__c;
           if(a.Available_Quantity__c == Null)
           a.Available_Quantity__c = a.Quantity_Disp__c;
           else
           a.Available_Quantity__c = a.Available_Quantity__c;
                           if(!selectedAssetIDs.contains(a.Id))a.Quantity_To_be_Upgraded__c = a.Available_Quantity__c;
           InputFieldValue  = a.Available_Quantity__c;
            ProdID.add(a.Product2.id);
            AssWrapList.add(assWrap); 
              
        }
      for(Product2 Pr : [Select id,Name from Product2 where id in: ProdID]){
      ProdMap.Put(Pr.id,Pr);
      }
    }
    
    
    public void removeAsset(){
        selectedAssetIDs.remove(selectedAssetId);
       List<Apttus_Config2__LineItem__c> Line = new List<Apttus_Config2__LineItem__c>();
        Line = [select id,Apttus_Config2__Quantity__c from Apttus_Config2__LineItem__c where Apttus_Config2__AssetId__c =:selectedAssetId and Apttus_Config2__ConfigurationId__c=:cartId and (Apttus_Config2__LineStatus__c = 'Cancelled' or Apttus_Config2__LineStatus__c = 'Upgraded')];
        delete Line;
       fetchAsset();
    }
    public void gotoPricing(){
        Map<Id,AssetWrapper> prdPriceMap = new Map<Id,AssetWrapper>();
        Map<Id,decimal> prdQtyMap = new Map<Id,Decimal>();
        AssetLineItem = new List<asset>();
        boolean updatedPriceFlag = false;
        boolean updatedReasonCodeFlag = false;
        boolean QtyUpdateFlag = false;
        for(AssetWrapper ass : AssWrapList)
        {
            if(ass.cat.Id == selectedAssetId)
            {
               // ass.UpdateButton = True;
                selectedAssetIDs.add(ass.cat.Id);
                //ass.cat.Updated_Price__c= ass.UpdatedPrice;
                ass.UpdatedPrice = ass.cat.Updated_Price__c;
                if(ass.UpdatedPrice != null)updatedPriceFlag = true;
                prdPriceMap.put(ass.cat.Product2ID,ass);
                prdQtyMap.Put(ass.cat.Product2ID,ass.cat.Quantity_To_be_Upgraded__c);
                    
                     
                if(ass.cat.Reason_Code__c != '' && ass.cat.Reason_Code__c != null)updatedReasonCodeFlag= true;
                
                if(ass.cat.Available_Quantity__c >= ass.cat.Quantity_To_be_Upgraded__c) QtyUpdateFlag= true;
                
                system.debug('>>>>>>ass.cat.Quantity_Disp__c>>>>>>>>'+ass.cat.Quantity_Disp__c);
                 system.debug('>>>>>>ass.cat.Quantity_To_be_Upgraded__c>>>>>>>>'+ass.cat.Quantity_To_be_Upgraded__c);
                AssetLineItem.add(ass.cat);
            }
            
           
        }
        
        if(updatedPriceFlag && updatedReasonCodeFlag && QtyUpdateFlag){
            system.debug('*&*&*&*&'+AssetLineItem);
            if(AssetLineItem.size()>0)
            update AssetLineItem;
            system.debug('*&*&*&*&'+AssetLineItem);
            List<Decimal> lineNumbers = new List<Decimal>();
            for(Asset ass : AssetLineItem){
                system.debug('--------------------' + ass);
                Apttus_CPQApi.CPQ.AddBundleRequestDO request = new Apttus_CPQApi.CPQ.AddBundleRequestDO(); 
                request.CartId = CartId;
                request.SelectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();  
                request.SelectedBundle.SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
                request.SelectedBundle.SelectedProduct.ProductId = ass.Product2Id;
                request.SelectedBundle.SelectedProduct.Quantity = -1 * prdQtyMap.get(ass.Product2Id);
                Apttus_CPQApi.CPQ.AddBundleResponseDO response = Apttus_CPQApi.CPQWebService.addBundle(request);
                system.debug('--------------------' + response);
                lineNumbers.add(response.LineNumber);
            }
            
          /*  for(Decimal lineNumber : lineNumbers){
                Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO priceRequest = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO(); 
                priceRequest.CartId = cartId; 
                priceRequest.LineNumber = lineNumber; 
                Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(priceRequest);
                system.debug('------------priceResponse-----------' + priceResponse);
            }*/
            List<Apttus_Config2__LineItem__c> updateLineList = new List<Apttus_Config2__LineItem__c>();
            for(Apttus_Config2__LineItem__c lineItem : [select Id,Apttus_Config2__BasePriceOverride__c ,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__Quantity__c,Apttus_Config2__AssetQuantity__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ProductId__c from Apttus_Config2__LineItem__c where 
                                                        Apttus_Config2__LineNumber__c in : lineNumbers and Apttus_Config2__ConfigurationId__c =: cartId]){
                lineItem.Apttus_Config2__LineStatus__c = 'Upgraded';  
                lineItem.Apttus_Config2__ChargeType__c ='Standard Price'; 
                if(prdPriceMap.get(lineItem.Apttus_Config2__ProductId__c) != null){
                UpdatedPricePublic = prdPriceMap.get(lineItem.Apttus_Config2__ProductId__c).updatedprice;
                AssetIDPublic = prdPriceMap.get(lineItem.Apttus_Config2__ProductId__c).cat.id;
                    lineItem.Apttus_Config2__ListPrice__c = prdPriceMap.get(lineItem.Apttus_Config2__ProductId__c).updatedprice;
                    lineItem.Apttus_Config2__NetPrice__c =  prdPriceMap.get(lineItem.Apttus_Config2__ProductId__c).updatedprice *LineItem.Apttus_Config2__Quantity__c;
                    //lineItem.Apttus_Config2__BaseExtendedPrice__c =  prdPriceMap.get(lineItem.Apttus_Config2__ProductId__c).updatedprice *LineItem.Apttus_Config2__Quantity__c;
                    LineItem.Apttus_Config2__PriceUom__c = 'Each';
                    LineItem.Apttus_Config2__AssetId__c = selectedAssetId;
                   // system.debug('extended price is ## :'+prdPriceMap.get(lineItem.Apttus_Config2__ProductId__c).updatedprice *prdQtyMap.get(lineItem.Apttus_Config2__ProductId__c));
                    LineItem.Apttus_Config2__ExtendedPrice__c = prdPriceMap.get(lineItem.Apttus_Config2__ProductId__c).updatedprice * LineItem.Apttus_Config2__Quantity__c;
                    LineItem.Asset_Oracle_ID__c = prdPriceMap.get(lineItem.Apttus_Config2__ProductId__c).cat.Asset_Oracle_ID__c;
                    LineItem.Apttus_Config2__IsCustomPricing__c = True;
                    lineItem.Apttus_Config2__BasePrice__c  = prdPriceMap.get(lineItem.Apttus_Config2__ProductId__c).updatedprice * LineItem.Apttus_Config2__Quantity__c;
                    lineItem.Apttus_Config2__BasePriceOverride__c = prdPriceMap.get(lineItem.Apttus_Config2__ProductId__c).updatedprice *LineItem.Apttus_Config2__Quantity__c;
                     
                updateLineList.add(lineitem);
                }
            }
            
            if(updateLineList.size() > 0){
                update updateLineList;
                
             /*   system.debug('updateLineList is :'+updateLineList);
                // create the update price request 
                Apttus_CpqApi.CPQ.UpdatePriceRequestDO request = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();   
                request.CartId = CartId;        
                
                // update price for the cart 
                Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(request);
                if(!proposalTypeUpdateFlag){
                    Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
                    proposal.Id = ProposalID;
                    proposal.Order_Type__c = 'UPG';
                    update proposal;
                    proposalTypeUpdateFlag = true;            
                }*/
              if(AssetIDPublic != Null) {
               Asset Ast = new Asset(id=AssetIDPublic,Updated_Price__c=UpdatedPricePublic);
               update Ast;
               }
               fetchAsset();
            }
        }else if(!updatedReasonCodeFlag && !updatedPriceFlag){
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter Updated Price and Reason Code.'));
        }else if(!updatedPriceFlag){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter Updated Price.'));
        }else if(!updatedReasonCodeFlag){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Reason Code.'));
        }
        if(!QtyUpdateFlag){
        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter Qty To be Upgrade lesser than Qty.'));
        }
        system.debug('--------------------' + cartId);
    } 
    
    public pageReference cancel(){
     if(flowUI=='Angular')
     return new pagereference('/apex/Apttus_Config2__Cart?id='+cartId+'&configRequestId='+configRequestId+'&flow='+flowUI);
     else
     return new pagereference('/apex/Apttus_Config2__Cart?id='+cartId+'&configRequestId='+configRequestId+'&flow=Default');
    }
  
    public class AssetWrapper{
        public Boolean checked{ get; set; }
        public Asset cat{ get; set; }
        public Decimal UpdatedPrice{get;set;}
        public transient Decimal UpdatedQty{get;set;}
        public String Reasoncode {get;set;}
        Public boolean UpdateButton {get;set;}
        public boolean AssetOracleID {get;set;}
        Public ID ProductID {get;set;}
       
    }
}