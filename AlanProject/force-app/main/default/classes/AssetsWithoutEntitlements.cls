public class AssetsWithoutEntitlements{

    public static List<Asset> assetLst{get;set;}

    public AssetsWithoutEntitlements()
    {
        fetchRecords();
    }
     @readOnly
    @RemoteAction
    public static void fetchRecords()
    {
        assetLst = new List<Asset>();
        
        List<Id> assetIdLst = new List<Id>();
        
        for(Entitlement en: [Select StartDate, Quantity__c, Name, LastModifiedDate, LastModifiedBy.Name, Id, Entitlement_Total_Cost__c, Entitlement_Product__r.ProductCode, Entitlement_Product__r.Name, Entitlement_Product__c, EndDate, CreatedDate, CreatedBy.Name, Asset.Product_Type__c, Asset.Quantity, Asset.Status, Asset.SerialNumber, Asset.Name, Asset.LastModifiedBy.Name, Asset.LastModifiedDate, Asset.CreatedBy.Name, Asset.CreatedDate, Asset.Product2.Name,Asset.Product2.ProductCode, AssetId,Asset.Account.Legacy_System_ID_MSCRM__c, Asset.Account.Enterprise_Party_Number__c, Asset.Account.Enterprise_Master_ID_del__c, Asset.Account.Legacy_System_ID_GCCM__c, Asset.Account.BillingCountry, Asset.Account.BillingPostalCode, Asset.Account.BillingState, Asset.Account.BillingCity, Asset.Account.BillingStreet, Asset.Account.Name, Asset.AccountId, Asset.Account.Owner.Name, Asset.Account.Owner.Division__c From Entitlement where (Asset.Status='Purchased' OR Asset.Status='Installed' OR Asset.Status='Subscription') and (Asset.Product_Type__c = 'Vico')])
        {
            assetIdLst.add(en.AssetId);
        }
        
        
        assetLst = [Select Id, Product_Type__c, Quantity, Status, SerialNumber, Name, LastModifiedBy.Name, LastModifiedDate, CreatedBy.Name, CreatedDate, Product2.Name, Product2.ProductCode, Account.Legacy_System_ID_MSCRM__c, Account.Enterprise_Party_Number__c, Account.Enterprise_Master_ID_del__c, Account.Legacy_System_ID_GCCM__c, Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingCity, Account.BillingStreet, Account.Name, AccountId, Account.Owner.Name, Account.Owner.Division__c From Asset where (Status='Installed') and (Product_Type__c = 'Vico' ) and Id not in: assetIdLst order by Name DESC limit 2000];
    
    
    }
    
}