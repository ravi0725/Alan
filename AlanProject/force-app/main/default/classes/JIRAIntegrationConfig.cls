/***
    Class Name : JIRAIntegrationConfig
    Desciption : This class is used in connect with JIRA configuration setup.
    Date	   : 07-Jun-2016
    Author	   : Suresh Babu Murugan
**/
public class JIRAIntegrationConfig {
	public static String orgType;
    public static map<String,JIRA_System_Config__c> JIRAConfig;
    static{
        orgType = 'Production';
        if([Select isSandbox from Organization where Id =: userinfo.getOrganizationId()].isSandbox){
            orgType = 'Sandbox';
        }
        JIRAConfig = new Map<String,JIRA_System_Config__c>();
        JIRAConfig = JIRA_System_Config__c.getAll();
    }
    
    public static string getUserName(String uName){
        String name = uName + '_' + orgType;
        return JIRAConfig.get(name).User_Name__c;
    }
    
    public static string getPassword(String pwd){
        String password = pwd + '_' + orgType;
        return JIRAConfig.get(password).Password__c;
    }
    
    public static string getSystemId(String sysId){
        String systemId = sysId + '_' + orgType;
        return JIRAConfig.get(systemId).System_Id__c;
    }
    
    public static string getEndPointURL(String integrationName){
        String name = integrationName + '_' + orgType;
        return JIRAConfig.get(name).End_Point_URL__c;
    }
}