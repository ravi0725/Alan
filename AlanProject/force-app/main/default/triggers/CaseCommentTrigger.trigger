/*****************************************************************************************
  Name    : CaseCommentTrigger
  Desc    : Apex trigger for Case Comment object
 
  Modification Log : 
  ===========================================================================
  Developer					Date			Description
  ===========================================================================
  Suresh Babu Murugan		1/Jun/2016		Created
  Suresh Babu Murugan		03/Apr/2019		Added functionality to sync Case Comments to JIRA global Comment section
 ******************************************************************************************/
Trigger CaseCommentTrigger on CaseComment(after insert, after update, after delete) {
	if (UserInfo.getName() != 'Data Administrator' && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
		CaseCommentHandler.afterTriggerCaseCommentActions(Trigger.new, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate);
	}

	if (UserInfo.getName() != 'Data Administrator' && Trigger.isAfter && Trigger.isDelete) {
		CaseCommentHandler.afterTriggerDeleteCaseCommentActions(Trigger.old, Trigger.isAfter, Trigger.isDelete);
	}
}