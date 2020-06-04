/*****************************************************************************************
    Name        :   ProductConfigurationHandler 
    Desc        :   Used in Productconfiguration trigger
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Suresh Babu         04/20/2017          Created
******************************************************************************************/
public class ProductConfigurationHandler {
    public static Map<String, Integer> launchControl;
    // Static initialize
    static {
        resetLaunchControl();
    }
    // Reset Trigger control (e.g. for testing)
    public static void resetLaunchControl() {
        launchControl = new Map<String, Integer>();
        launchControl.put('pConfigBeforeTrigger', 0);
        launchControl.put('pConfigAfterUpdate', 0);
    }

    // This method is used in before trigger
    public static void pConfigBefore(List<Apttus_Config2__ProductConfiguration__c> lstNewProdConfig){
    Set<ID> Config = new Set<ID>();
   
        if(launchControl.get('pConfigBeforeTrigger') < 1){
            launchControl.put('pConfigBeforeTrigger', launchControl.get('pConfigBeforeTrigger') + 1);
           for (Apttus_Config2__ProductConfiguration__c a : lstNewProdConfig){
           config.add(a.id);
           }
          
            for (Apttus_Config2__ProductConfiguration__c a : lstNewProdConfig){
                try{
                    a.Sales_Rep_Manager__c = a.Sales_Manager_Id_Formula__c;
                    
                }catch(Exception e){
                    a.addError(e.getMessage());
                }
            }
        }
    }

//Method is used in After Insert Method (To Revoke the Cart Sequence Changed field on Proposal record. 
    Public static void pConfigAfterInsert(List<Apttus_Config2__ProductConfiguration__c> lstNewProdConfig){
    if(launchControl.get('pConfigAfterInsert') < 1){
            launchControl.put('pConfigAfterInsert', launchControl.get('pConfigAfterInsert') + 1);
            system.debug('>>>Inside the class>>>>');
            
            Set<Id> quoteIdSet = new Set<Id>();
            List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
            Map<Id, Apttus_Proposal__Proposal__c> quoteMap = new Map<Id, Apttus_Proposal__Proposal__c>();
            boolean flag = false;

            for(Apttus_Config2__ProductConfiguration__c config : lstNewProdConfig){
                quoteIdSet.add(config.Apttus_QPConfig__Proposald__c);
            }

            Set<Id> uniqueIds = new Set<Id>();
            Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
            quoteMap = new Map<Id, Apttus_Proposal__Proposal__c>([Select Id, Cart_Line_Sequence_Changed__c,Apttus_Proposal__Approval_Stage__c,Product_Conf_Status__c from Apttus_Proposal__Proposal__c where Id IN: quoteIdSet]);
            system.debug('>>>Inside the class>>>>'+quoteMap);
            if(quoteMap.size() > 0){
                for(Apttus_Config2__ProductConfiguration__c config : lstNewProdConfig){
                    if(quoteMap.containsKey(config.Apttus_QPConfig__Proposald__c) && !uniqueIds.contains(config.Apttus_QPConfig__Proposald__c)){
                        quoteMap.get(config.Apttus_QPConfig__Proposald__c).Cart_Line_Sequence_Changed__c = False;
                        }
                      uniqueIds.add(config.Apttus_QPConfig__Proposald__c);
                      quoteList.add(quoteMap.get(config.Apttus_QPConfig__Proposald__c));
               }
            }
            if(quoteList.size() > 0){
                    update quoteList;
                }
    }
}

    // This method is used in afterupdate trigger
    public static void pConfigAfterUpdate(List<Apttus_Config2__ProductConfiguration__c> lstNewProdConfig){
        if(launchControl.get('pConfigAfterUpdate') < 1){
            launchControl.put('pConfigAfterUpdate', launchControl.get('pConfigAfterUpdate') + 1);

            Set<Id> quoteIdSet = new Set<Id>();
            List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
            Map<Id, Apttus_Proposal__Proposal__c> quoteMap = new Map<Id, Apttus_Proposal__Proposal__c>();
            boolean flag = false;

            for(Apttus_Config2__ProductConfiguration__c config : lstNewProdConfig){
                quoteIdSet.add(config.Apttus_QPConfig__Proposald__c);
            }

            Set<Id> uniqueIds = new Set<Id>();
            Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
            quoteMap = new Map<Id, Apttus_Proposal__Proposal__c>([Select Id, Apttus_Proposal__Approval_Stage__c,Product_Conf_Status__c from Apttus_Proposal__Proposal__c where Id IN: quoteIdSet]);
            if(quoteMap.size() > 0){
                for(Apttus_Config2__ProductConfiguration__c config : lstNewProdConfig){
                    if(quoteMap.containsKey(config.Apttus_QPConfig__Proposald__c) && !uniqueIds.contains(config.Apttus_QPConfig__Proposald__c)){
                        quoteMap.get(config.Apttus_QPConfig__Proposald__c).Product_Conf_Status__c = config.Apttus_Config2__Status__c;
                        
                        if(config.Apttus_CQApprov__Approval_Status__c == 'Pending Approval'){
                            quoteMap.get(config.Apttus_QPConfig__Proposald__c).Apttus_Proposal__Approval_Stage__c = 'In Review';           
                        }
                        if(config.Apttus_CQApprov__Approval_Status__c == 'Approved'){
                            quoteMap.get(config.Apttus_QPConfig__Proposald__c).Apttus_Proposal__Approval_Stage__c = 'Approved';                
                        }
                        if(config.Apttus_CQApprov__Approval_Status__c == 'Cancelled'){
                            quoteMap.get(config.Apttus_QPConfig__Proposald__c).Apttus_Proposal__Approval_Stage__c = 'Cancelled';                
                        }
                        if(config.Apttus_CQApprov__Approval_Status__c == 'Rejected'){
                            quoteMap.get(config.Apttus_QPConfig__Proposald__c).Apttus_Proposal__Approval_Stage__c = 'Approval Rejected';                
                        }
                        
                        uniqueIds.add(config.Apttus_QPConfig__Proposald__c);
                        quoteList.add(quoteMap.get(config.Apttus_QPConfig__Proposald__c));
                    }
                }

                if(quoteList.size() > 0){
                    update quoteList;
                }
            }

        }
    }
}