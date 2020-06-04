/***
    Class Name : CloseTaskRelatedtoCase
    Desciption : This class is used in Process Builder, when Case closed with "Resolution Provided" Case Reason, its related Tasks should be closed.
    Date       : 06-Jun-2016
    Author     : Suresh Babu Murugan
**/
public class CloseTaskRelatedtoCase {
    @InvocableMethod(label='Close Tasks when Case was closed' description='When case closed with Resolution Provided status, its related Tasks should be closed')
    public static void removeUnwantedString(List<Id> caseIDs){
        // Query related Tasks
        List<Task> lstTasks = [SELECT Id, Status, Subject, Description FROM Task WHERE WhatId IN : caseIDs AND Status != 'Completed'];
        for(Task tsk: lstTasks){
            tsk.Status = 'Completed';
        }
        update lstTasks;
    }
}