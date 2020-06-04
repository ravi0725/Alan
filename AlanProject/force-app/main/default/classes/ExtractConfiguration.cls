public class ExtractConfiguration{
    public String pageLoadType{get;set;}
    public String LoadType{get;set;}
    public String renderAs{get;set;}
    public transient List<ObjectWrapper> objWrapList{get;set;}
    public transient List<FieldWrapper> fldWrapList{get;set;}
    public transient Map<String,Profile> sysPermissionsMap{get;set;}
    public String renderedTab{get;set;}
    public transient List<MetadataService.ListView> ListViews{get;set;}
    Map<String,List<MetadataService.ListView>> listViewMap;
    //public transient List<MetadataService.ProfileTabVisibility> TabVisibility{get;set;}
    public String selectedObjectListView{get;set;}//used for List view tab
    public List<selectOption> objectList{get;set;}//used in List view tab
    public List<SelectOption> prfLstOptions {get;set;}
    public String profileSelectedforObjPrms {get;set;}
    public String profileSelected {get;set;}
    public transient List<ReportWrapper> rtWrapperList{get;set;}
    public List<SelectOption> folderOptions {get;set;}
    public String FolderId{get;set;}
    public String sessionId{get;set;}
    
    public transient List<MetadataService.ValidationRule> ValidationRules{get;set;}
    public String selectedObjectValidationRule{get;set;}//used for List view tab
    public List<selectOption> objectValidationRuleList{get;set;}//used in List view tab
    Map<String,List<MetadataService.ValidationRule>> ValidationRuleMap;
    public ExtractConfiguration(){
        listViewMap = new Map<String,List<MetadataService.ListView>>();
        ValidationRuleMap  = new Map<String,List<MetadataService.ValidationRule>>();
        try{
            partnerSoapSforceCom_v1 temp = new partnerSoapSforceCom_v1();
            partnerSoapSforceCom_v1.Soap soap = new partnerSoapSforceCom_v1.soap();
            partnerSoapSforceCom_v1.LoginResult result =  soap.login(Admin_User_Config__c.getAll().get('Admin').User_Name__c,Admin_User_Config__c.getAll().get('Admin').Token__c);
            sessionId = result.sessionId;
        }catch(Exception ex){
            system.debug('----------------' + ex);
        }    
    
        pageLoadType = 'VF Page';
        renderAs = '';
        renderedTab = 'ObjectPermissionsTabId';
        getObjectList();
        getProfileList();
        getFolderList();
    }
    
    public void getObjectList(){
        objectList = new List<selectOption>();
        objectValidationRuleList = new List<selectOption>();
        for(AggregateResult arg : [select sObjectType from ListView where sObjectType != '' group by sObjectType order by sObjectType]){
            if(Schema.getGlobalDescribe().get(String.valueOf(arg.get('sObjectType'))) != null)
            objectList.add(new selectOption(String.valueOf(arg.get('sObjectType')),Schema.getGlobalDescribe().get(String.valueOf(arg.get('sObjectType'))).getDescribe().getLabel()));//Schema.getGlobalDescribe().get(String.valueOf(arg.get('sObjectType'))).getDescribe().getName()
        }
        
        for(Schema.SObjectType obj: Schema.getGlobalDescribe().values()){
            if(obj.getDescribe().isCustom() || Label.object_list.contains(obj.getDescribe().getLabel()) 
                || Label.object_list.contains(obj.getDescribe().getName()))
                objectValidationRuleList.add(new selectOption(obj.getDescribe().getName(),obj.getDescribe().getLabel()));
        }
        objectList.sort();
        objectValidationRuleList.sort();
    }
    
    public void getFolderList(){
        folderOptions = new List<selectOption>();
        for(Folder f : [select Id,NAme from Folder where Type = 'Report' order by Name]){
            if(f.NAme != null && f.NAme != '*')
            folderOptions.add(new selectOption(f.Id,f.Name));
        }
    }
    
    public void getProfileList(){
        prfLstOptions = new List<SelectOption>();
        for(Profile pfl: [select Id, Name from Profile order by Name]){
            prfLstOptions.add(new SelectOption(pfl.Name, pfl.Name));
        }
    }
    
    public void clearList(){
        rtWrapperList = new List<REportWrapper>();
        objWrapList = new List<ObjectWrapper>();
        fldWrapList = new List<FieldWrapper>();
        ListViews = new List<MetadataService.ListView>();
    }
    
    public void getReportDetails(){
        clearList();
        loadType('Reports');
        renderedTab = 'ReportsTabId';
        rtWrapperList = new List<REportWrapper>();
        for(Report rt : [select ID from Report where OwnerId =: FolderId]){
            rtWrapperList.add(new ReportWrapper(Reports.ReportManager.describeReport(rt.Id).getReportMetadata()));
        }
    }
    
    public void getObjectPermissions(){
        clearList();
        loadType('Object_Permissions');
        renderedTab = 'ObjectPermissionsTabId';
        objWrapList = new List<ObjectWrapper>();
        ObjectWrapper objWrap;
        String profileName = '';
        List<ObjectPermissions> permissionList = new List<ObjectPermissions>();
        for(ObjectPermissions temp : [Select PermissionsCreate,PermissionsDelete,PermissionsEdit,PermissionsRead, 
                PermissionsModifyAllRecords,PermissionsViewAllRecords ,sObjectType,Parent.Profile.Name from 
                    ObjectPermissions where parent.IsOwnedByProfile = true AND Parent.Profile.Name =: profileSelectedforObjPrms order by Parent.Profile.Name]){
            if(profileName != temp.Parent.Profile.Name && profileName != ''){
                objWrap = new ObjectWrapper(profileName,permissionList);
                objWrapList.add(objWrap);
                permissionList = new List<ObjectPermissions>();
                profileName = temp.Parent.Profile.Name;
            }
            profileName = temp.Parent.Profile.Name;
            permissionList.add(temp);
        }
        
        if(permissionList.size() > 0){
            objWrap = new ObjectWrapper(profileName,permissionList);
            objWrapList.add(objWrap);
        }
    }
    
    public void getFieldPermissions(){
        clearList();
        loadType('Field_Permissions');
        renderedTab = 'FieldPermissionsTabId';
        fldWrapList = new List<FieldWrapper>();
        FieldWrapper fldWrap;
        objWrapList = new List<ObjectWrapper>();
        ObjectWrapper objWrap;
        String objName = '';
        String profileName = '';
        List<FieldPermissions> permissionList = new List<FieldPermissions>();
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
        Map<String, String> ObjLabelMap = new Map<String, String>();
        
        for(SObjectType objType : gd){
            ObjLabelMap.put(String.valueOf(objType), objType.getDescribe().getLabel());
        }
        
        for(FieldPermissions temp : [Select Field,PermissionsEdit,PermissionsRead,sObjectType,Parent.Profile.Name from 
                    FieldPermissions where parent.IsOwnedByProfile = true and Parent.Profile.Name =: profileSelected  order by Parent.Profile.Name,sObjectType]){
            if(profileName != temp.Parent.Profile.Name && profileName != ''){
                fldWrap = new FieldWrapper(profileName,objWrapList);
                fldWrapList.add(fldWrap);
                profileName = temp.Parent.Profile.Name;
            }
            
            if(objName != temp.sObjectType && objName != ''){
                objWrap = new ObjectWrapper(objName,permissionList);
                objWrapList.add(objWrap);
                permissionList = new List<FieldPermissions>();
                objName = temp.sObjectType;
            }
            objName = temp.sObjectType;
            //objType.getDescribe().getLabel()
            
            /*if(objName != ObjLabelMap.get(temp.sObjectType) && objName != ''){
                objWrap = new ObjectWrapper(objName,permissionList);
                objWrapList.add(objWrap);
                permissionList = new List<FieldPermissions>();
                objName = ObjLabelMap.get(temp.sObjectType);
            }
            
            objName = ObjLabelMap.get(temp.sObjectType);*/
            profileName = temp.Parent.Profile.Name;
            permissionList.add(temp);
        }

        fldWrap = new FieldWrapper(profileName,objWrapList);
        fldWrapList.add(fldWrap);

    }

    public void getObjectListViews(){
        clearList();
        loadType('ListViews');
        renderedTab = 'ListViewsTabId';
        try{
            if(listViewMap.get(selectedObjectListView) == null){
                MetadataServiceExamples.sessionId = sessionId;
                ListViews = new List<MetadataService.ListView>();
                ListViews = MetadataServiceExamples.readCustomObject(selectedObjectListView).listViews;
                listViewMap.put(selectedObjectListView,ListViews);
            }else
                ListViews = listViewMap.get(selectedObjectListView);
            system.debug('--------------------' + listViews);
        }catch(Exception ex){
            
        }
    }
    
    public void getObjectValidationRules(){
        clearList();
        loadType('ValidationRules');
        renderedTab = 'ValidationRuleTabId';
        try{
            if(listViewMap.get(selectedObjectListView) == null){
                MetadataServiceExamples.sessionId = sessionId;
                ValidationRules = new List<MetadataService.ValidationRule>();
                ValidationRules = MetadataServiceExamples.readCustomObject(selectedObjectValidationRule).ValidationRules;
                ValidationRuleMap.put(selectedObjectListView,ValidationRules);
            }else
                ValidationRules = ValidationRuleMap.get(selectedObjectValidationRule);
            system.debug('--------------------' + listViews);
        }catch(Exception ex){
            
        }
    }
    
   /* public void getTabVisibility(){
        clearList();
        loadType('TabVisibility');
        renderedTab = 'TabVisibilityTabId';
        try{
            TabVisibility = new List<MetadataService.ProfileTabVisibility>();
            for(MetadataService.Profile temp : MetadataServiceExamples.readProfile('Admin')){
                system.debug('--------------------' + temp);
                TabVisibility = temp.tabVisibilities;
            }
        }catch(Exception ex){
            
        }
    }*/
        
    public void loadType(String fileName){
        if(pageLoadType == 'Excel'){
            LoadType = 'application/vnd.ms-excel#' + fileName + '.xls';
            renderAs = '';
        }else if(pageLoadType == 'PDF'){
            renderAs = 'PDF';
            LoadType = '';
        }else if(pageLoadType == 'Doc'){
            loadType = 'application/vnd.msword#' + fileName + '.doc';
            renderAs = '';
        }else if(pageLoadType == 'CSV'){
            loadType = 'application/vnd.ms-excel#' + fileName + '.csv';
            renderAs = '';
        }else{
            LoadType = '';
            renderAs = '';
        }
    }

    public class ObjectWrapper{
        public transient String Type{get;set;}
        public transient List<ObjectPermissions> ObjPermissions{get;set;}
        public transient List<FieldPermissions> fldPermissions{get;set;}
        public ObjectWrapper(String t, List<ObjectPermissions> permissions){
            Type = t;
            ObjPermissions = new List<ObjectPermissions>();
            ObjPermissions = permissions;
        }
        
        public ObjectWrapper(String t, List<FieldPermissions> permissions){
            Type = t;
            fldPermissions = new List<FieldPermissions>();
            fldPermissions = permissions;
        }
    }
    
    public class FieldWrapper{
        public transient String Type{get;set;}
        public transient List<ObjectWrapper> objWrapList{get;set;}
        public FieldWrapper(String t, List<ObjectWrapper> permissions){
            Type = t;
            objWrapList = new List<ObjectWrapper>();
            objWrapList = permissions;
        }
    }
    
    public class ReportWrapper{
        public transient String Name{get;set;}
        public transient String rtType{get;set;}
        public transient String booleanFilter{get;set;}
        public transient String rtFormat{get;set;}
        public transient List<String> flters{get;set;}
        public transient List<String> columns{get;set;}
        public ReportWrapper(Reports.ReportMetadata rtMetadata){
            flters = new List<String>();
            columns = new List<String>();
            
            Name = rtMetadata.getNAme();
            rtType = rtMetadata.getReportType().getLabel();
            rtFormat = rtMetadata.getReportFormat() + '';
            booleanFilter = rtMetadata.getReportBooleanFilter();
            for(Reports.ReportFilter filter : rtMetadata.getReportFilters()){
                flters.add( filter.getcolumn() + ' ' + filter.getOperator() + ' ' + filter.getValue() );
                system.debug('-----------' + filter.getcolumn());
                system.debug('-----------' + filter.getOperator());
                system.debug('-----------' + filter.getValue());
            }
            columns = rtMetadata.getDetailColumns();
            system.debug('----------------' +  rtMetadata.getNAme());
            system.debug('----------------' +  rtMetadata.getReportType().getLabel());
            system.debug('----------------' +  rtMetadata.getReportFormat());
            system.debug('----------------' +  rtMetadata.getReportBooleanFilter());
            system.debug('----------------' +  rtMetadata.getDetailColumns() );
        }
    }
}