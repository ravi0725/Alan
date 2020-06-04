public without sharing class AddUser
{
    @future
    public static void AddToGroups(Set<Id> userIds)
    {
        //Get the groups that the user should be added to
        Group g=[select Id from Group Where DeveloperName='GCCM_ProjectSight_Portal'];
        Group gLean=[select Id from Group Where DeveloperName='GCCM_LeanSight_Portal'];

        List<User> users=[select id,isActive, Profile.Name from user where id in:userIds and (Profile.Name like 'GCCM - Portal ProjectSight%' Or Profile.Name like 'GCCM - Portal LeanSight%')];
        
        //System.debug('-------users------'+users);
        
        List<GroupMember>listGroupMember =new List<GroupMember>();  
        
        // loop the users that have been created
        for (User user : users)
        {
            //System.debug('-------profile------'+user.Profile.Name);        
            GroupMember gm= new GroupMember(); 
            If(user.Profile.Name.contains('GCCM - Portal ProjectSight'))
            {
                gm.GroupId=g.id;
            }    
            If(user.Profile.Name.contains('GCCM - Portal LeanSight')) 
            { 
                gm.GroupId=gLean.id;
            }      
            gm.UserOrGroupId = user.id;
            listGroupMember.add(gm);   
        } 
        //System.debug('-------listGroupMember-------'+listGroupMember);
        insert listGroupMember;
    }
}