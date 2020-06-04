//This class is used to add notes for P1:Case box VF page (inline page on Case pagelayout), through standard Save action but redirect to the same page

public class savep1
    {
        Case request;
        private ApexPages.StandardController controller;
        
        public savep1(ApexPages.StandardController controller) 
            {
                this.controller = controller;
            }
        
        public PageReference savep1() 
            {
                controller.save();
                PageReference requestPage = Page.p1casefields;
                requestPage.setRedirect(false);
                return requestPage;
            
            }
    }