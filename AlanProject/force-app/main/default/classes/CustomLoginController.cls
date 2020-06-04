public class CustomLoginController
{

    public String username{get; set;}
    public String password {get; set;}
    public Boolean isLoginFailed{get;set;}
    
    public PageReference doLogin()
    {
       isLoginFailed = false;
       PageReference ref=Site.login(username,password,null);
       if(ref==null)
       {
        isLoginFailed=true;
        return null;
       }
       return ref;      
    }
}