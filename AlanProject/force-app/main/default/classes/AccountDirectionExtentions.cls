public class AccountDirectionExtentions {

    public Id accId {set;get;}
    Public String profileName {set;get;}
    public AccountDirectionExtentions(ApexPages.StandardController controller) 
    {
       
    }

    public PageReference AccountDirectionSet()
    {
        profileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        //if(profileName.contains('RE&WS - Customer Community'))
        if(profileName.contains('RE&WS - Customer Portal'))
        {
            accId=ApexPages.CurrentPage().getParameters().get('id');
            String url='/'+accId+'?nooverride=1';
            PageReference newocp = new PageReference(url);
            newocp.setRedirect(true);   
            return newocp;         
        }
        else
        {
            accId=ApexPages.CurrentPage().getParameters().get('id');
            String url='/apex/AccountOverride?id='+accId+'&sfdc.override=1';
            PageReference newocp = new PageReference(url);
            newocp.setRedirect(true);   
            return newocp;         
        }
    }
}