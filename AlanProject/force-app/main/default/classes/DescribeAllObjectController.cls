public class DescribeAllObjectController {
    public transient List<String> objectList{get;set;}
    public transient Map<String,List<ObjectWrapper>> ObjWrapMap{get;set;}
    public transient Map<String, String> ObjPrefixMap {get; set;}
    public String pageLoadType{get;set;}
    public String LoadType{get;set;}
    public DescribeAllObjectController(){
        pageLoadType = apexpages.currentpage().getparameters().get('pageLoadType');
        if(pageLoadType == 'Excel')
            pageLoadType = 'application/vnd.ms-excel#CustomObject.xls';
        else if(pageLoadType == 'PDF')
            LoadType = 'PDF';
        else
            pageLoadType = '';
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
        objectList = new List<String>();
        ObjWrapMap = new Map<String,List<ObjectWrapper>>();     
        ObjPrefixMap = new Map<String, String>();
        
        for(Schema.SObjectType objType : gd){
            Schema.DescribeSObjectResult r = objType.getDescribe();
            ObjPrefixMap.put(objType.getDescribe().getLabel(), (r.getKeyPrefix() == null?'':r.getKeyPrefix())); 
            if((objType.getDescribe().isCustom() || Label.Object_List.contains(objType.getDescribe().getNAme())) || 
            (test.isRunningTest() && objType.getDescribe().getNAme() == 'Account')){
                ObjectWrapper temp;
                for (Schema.SObjectField f : objType.getDescribe().fields.getMap().values()){
                    temp = new ObjectWrapper(f.getDescribe());
                    if(ObjWrapMap.get(objType.getDescribe().getName()) == null){
                        ObjWrapMap.put(objType.getDescribe().getName(),new List<ObjectWrapper>());
                    }
                    ObjWrapMap.get(objType.getDescribe().getName()).add(temp);
                }
            }
        }
    }
    
    public class ObjectWrapper{
        public String fieldName{get;set;}
        public String fieldAPIName{get;set;}
        public String description{get;set;}
        public String fieldType{get;set;}
        public String fieldDescription{get;set;}
        public String pickValues{get;set;}
        public boolean isCustom{get;set;}
        public ObjectWrapper(Schema.DescribeFieldResult f){
            fieldName = f.getLabel();
            fieldAPIName = f.getName();
            fieldType = f.getType().name();
            isCustom = f.isCustom();
            fieldDescription = f.getInlineHelpText();
            if(fieldType == 'DOUBLE' || fieldType == 'INTEGER'){
                fieldType = fieldType + '(' + f.getScale() + ',' + f.getPrecision() + ')';
            }else if(fieldType == 'STRING'){
                fieldType = fieldType + '(' + f.getLength() + ')';
            }else if(fieldType == 'REFERENCE'){
                fieldType = fieldType + f.getReferenceTo();
            }else if(fieldType == 'PICKLIST'){
                List<Schema.PicklistEntry> ple = f.getPicklistValues();
                
                pickValues = '---';
                for( Schema.PicklistEntry p : ple){
                    pickValues = pickValues + ',' + p.getLabel();
                system.debug('Picklist Level>>>>>>>>>>>>>>>'+p.getLabel()+'::Picklist Value>>>>>>>>>'+p.getValue());
                }
                pickValues = pickValues.replaceAll('---,','');
                pickValues = pickValues.replaceAll('---','');                
            }
        }
    }
}