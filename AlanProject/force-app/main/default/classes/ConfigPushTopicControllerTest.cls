/*****************************************************************************************
Name    : ConfigPushTopicControllerTest 
Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
P M Mamata       28/08/2015          Created
******************************************************************************************/
@isTest(seealldata=true)
private class ConfigPushTopicControllerTest {
    static testmethod void math1(){
        
        PushTopic pushTopic = new PushTopic();
        pushTopic.Name = 'InvoiceStatementUpdates';
        pushTopic.Query = 'SELECT Id,Subject FROM Case';
        pushTopic.ApiVersion = 34.0;
        pushTopic.NotifyForOperationCreate = true;
        pushTopic.NotifyForOperationUpdate = true;
        pushTopic.NotifyForOperationUndelete = true;
        pushTopic.NotifyForOperationDelete = true;
        pushTopic.NotifyForFields = 'SELECT';
        insert pushTopic;
        ConfigPushTopicController ct = new ConfigPushTopicController();
        ct.addPushTopics();        
        ct.pushTopicID = pushTopic.Id;
        ct.savePushTopic();
        ct.deletePushTopic();
        ct.createPushTopic();
        ct.pushTopicID = null;
        ct.savePushTopic();
        
    }
}