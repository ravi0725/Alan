/*****************************************************************************************
    Name    : Setpricebookdefault 
    Desc    : Trigger for Adding pricebook default to opportunity where record type contain Plancal and current user profile contain 'MEP'
    Project ITEM-00761
    Modification Log : 
---------------------------------------------------------------------------
Developer               Date            Description
---------------------------------------------------------------------------
Chandrakant             11/21/2013      Created
******************************************************************************************/

/*Swati        7/22/015      Removed reference of Opportunity (Plancal)record type
/*Suresh        3/4/2016    Updated process also we are changing Opportunity Price Book based on Price list
******************************************************************************************/
trigger Setpricebookdefault on Opportunity (before insert, before update) {            
    if(CreateRenewalOpportunityFromEBS.runOpportunityTrigger && !RecursiveTriggerUtility.isSetPriceBookDefaultTriggerRecursive){
        RecursiveTriggerUtility.isSetPriceBookDefaultTriggerRecursive = true;
		//Creating a Map of opportunity Record Type Name and id of record type
        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Opportunity.SObjectType);
        //Creating list of price book to get the id where Name is Plancal Standard Pricebook
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = [Select Id, Name from PriceBook2 where Name =: Label.Plancal_Standard_Pricebook OR Name ='Manhattan Standard Price Book' OR Name='GCCM Price Book' OR Name = 'Lifting Solutions Pricebook' OR Name = 'MEP NA'];
        Map<String,Id> BookMap = new Map<String,Id>();
        for(PriceBook2 Pr : priceBookList){
            BookMap.put(Pr.Name,Pr.Id);
        }
        Map<Id, Apttus_Config2__PriceList__c> mapPriceLists = new Map<Id, Apttus_Config2__PriceList__c>([SELECT Apttus_Config2__Active__c, Name, Division__c, Id FROM Apttus_Config2__PriceList__c  ORDER BY Division__c ASC]);
        
        //On Before Insert process
        if(Trigger.isInsert){
            for(Opportunity opty : Trigger.new){
                if(opty.Price_List__c != null){
                    try{
                        if(mapPriceLists.get(opty.Price_List__c).Division__c == 'Plancal'){
                            opty.PriceBook2Id = BookMap.get('Plancal Standard Pricebook');
                        }
                        else if(mapPriceLists.get(opty.Price_List__c).Division__c == 'RE&WS'){
                            opty.PriceBook2Id = BookMap.get('Manhattan Standard Price Book');
                        }
                        else if(mapPriceLists.get(opty.Price_List__c).Division__c == 'GCCM'){
                            opty.PriceBook2Id = BookMap.get('GCCM Price Book');
                        }
                        else if(mapPriceLists.get(opty.Price_List__c).Division__c == 'MEP NA'){
                            opty.PriceBook2Id = BookMap.get('MEP NA');
                        }
                    }
                    catch(Exception e){
                        opty.addError(e.getMessage());
                    }
                }else if(opty.Selling_Division__c == 'Lifting Solutions'){
                    opty.PriceBook2Id = BookMap.get('Lifting Solutions Pricebook');
                }
            }
        }
        // On Before Update process
        else{
            // Checking - Pricelist Got changed.
            for(Opportunity opty : Trigger.new){
                if(opty.Price_List__c != null && Trigger.oldMap.get(opty.Id).Price_List__c != opty.Price_List__c){
                    // We have to change Price Book for Opportunity
                    try{
                        if(mapPriceLists.get(opty.Price_List__c).Division__c == 'Plancal'){
                            opty.PriceBook2Id = BookMap.get('Plancal Standard Pricebook');
                        }
                        else if(mapPriceLists.get(opty.Price_List__c).Division__c == 'RE&WS'){
                            opty.PriceBook2Id = BookMap.get('Manhattan Standard Price Book');
                        }
                        else if(mapPriceLists.get(opty.Price_List__c).Division__c == 'GCCM'){
                            opty.PriceBook2Id = BookMap.get('GCCM Price Book');
                        }
                        else if(mapPriceLists.get(opty.Price_List__c).Division__c == 'MEP NA'){
                            opty.PriceBook2Id = BookMap.get('MEP NA');

                        }
                    }
                    catch(Exception e){
                        opty.addError(e.getMessage());
                    }
                }
            }
        }
    }
}