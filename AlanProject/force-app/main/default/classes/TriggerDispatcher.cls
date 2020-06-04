/*****************************************************************************************
  Name    : TriggerDispatcher 
  Desc    : Global Trigger Dispatcher class
  Modification Log : 
  ---------------------------------------------------------------------------
  Developer					Date			Description
  ---------------------------------------------------------------------------
  Suresh Babu Murugan		25/Mar/2019		Created
 ******************************************************************************************/
public class TriggerDispatcher
{
	/*
	  Call this method from your trigger, passing in an instance of a trigger handler which implements ITriggerHandler.
	  This method will fire the appropriate methods on the handler depending on the trigger context.
	 */
	public static void run(ITriggerHandler handler)
	{
		// Check to see if the trigger has been disabled. If it has, return
		if (handler.isDisabled())
		return;

		// Detect the current trigger context and fire the relevant methods on the trigger handler:

		// Before trigger logic
		if (Trigger.isBefore)
		{
			if (Trigger.isInsert)
			handler.BeforeInsert(trigger.new);

			if (Trigger.isUpdate)
			handler.BeforeUpdate(trigger.newMap, trigger.oldMap);

			if (Trigger.isDelete)
			handler.BeforeDelete(trigger.oldMap);
		}

		// After trigger logic
		if (Trigger.isAfter)
		{
			if (Trigger.isInsert)
			handler.AfterInsert(Trigger.newMap);

			if (Trigger.isUpdate)
			handler.AfterUpdate(trigger.newMap, trigger.oldMap);

			if (trigger.isDelete)
			handler.AfterDelete(trigger.oldMap);

			if (trigger.isUndelete)
			handler.AfterUndelete(trigger.oldMap);
		}
	}
}