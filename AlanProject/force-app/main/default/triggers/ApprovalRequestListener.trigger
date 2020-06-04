trigger ApprovalRequestListener on Apttus_Approval__Approval_Request__c(before insert, after insert, before update, after update) {

	if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
		Map<Id, Id> mapQueueId = new Map<Id, Id> ();
		Map<Id, Set<Id>> mapUsersId = new Map<Id, Set<Id>> ();
		Map<Id, String> mapUserName = new Map<Id, String> ();
		Set<Id> setUserId = new Set<Id> ();
		for (Apttus_Approval__Approval_Request__c AppReq : trigger.new) {
			if (AppReq.Apttus_Approval__Assigned_To_Type__c == 'Queue' && AppReq.Apttus_Approval__Assigned_To_Id__c != null) {
				mapQueueId.put(AppReq.Id, AppReq.Apttus_Approval__Assigned_To_Id__c);
			}
		}

		List<GroupMember> lstGroupMembers = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :mapQueueId.values()];
		for (GroupMember gMember : lstGroupMembers) {
			if (mapUsersId.containsKey(gMember.GroupId)) {
				Set<Id> tmpUserId = mapUsersId.get(gMember.GroupId);
				tmpUserId.add(gMember.UserOrGroupId);
				mapUsersId.put(gMember.GroupId, tmpUserId);
			}
			else {
				Set<Id> tmpUserId = new Set<Id> ();
				tmpUserId.add(gMember.UserOrGroupId);
				mapUsersId.put(gMember.GroupId, tmpUserId);
			}
		}

		for (Set<Id> userid : mapUsersId.values()) {
			setUserId.addAll(userid);
		}

		Map<Id, User> mapUsers = new Map<Id, User> ([SELECT Id, Name FROM User WHERE Id IN :setUserId]);
		for (Id grpId : mapUsersId.keySet()) {
			String membersName = '';
			for (Id uId : mapUsersId.get(grpId)) {
				membersName += mapUsers.get(uId).Name + '\n';
			}
			mapUserName.put(grpId, membersName);
		}

		for (Apttus_Approval__Approval_Request__c AppReq : trigger.new) {
			if (AppReq.Apttus_Approval__Assigned_To_Type__c == 'Queue' && AppReq.Apttus_Approval__Assigned_To_Id__c != null) {
				AppReq.Assigned_To_Queue_Members__c = (mapUserName.containsKey(AppReq.Apttus_Approval__Assigned_To_Id__c) ? mapUserName.get(AppReq.Apttus_Approval__Assigned_To_Id__c) : '');
			}
		}
	}

	if (trigger.isafter && trigger.isupdate && !RecursiveTriggerUtility.approvallistner)
	{
		RecursiveTriggerUtility.approvallistner = True;
		RecursiveTriggerUtility.stopLineItemTrigger_ApprovalRequestListener = TRUE;

		set<Id> ObjId = new Set<Id> ();
		List<Apttus_Approval__Approval_Request__c> AppReqList = new List<Apttus_Approval__Approval_Request__c> ();

		for (Apttus_Approval__Approval_Request__c AppReq : trigger.new)
		{
			ObjId.add(AppReq.id);
		}
		AppReqList = [select id, Apttus_Approval__SubmissionComment1__c, Apttus_Approval__SubmissionComment2__c, Apttus_Approval__SubmissionComment3__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Reason_for_Discount__c,
		              Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c from Apttus_Approval__Approval_Request__c where id in :Objid];


		if (AppReqList.size() > 0 && AppReqlist.get(0).Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c != Null)
		{
			CreateRenewalOpportunityFromEBS.runOpportunityTrigger = False;

			Opportunity Opp = new opportunity(id = AppReqlist.get(0).Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c);
			Opp.Reason_for_Discount__c = AppReqlist.get(0).Apttus_Approval__SubmissionComment1__c;
			update Opp;

		}
	}
}