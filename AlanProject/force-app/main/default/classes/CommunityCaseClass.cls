public class CommunityCaseClass{

    public CommunityCaseClass(ApexPages.StandardController standardController){
        
    }
    
    public PageReference newCase(){
        return new PageReference('/500/e?retURL=%2F500%2Fo');
    }
}