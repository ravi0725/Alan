/*****************************************************************************************
    Name    : custombilltolookupPageController
    Desc    : Used as controller class for the Page custombilltolookupPage as Custom Visualforce Lookup.
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo         29/03/2015          Created
******************************************************************************************/
public with sharing class custombilltolookupPageController{
 
  public Address__c asset{get;set;} // new account to create
  public List<Address__c> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  public String accountidnew{get;set;}
  public String caseidnew{get;set;}
  public custombilltolookupPageController() {
    asset= new Address__c();
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
  public void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results = performSearch(searchString,accountidnew);               
  } 
 
  // run the search and return the records found. 
  public List<Address__c> performSearch(string searchString,string accountidnew) {
    
      String soql = 'select id,Account__r.name,Name,Country__c,Ship_To__c,Site_Name__c,Enterprise_Address_Number__c,Bill_to__c,City__c,Address_line1__c,Address_line2__c,Address_line3__c,Address_line4__c from Address__c where Bill_to__c = TRUE and Account__c= \'' +accountidnew+'\'';
    if(searchString != '' && searchString != null)
      soql = soql +  ' and (Country__c LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\' or Account__r.NAme like \'%' + String.escapeSingleQuotes(searchString) +'%\')';
   
    soql = soql + ' limit 200';
    System.debug(soql);
    return database.query(soql); 
 
  }
 
  // save the new account record
  public PageReference saveAccount() {
    insert asset;
    // reset the account
    asset= new Address__c();
    return null;
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