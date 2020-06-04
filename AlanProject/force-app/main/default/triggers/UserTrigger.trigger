trigger UserTrigger on User (after insert)
{
    AddUser.AddToGroups(trigger.newMap.keySet());
}