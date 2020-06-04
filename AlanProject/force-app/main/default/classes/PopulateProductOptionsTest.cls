@isTest
private class PopulateProductOptionsTest {
    
    public static Apttus_Config2__ProductOptionComponent__c component;
    public static Product2 parentProduct;
    public static Product2 productComponent;
    
    public static testMethod void setUpData(){           
        
        parentProduct = new Product2();
        parentProduct.Name = 'Hauptserver';
        insert parentProduct; 
         
        productComponent = new Product2();
        productComponent.Name = '1GB DDR-DIMM PC3200';
        productComponent.Option_Name_DE__c = '1GB DDR-DIMM PC3200';
        productComponent.Option_Name_EN__c = '1GB DDR-DIMM PC3200';
        productComponent.Option_Name_FR__c = '1GB DDR-DIMM PC3200';
        insert productComponent;
         
        component = new Apttus_Config2__ProductOptionComponent__c();
        component.Apttus_Config2__Sequence__c = 1;
        component.Apttus_Config2__ParentProductId__c = parentProduct.Id;
        component.Apttus_Config2__ComponentProductId__c = productComponent.Id;
        insert component;                            
    }
}