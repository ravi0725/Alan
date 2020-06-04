/*****************************************************************************************
  Name    : ITriggerHandler 
  Desc    : Trigger Handler Interface class
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer					Date			Description
  ---------------------------------------------------------------------------
  Suresh Babu Murugan		25/Mar/2019		Created
 ******************************************************************************************/
public interface ITriggerHandler
{
	void beforeInsert(List<SObject> newItems);

	void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);

	void beforeDelete(Map<Id, SObject> oldItems);

	void afterInsert(Map<Id, SObject> newItems);

	void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);

	void afterDelete(Map<Id, SObject> oldItems);

	void afterUndelete(Map<Id, SObject> oldItems);

	Boolean isDisabled();
}