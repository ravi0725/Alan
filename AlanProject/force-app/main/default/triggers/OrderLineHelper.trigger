trigger OrderLineHelper on Order_Line_Item__c (after insert,after update) {
try{
    Set<ID> OrderID = new Set<ID>();
    Set<String>OderlIneStatus = new Set<String>();
    Map<ID,String>OppMap = new Map<ID,String>();
    List<Opportunity>UpdateOppty = new List<Opportunity>();
    List<Order__c>OrderList = new List<Order__c>();
    List<Order_Line_Item__c> OrderlineList = new List<Order_Line_Item__c>();
    List<MEPNA_Order_Operations_Status__c> CustomSetRecList = new List<MEPNA_Order_Operations_Status__c>();
    Map<String, Integer> AllRecs = new Map<String, Integer>();
    Map<String, MEPNA_Order_Operations_Status__c> mcs = MEPNA_Order_Operations_Status__c.getAll();
    
    
    for(Order_Line_Item__c Od : Trigger.new)
    {
        OrderID.add(Od.Order__c);
    }
    
    OrderList = [select id,Related_Quote_Proposal__r.Apttus_Proposal__Opportunity__r.Id,Related_Quote_Proposal__c from Order__c where id in: OrderID];
    OrderlineList = [select id,Order_Line_Order_Status__c,Order__c,Order__r.Related_Quote_Proposal__r.Apttus_Proposal__Opportunity__r.Id from Order_Line_Item__c where Order__c in: OrderID];
    CustomSetRecList = mcs.values(); //[select id,Status_Value__c,Priority__c from MEPNA_Order_Operations_Status__c order by Priority__c ASC];
    
    for(MEPNA_Order_Operations_Status__c  Csr : CustomSetRecList)
    {
        AllRecs.put(csr.Status_Value__c , Integer.valueof(csr.Priority__c));
    }
    
    for(Order__c Ord : OrderList){
        List<Integer> Priority = new List<Integer>();
        for(Order_Line_Item__c Oli : OrderlineList)
        {
            if(Ord.id == Oli.Order__c){
                
                if(AllRecs.get(Oli.Order_Line_Order_Status__c)!=Null)
                { 
                    Priority.add(AllRecs.get(Oli.Order_Line_Order_Status__c));
                }
            }
        }
        Priority.sort();
        System.debug('>>>>>>>Priority>>>>>>>>>>'+Priority);
        if(mcs.get(String.valueOf( Priority.get(0) ))!= Null && Ord.Related_Quote_Proposal__c != Null) {
            OppMap.put(Ord.Related_Quote_Proposal__r.Apttus_Proposal__Opportunity__r.Id, mcs.get(String.valueOf( Priority.get(0) )).Status_Value__c);
        }
    }
    system.debug('>>>>>>>>>>>AllRecs>>>>>>>>>>'+AllRecs);
    system.debug('>>>>>>>>>>>OppMap>>>>>>>>>>'+oppMap);
    
    for(ID OppID : OppMap.keyset())
    {
        Opportunity Opp = new opportunity(id=OppID);
        Opp.MEPNA_Order_Operations_Status__c = OppMap.get(OppID);
        UpdateOppty.add(Opp);
    }
    
    if(UpdateOppty.size() >0) Update UpdateOppty;
    }
    
    catch(exception ex)
    {
    }
}