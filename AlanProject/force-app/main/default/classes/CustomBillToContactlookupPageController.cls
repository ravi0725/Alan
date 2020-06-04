public with sharing class CustomBillToContactlookupPageController{

  public List<Contact> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  public String accountidnew{get;set;}
  public String caseidnew{get;set;}
  public CustomBillToContactlookupPageController() {
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    accountidnew= System.currentPageReference().getParameters().get('accountid');
    
    runSearch();  
  }
 
  // performs the keyword search
  public PageReference search() {
      system.debug('--------searchString--------' + searchString);
    runSearch();
    return null;
  }
 
  // prepare the query and issue the search command
  public void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
     system.debug('--------searchString--------' + searchString);
    results = performSearch(searchString,accountidnew);               
  } 
 
  // run the search and return the records found. 
  public List<Contact> performSearch(string searchString,string accountidnew) {
    system.debug('--------searchString--------' + searchString);
      String soql = 'select id,name,Salutation,Account.Name,Account.Site,Account.Enterprise_Party_Number__c,Phone,MobilePhone,HomePhone,Email,Enterprise_Contact_Number__c from contact where Bill_To__c= True and Accountid = \'' +accountidnew+'\'';
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