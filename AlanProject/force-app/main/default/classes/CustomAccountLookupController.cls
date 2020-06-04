public with sharing class CustomAccountLookupController {
 
  public Account Account {get;set;} // new Account to create
  public List<Account> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
 
  public CustomAccountLookupController() {
    Account = new Account();
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
      
    runSearch();  
  }
 
  // performs the keyword search
  public PageReference search() {
    runSearch();
    return null;
  }
 
  // prepare the query and issue the search command
  private void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results = performSearch(searchString);               
  } 
 
  // run the search and return the records found. 
  private List<Account> performSearch(string searchString) {
 
    String soql = 'select id, name, BillingCity, BillingState, Marketing_Segment__c, Owner.Name  from Account';
    if(searchString != '' && searchString != null)
      soql = soql +  ' where name LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\'';
    soql = soql + ' limit 25';
    System.debug(soql);
    return database.query(soql); 
 
  }
 
  // save the new Account record
  //Commented this method as it is not used in page and making code coverage less
  /*public PageReference saveAccount() {
    insert Account;
    // reset the Account
    Account = new Account();
    return null;
  }*/
 
  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    string str = System.currentPageReference().getParameters().get('frm');
    //system.debug('str======'+str);        
    return System.currentPageReference().getParameters().get('frm');
  }
 
  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    string str = System.currentPageReference().getParameters().get('txt');
    system.debug('str======'+str);
    return System.currentPageReference().getParameters().get('txt');
  }
  
}