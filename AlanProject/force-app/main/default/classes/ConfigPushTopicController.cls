public class ConfigPushTopicController{
    public Map<Id,PushTopic> notifications{get;set;}
    public PushTopic updatePushTopic{get;set;}
    public PushTopic createPushTopic{get;set;}
    public Id pushTopicID{get;set;}
    public ConfigPushTopicController(){
        notifications = new Map<Id,PushTopic>();
        updatePushTopic = new PushTopic();
        createPushTopic = new PushTopic();
        getPushTopics();
    }
    
    public void getPushTopics(){
        notifications = new Map<Id,PushTopic>([Select Id,ApiVersion,Description,isActive,Name,NotifyForFields,NotifyForOperations,NotifyForOperationCreate,
            NotifyForOperationUpdate,NotifyForOperationDelete,NotifyForOperationUndelete,Query from PushTopic]); 
    }
    
    public void addPushTopics(){
        notifications.put(null,new PushTopic());
    }
    
    public void savePushTopic(){
        try{
            system.debug('-------pushTopicID---------' + pushTopicID);   
            if(pushTopicID != null && notifications.get(pushTopicID) != null){
                updatePushTopic = notifications.get(pushTopicID);
                update updatePushTopic;
            }else if(pushTopicID == null){
                updatePushTopic = notifications.get(null);
                insert updatePushTopic;
            }
        }catch(Exception ex){
            Apexpages.addMessages(ex);
        }
        getPushTopics();
    }
    
    public void deletePushTopic(){
        try{
            system.debug('-------pushTopicID---------' + pushTopicID);   
            if(pushTopicID != null && notifications.get(pushTopicID) != null){
                updatePushTopic = notifications.get(pushTopicID);
                delete updatePushTopic;
            }
            /*
            else if(pushTopicID == null){
                updatePushTopic = notifications.get(null);
                insert updatePushTopic;
            }*/
        }catch(Exception ex){
            Apexpages.addMessages(ex);
        }
        getPushTopics();
    }
    
    public void createPushTopic(){
        try{
            updatePushTopic = notifications.get(null);
            system.debug('--create--'+updatePushTopic);
            insert updatePushTopic;
        }catch(Exception ex){
            Apexpages.addMessages(ex);
        }
        getPushTopics();
    }
}