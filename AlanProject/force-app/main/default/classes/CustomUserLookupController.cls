public with sharing class CustomUserLookupController {
 
  public User User {get;set;} // new User to create
  public List<User> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
 
  public CustomUserLookupController() {
    User = new User();
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
  private List<User> performSearch(string searchString) {
 
   /* String soql = 'select id, name from User';
    if(searchString != '' && searchString != null)
      soql = soql +  ' where name LIKE \'%' + searchString +'%\'';
    soql = soql + ' limit 25';
    System.debug(soql);*/
    String soql = 'select id, name from User where Isactive=true ';
    if(searchString != '' && searchString != null)
      soql = soql +  ' And name LIKE \'%' + searchString +'%\'';
    soql = soql + ' limit 25';
    System.debug(soql);
    return database.query(soql); 
 
  }
 
  // save the new User record
  public PageReference saveUser() {
    insert User;
    // reset the User
    User = new User();
    return null;
  }
 
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