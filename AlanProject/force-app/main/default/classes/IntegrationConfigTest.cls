@isTest(seealldata=true)
private class IntegrationConfigTest {
    
    static testmethod void meth1(){
    	for(System_Integration_Config__c s : System_Integration_Config__c.getall().values()){
            system.debug('-----------s.Name---------------' + s.Name);
            s.Name = s.Name.replaceAll('_Sandbox','').replaceAll('_Production','');
            system.debug('-----------s.Name---------------' + s.Name);
    		IntegrationConfig.getEndPointURL('FCH_Integration');   
    	}    
        
    }
      
}