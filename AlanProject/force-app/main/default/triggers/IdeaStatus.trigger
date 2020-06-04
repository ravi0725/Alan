trigger IdeaStatus on Idea(before insert){
for(Idea ideaObj:trigger.new){
if(ideaObj.Status == null)
ideaObj.Status = 'New';
}
}