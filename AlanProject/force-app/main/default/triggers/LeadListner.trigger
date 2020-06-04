/*****************************************************************************************
Name        : LeadListner
Desc        : Trigger on Lead object
---------------------------------------------------------------------------
Developer              Date             Description
---------------------------------------------------------------------------
Ankur Patel          30/10/2017         Call LeadConversionDefaultOpportunityFields to default Opportunity fields value 
                                        while converting Lead
******************************************************************************************/
trigger LeadListner on Lead (before insert, before update, after insert, after update) {
    if(trigger.isAfter && trigger.isUpdate){
        LeadHelper.LeadConversionDefaultOpportunityFields(trigger.New, trigger.OldMap);
    }
}