public class TechServiceHandler{
    public static Map<String, Integer> launchControl;
    // Static initialize
    static {
        resetLaunchControl();
    }
    
    
    
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('attachTechServicesToCase', 0);
        launchControl.put('clearFields', 0);
    }
    
    public static void clearFields(List<Tech_Service__c> newtechList){
        if(launchControl.get('clearFields') < 1){
            launchControl.put('clearFields',launchControl.get('clearFields') + 1);
            for(Tech_Service__c tech : newtechList){
                tech.System_Case_Id__c = '';
            }
        }
    }
    
    public static void attachTechServicesToCase(List<Tech_Service__c> newtechList){
        if(launchControl.get('attachTechServicesToCase') < 1){
            launchControl.put('attachTechServicesToCase',launchControl.get('attachTechServicesToCase') + 1);
            List<Tech_Service_Junction__c> techJunctionList = new List<Tech_Service_Junction__c>();
            for(Tech_Service__c tech : newtechList){
                if(tech.System_Case_Id__c != null && tech.System_Case_Id__c != ''){
                    Tech_Service_Junction__c temp = new Tech_Service_Junction__c();
                    temp.Case__c = tech.System_Case_Id__c;
                    temp.Tech_Service__c = tech.ID;
                    techJunctionList.add(temp);
                }
            }
            if(techJunctionList.size() > 0){
                system.debug('--------techJunctionList----------' + techJunctionList);
                insert techJunctionList;
            }
        }
    }

}