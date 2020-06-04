public with sharing class CustomAssetAccountlookupPageController{
 
  public Asset asset{get;set;} // new account to create
  public List<Asset> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  public String accountidnew{get;set;}
  public String caseidnew{get;set;}
  public CustomAssetAccountlookupPageController() {
    asset= new Asset();
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    caseidnew= System.currentPageReference().getParameters().get('caseid');
    List<Case> Caselist =new List<Case>();
    Caselist =[select id,Accountid from case where id=:caseidnew];
    accountidnew = Caselist.get(0).Accountid ;
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
  private List<Asset> performSearch(string searchString,string accountidnew) {
    
      String soql = 'select id,name,Status from Asset where  Accountid = \'' +accountidnew+'\'';
    if(searchString != '' && searchString != null)
      soql = soql +  ' and name LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\'';
   
    soql = soql + ' limit 200';
    System.debug(soql);
    return database.query(soql); 
 
  }
 
  // save the new account record
  public PageReference saveAccount() {
    insert asset;
    // reset the account
    asset= new Asset();
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