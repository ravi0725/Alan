public class LinkAccontLookupController {
    public List<Account> results{get;set;} // search results
    public string searchString{get;set;} // search keyword
    
    public LinkAccontLookupController() {
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        search();  
    }
    
    public void search(){
        String soql = 'select id, name, Account_Status__c  from Account';
        if(searchString != '' && searchString != null)
            soql = soql +  ' where name LIKE \'%' + searchString +'%\'';/* and FCH_Party_ID__c = null'*/
        soql = soql + ' limit 25';
        system.debug('---soql----'+soql);
        System.debug(soql);
        results = database.query(soql);
    }
}