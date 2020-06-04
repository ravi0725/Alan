public with sharing class CustomprimarycontactlookupPageController{
 
  public List<Contact> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  public String accountidnew{get;set;}
  public CustomprimarycontactlookupPageController() {
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    accountidnew= System.currentPageReference().getParameters().get('accountid');
    
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
    results = performSearch(searchString,accountidnew);               
  } 
 
  // run the search and return the records found. 
  private List<Contact> performSearch(string searchString,string accountidnew) {
    
      String soql = 'select id,name,Salutation,Account.Name,Account.Site,Account.Enterprise_Party_Number__c,Phone,MobilePhone,HomePhone,Email,Enterprise_Contact_Number__c from contact where Ship_To__c= True and Accountid = \'' +accountidnew+'\'';
    if(searchString != '' && searchString != null)
      soql = soql +  ' and name LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\'';
   
    soql = soql + ' limit 200';
    System.debug(soql);
    return database.query(soql); 
 
  }

  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }
 
  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }
 
}