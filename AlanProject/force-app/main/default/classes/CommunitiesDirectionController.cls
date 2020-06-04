/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class CommunitiesDirectionController{

    public String strUname{get;set;}
    public String strPassword{get;set;}
    public string strErrorMessage{get;set;}
    public string strLoginPageLink{get;set;}
    
    global CommunitiesDirectionController()
    {
        strUname = System.currentPageReference().getParameters().get('un');
        strPassword = System.currentPageReference().getParameters().get('pw');
        strErrorMessage = '';
        strLoginPageLink = Label.CommunityLoginPage_DefaultLoginPageURL;
    }
    
    global PageReference login()
    {
     
        PageReference objPageReference = null;
        try
        {
            objPageReference = Site.login(strUname, strPassword, null);
             
            if(objPageReference == null)
            {
                strErrorMessage = Label.CommunityLoginPage_DefaultErrorMessage;
                
            }
         }
         catch(Exception ex)
         {
            strErrorMessage = ex.getMessage();
         }
        return objPageReference;
    }
}