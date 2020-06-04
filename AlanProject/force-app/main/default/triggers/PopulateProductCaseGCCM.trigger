trigger PopulateProductCaseGCCM on Case (before insert, before update){
    
    
    Profile prof = [Select id,Name from Profile where Id =: UserInfo.getProfileId()];
    if(prof.Name.contains('GCCM')){
        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Case.SObjectType);
        List<Id> assetIdList = new List<Id>(); 
        for(Case c : trigger.new){
           if(c.AssetId != null)
              assetIdList.add(c.AssetId);
        }
        
        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        assetMap = new Map<Id, Asset>([Select Id, Product2Id from Asset where Id IN: assetIdList]);
        
        for(Case c : trigger.new){
           try{
             if(c.RecordTypeId == recordTypeMap.get(Label.Case_GCCM_Customer_Record_Type)){
                if(assetMap != null && assetMap.containsKey(c.AssetId))
                    c.ProductId = assetMap.get(c.AssetId).Product2Id;
             }  
           }catch(Exception e){
             c.addError(e.getMessage());
           }            
        }
    }    
}