trigger P1UpdateIssueOwneronCaseTrigger on Case (before insert, before Update) {
    if(userinfo.getName() != 'Data Administrator' && ((trigger.isInsert && trigger.isBefore) || (trigger.isUpdate && trigger.isBefore)))
        UpdateIssueOwneronCase.IssueOwnerupdate (trigger.new);
}