/*****************************************************************************************
Name    : JIRAIssue_Create_GCCMCtrl
Desc    : Used to provide access to create JIRA for GCCM Cases

Modification Log :
===========================================================================
Developer				Date			Description
===========================================================================
Suresh Babu Murugan		30/Nov/2018		Created
******************************************************************************************/
public with sharing class JIRAIssue_Create_GCCMCtrl {
	public Case gccmCase {get;set;}
	public Boolean isHavePermissionToCreateJIRAIssue {get;set;} // This boolean denotes current Case record authorized to create JIRA issue
	// Standard Constructor
	public JIRAIssue_Create_GCCMCtrl(ApexPages.StandardController controller){
		gccmCase = [SELECT Id, Record_Type_Name__c, Product__c FROM Case WHERE Id =: controller.getId()];
		if(gccmCase.Product__c.contains('ProjectSight') || gccmCase.Product__c.contains('Prolog') || gccmCase.Product__c.contains('Proliance') || gccmCase.Product__c.contains('Field Mgmt')){
			isHavePermissionToCreateJIRAIssue = true;
		}
		else{
			isHavePermissionToCreateJIRAIssue = false;
		}
	}
}