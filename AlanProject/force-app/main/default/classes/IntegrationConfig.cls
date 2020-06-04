public class IntegrationConfig{
    public static String orgType;
    public static map<String,System_Integration_Config__c> systemIntegrationConfig;
    static{
        orgType = 'Production';
        if([Select isSandbox from Organization where Id =: userinfo.getOrganizationId()].isSandbox){
            orgType = 'Sandbox';
        }
        systemIntegrationConfig = new Map<String,System_Integration_Config__c>();
        systemIntegrationConfig = System_Integration_Config__c.getAll();
    }
    public static string getEndPointURL(String integrationName){
        system.debug(integrationName + '-----------orgType---------------' + orgType);
        String name = integrationName + '_' + orgType;
        system.debug('-----------name---------------' + name);
        return systemIntegrationConfig.get(name).End_Point_URL__c;
    }
}