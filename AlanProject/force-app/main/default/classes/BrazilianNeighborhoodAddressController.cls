public class BrazilianNeighborhoodAddressController {
    public string brazilianState{get;set;}
    public string brazilianCity{get;set;}
    public Address__c add;
    public List<SelectOption> states;
    public List<SelectOption> cities;
    public BrazilianNeighborhoodAddressController(Apexpages.StandardController controller){
        brazilianState = '';
        brazilianCity = '';
        add = [select Id,Country__c,Brazilian_City__c,Brazilian_Neighborhood__c,Brazilian_State__c from Address__c where Id =: controller.getId()];
        brazilianState = add.Brazilian_State__c;
        brazilianCity = add.Brazilian_City__c;
        if(add.Country__c =='Brazil' && add.Brazilian_Neighborhood__c == Null)
        {
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Brazilian Neighborhood'));
        // return null;
        }
        
    }
    
    public List<selectoption> getStates(){
        List<SelectOption> tempList = new List<SelectOption>();
        tempList.add(new selectOption('','--None--'));
        for(Brazilian_Neighbourhood__c brazilianNeighbourhood : [select Id,State__c,State_Description__c from Brazilian_Neighbourhood__c where Is_State__c = true order by State__c ASC]){
            tempList.add(new selectOption(brazilianNeighbourhood.State__c + '-' + brazilianNeighbourhood.State_Description__c,brazilianNeighbourhood.State_Description__c));
            if(brazilianNeighbourhood.State__c == brazilianState)brazilianState = brazilianState + '-' + brazilianNeighbourhood.State_Description__c;
        }
        return tempList;
    }
    
    public List<selectoption> getCities(){
        List<SelectOption> tempList = new List<SelectOption>();
        tempList.add(new selectOption('','--None--'));
        if(brazilianState != '' && brazilianState != null){
            for(Brazilian_Neighbourhood__c brazilianNeighbourhood : [select Id,State__c,State_Description__c,City__c,City_Description__c from Brazilian_Neighbourhood__c where Is_State__c = false order by City__c Asc]){
                if(brazilianNeighbourhood.State__c == brazilianState.split('-').get(0)){
                    tempList.add(new selectOption(brazilianNeighbourhood.City__c + '-' + brazilianNeighbourhood.City_Description__c,brazilianNeighbourhood.City_Description__c));
                    if(brazilianNeighbourhood.City__c == brazilianCity)brazilianCity = brazilianCity + '-' + brazilianNeighbourhood.City_Description__c;
                }
            }
        }
        return tempList;
    }
    
    public void save(){
        system.debug('-----------brazilianState--------------' + brazilianState);
        system.debug('-----------brazilianCity--------------' + brazilianCity);
        if(String.isblank(brazilianState) || String.isblank(brazilianCity))
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'State and City are Mandatory Values.'));
        else
        {
        add.Brazilian_State__c = brazilianState.split('-').get(0);
        add.Brazilian_City__c = brazilianCity.split('-').get(0);
        add.State__c = brazilianState.split('-').get(0);
        add.city__c = brazilianCity.split('-').get(0);
        update add;
        }
    }
}