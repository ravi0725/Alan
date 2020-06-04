public class WS_Interface_Log {
	public static WS_Interface_Log__c createLog(String componentName, String methodName, String exceptionInfo, String exceptionDetail,String description){
        WS_Interface_Log__c il = new WS_Interface_Log__c();
        il.ComponentName__c = componentName;
        il.MethodName__c = methodName;
        il.ExceptionDetails__c = exceptionDetail;
        il.Exception__c = (exceptionInfo != null ? exceptionInfo.left(254) : '');
        il.Timestamp__c = string.valueOf(system.Now());
        il.Description__c = (description != null ? description.left(1000) : '');
        return il;
    }
}