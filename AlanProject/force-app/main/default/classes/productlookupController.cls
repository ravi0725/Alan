public with sharing class productlookupController{

  public String getContact() {
      return null;
  }
  public List<Product2> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  public set<id> prodId;
  List<PricebookEntry> priceBookList = new List<PricebookEntry>();
  public  Map<Id,string> mapPrdIdUnitPrice;
 
  public productlookupController() {
   // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');   
    
    priceBookList  = new List<PricebookEntry>();
    PriceBook2 pbe2 = new PriceBook2();
    pbe2 = [Select id,name from PriceBook2 where name='GCCM Price Book' limit 1];
    priceBookList  = [Select id,Product2Id,unitprice from PricebookEntry where Pricebook2Id =: pbe2.Id ];
    mapPrdIdUnitPrice = new Map<Id,string>();
    if(!priceBookList.isEmpty()){
        prodId = new Set<Id>();
        for( PricebookEntry pbe : priceBookList ){
            
            prodId.add(pbe.Product2Id);
            mapPrdIdUnitPrice.put(pbe.Product2Id,string.valueof(pbe.UnitPrice));
        }
    }
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
  private List<Product2> performSearch(string searchString) {
     
    String soql = 'Select id,Name,Family,ProductCode from product2 where id=:prodid';
    //soql += prodId ;
    if(searchString != '' && searchString != null)
      soql = soql +  ' and name LIKE \'%' + searchString +'%\'';
    soql = soql + ' limit 25';
    
    List<Product2> prodList = database.query(soql);
    List<Product2> productList = new List<Product2>(); 
    for(Product2 product :  prodList){
    	if(product.Family == 'Hardware' || product.Family == 'Software'){
    		productList.add(product);
    	}
    }
    return productList; 
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