public class CallTFS{
    public String errorMsg{get;set;}
    List<Id> idList;
    Case cs;
    public CallTFS(ApexPages.StandardController controller){
        idList = new List<Id>();
        idList.add(controller.getId());
        cs = [select Id,TFS_Id__c from CAse where Id =: controller.getId()];
    }
    public void makeCallOut(){
        CaseHandler.makeCallOut(idList,true,(cs.TFS_Id__c == null || cs.TFS_Id__c == '' ? true : false));
        errorMsg = CaseHandler.errorMessage;
    }
}