public class AskAQuestionController{
  
    @AuraEnabled
    public Static String getTopicName(String recordId)
    {
        String TopicName = 'helloworld';
        if(recordId != null && recordId != ''){
        list<Topic> TopicLst = new list<Topic>();
        TopicLst = [select id,name,TalkingAbout from topic where id =: recordId];
        if(!(TopicLst.isempty()))
            TopicName = TopicLst[0].name;
        }
        return TopicName;
    }
    
    @AuraEnabled
    public Static String postQuestionOnTopic(String recordId, String QuestionBody)
    {
        try{
        list<Topic> TopicLst = new list<Topic>();
            TopicLst = [select id,name,TalkingAbout,NetworkId from topic where id =: recordId];
            Network nw= new Network();
            //system.debug('---NW ID---'+nw.getNetworkId);
        FeedItem item = new FeedItem(
            parentId = UserInfo.getUserId(), // where to post message
            createdById = userinfo.getuserid(), // author to impersonate
            Type = 'QuestionPost',
            body = QuestionBody,
            NetworkScope = Network.getNetworkId(),  //TopicLst[0].NetworkId,
            Title = QuestionBody.length()>80?QuestionBody.substring(80):QuestionBody,
            isRichText = false
        );
        
        insert item;
          
            
            TopicAssignment obj = new TopicAssignment();
            obj.EntityId = item.id;
            obj.NetworkId = Network.getNetworkId(); //TopicLst[0].NetworkId;
            obj.TopicId = TopicLst[0].Id;
            insert obj;
            return item.id;
        }
        catch(exception ex){
        return 'Error:'+ex.getmessage();
        }
    }
}