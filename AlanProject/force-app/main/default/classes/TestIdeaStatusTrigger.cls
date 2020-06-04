@isTest()
public class TestIdeaStatusTrigger{
static  testmethod void testIdeaStatus(){
Idea idea = new Idea();
     idea.Title = 'Test Title';
     idea.Body = 'Test Body';
     idea.Status = null;
     try{
     insert idea;
     }catch(Exception e){
     system.debug('Oops, Something goes wrong>>>'+e);
     }
}
}