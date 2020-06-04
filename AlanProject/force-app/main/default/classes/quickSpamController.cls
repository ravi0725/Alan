public class quickSpamController{
    
    ApexPages.StandardSetController setCon;
    public quickSpamController(ApexPages.StandardSetController controller)
        {
            setCon = controller;
        }
    
    public pageReference markspam(){
        
        List<Case> caselist = new List<Case>();
                    
            for ( Case cse : (Case[])setCon.getSelected() ){
            
                    cse.status = 'Closed, Spam';
                    caselist.add(cse);
            }
            if(Caselist.size() > 0){
                try{
                     update caselist;
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'These Case(s) are now marked as SPAM and Status is "Closed, Spam"')); 
                         
                } 
                catch (DMLException ex ){
                         ApexPages.addMessages(ex);
                         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'The below Case(s) cannot be marked as SPAM, until the above Validation condition is satisfied')); 
                }
        
           }
            return null;
    }
}