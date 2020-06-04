/*****************************************************************************************
Name        : OpportunityEventListner
Desc        : Used to handel Opportunity trigger code
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Ankur Patel          06/04/2019          Created
******************************************************************************************/
trigger OpportunityEventListner on Opportunity (after insert, after update, after delete, after undelete, before insert, before update, before delete){
    //When Renewal Opportunity gets created via interface, runOpportunityTrigger value will be false
    system.debug('--------------------' + userinfo.getName() + '---------' + UserInfo.getUserId());
    if(CreateRenewalOpportunityFromEBS.runOpportunityTrigger){/* &&  !RecursiveTriggerUtility.approvallistner*/
        CentralDispatcher.Dispatch(trigger.IsBefore, trigger.isAfter, trigger.IsInsert, trigger.IsUpdate, trigger.IsDelete , trigger.IsExecuting, trigger.new, trigger.newmap, trigger.old, trigger.oldmap);
        if(trigger.isBefore && trigger.isInsert){
            String usrProfileName = [select u.Profile.Name,u.Division__c from User u where u.id = :Userinfo.getUserId()].Division__c; 
            for(Opportunity opp : trigger.new){
                if(trigger.isInsert){
                    if(usrProfileName!=Null && usrProfileName.contains('MEP NA'))
                        opp.Payment_Term__c = opp.Paymnt_Term_from_Bill_To_Account__c;
                }
            }
        }
        
        if(trigger.isAfter && trigger.isUpdate){
            OpportunityHelper.validateMEPNAEstimatingBusinessArea(Trigger.isInsert, Trigger.isUpdate, Trigger.New, Trigger.oldMap);    
        }
        
        if(trigger.isBefore && trigger.isUpdate){
            // OpportunityHelper.validatePaymentTerm(trigger.newMap,trigger.oldMap);
            // OpportunityHelper.updateProposalPaymentTerm(trigger.newMap,trigger.oldMap);
            OpportunityHelper.RollupOpptyLines(trigger.newMap);
            OpportunityHelper.updateBusinessArea(trigger.new);
            OpportunityHelper.updateBusinessUnit(trigger.newMap);
        }
        
        if(trigger.isAfter && trigger.isUpdate){
            system.debug('>>>>>>>trigger.isUpdate>>>>>>>'+trigger.newmap.get(trigger.new.get(0).id).Opportunity_Rental_Status__c);
            system.debug('>>>>>>>trigger.isUpdate>>>>>>>'+trigger.oldmap.get(trigger.new.get(0).id).Opportunity_Rental_Status__c);
            OpportunityHelper.runApprovalProcess(trigger.newMap,trigger.oldMap);
            if(trigger.newmap.get(trigger.new.get(0).id).Opportunity_Rental_Status__c == 'Rentals Shipped' && trigger.oldmap.get(trigger.new.get(0).id).Opportunity_Rental_Status__c != 'Rentals Shipped')
            {
                system.debug('>>>>>>>trigger.isUpdate>>>>>>>'+trigger.newmap.get(trigger.new.get(0).id).Opportunity_Rental_Status__c);
                OpportunityHelper.updateStartdateEnddate(trigger.new);
            }
            
            if(/*trigger.newmap.get(trigger.new.get(0).id).StageName != trigger.oldmap.get(trigger.new.get(0).id).StageName && */trigger.newmap.get(trigger.new.get(0).id).StageName=='6 - Closed Won' || trigger.newmap.get(trigger.new.get(0).id).StageName=='Closed Won')
            {
                OpportunityHelper.UpdateProductGrowth(trigger.new);
            }
            
        }
        
        
        
        if(Trigger.isAfter && trigger.isInsert)
        {
            Set<ID> ConIdSet = new Set<ID>();
            Map<ID,Set<ID>> oppConMap = new Map<Id,Set<ID>>();
            List<OpportunityContactRole> ConRole = new List<OpportunityContactRole>();
            for(Opportunity Op : trigger.new)
            {
                if(Op.Bill_To_Contact__c != Null) 
                    ConIdSet.add(Op.Bill_To_Contact__c);
                if(Op.Primary_Contact__c != Null)
                    ConIDSet.add(Op.Primary_Contact__c);
                oppConMap.put(Op.id,ConIDSet);
            }
            
            for(Opportunity Op : trigger.new)
            {
                Set<ID>Temp = new Set<ID>();
                Temp = oppConMap.get(op.id);
                List<ID>TempLt = new List<ID>(Temp);
                
                if(Temp.size()==1)
                {
                    OpportunityContactRole Opc = new OpportunityContactRole();
                    Opc.ContactID = TempLt[0];
                    Opc.OpportunityID =Op.Id;
                    Opc.Role = 'Others';
                    Insert Opc;
                }
                else if(Temp.size()==2)
                {
                    OpportunityContactRole Opc = new OpportunityContactRole();
                    Opc.ContactID = TempLt[0];
                    Opc.OpportunityID =Op.Id;
                    Opc.Role = 'Others';
                    Insert Opc;
                    OpportunityContactRole Opc1 = new OpportunityContactRole();
                    Opc1.ContactID = TempLt[1];
                    Opc1.OpportunityID =Op.Id;
                    Opc1.Role = 'Others';
                    Insert Opc1;
                }
            }
            
            
            
            
            
            //OpportunityHelper.createOpptyContactRoles(ConIDSet,Trigger.new);
            //OpportunityUtility.updateRSM(trigger.new);
        }
        
        if(trigger.isDelete && trigger.isBefore){
            OpportunityHelper.validateRenewalOpportunity(trigger.old);
        }
        
    }else{
        //Update Renewal Opportunity Owner, Name etc.
        //Renewal 3.5 - Added update scenario as well for MEPNA
        if((trigger.isInsert || trigger.isUpdate) && trigger.isBefore){
            CreateRenewalOpportunityFromEBS.processRenewalOpporutnity(trigger.new);
        }
    }
    system.debug('--------------------' + userinfo.getName() + '---------' + UserInfo.getUserId());
}