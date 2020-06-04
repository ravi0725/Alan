/**
 *  Apttus Config & Pricing
 *  ProductCPQSupport
 *   
 *  @2010-2011 Apttus Inc. All rights reserved.
 */
public abstract class ProductCPQSupport {
  
  // parameter names
  public static final String PARAM_ID = 'id';
  public static final String PARAM_CART_ID = 'cartId';
  public static final String PARAM_CONFIG_REQUEST_ID = 'configRequestId';
  public static final String PARAM_USEDEALOPTIMIZER = 'useDealOptimizer';
  public static final String PARAM_MODE = 'mode';
  
  // config modes
  public static final String MODE_READONLY = 'readOnly';
    
  // system properties
  static final String PROP_SYSTEM_PROPERTIES = 'System Properties';
    
  // business object type
  private static final String CATEGORY_QUOTE_OR_PROPOSAL = 'Proposal';
  // summary group types
  private static final String GROUPTYPE_CATEGORY = 'Category';
  private static final String GROUPTYPE_PRODUCT = 'Product';
  
  // status
  private static final String STATUS_NEW = 'New';
  private static final String STATUS_FINALIZED = 'Finalized';
  // record types Acme Car Dealership
  private static final String RECORDTYPE_ADOBE = 'DELL';
  @TestVisible  private static final String RECORDTYPE_PROPOSAL = 'Proposal';
  
  // value types 
  private static final String VALUETYPE_DEFAULT = 'Default';
  private static final String VALUETYPE_PRODUCT = 'Product';
  
  // line types
  public static final String LINETYPE_PRODUCT = 'Product/Service';
  public static final String LINETYPE_OPTION = 'Option';
    
  // global default record name
  private static final String GLOBAL_DEFAULT_NAME = 'All';
  
  // max name field size
  private static final Integer MAX_NAME_SIZE = 80;
    
  // nil value indicator
  private static final String NILVALUE = 'xsi:nil';
    
  /**
    * Creates a quote/proposal using the given opportunity
    * @param opptySO the opportunity to create the quote for
    * @return the id of the created quote/proposal
    */
  public static ID createQuoteOrProposal(Opportunity opptySO) {    
    
    // STEP I - get the proposal record type id
    // get the record type name
    //String recordTypeName = 'DELL';
    
    ID recordTypeId = null;             
    //recordTypeId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), 
    //                     recordTypeName);
    
    if (recordTypeId == null) {
      recordTypeId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), 
                          RECORDTYPE_PROPOSAL);
                          
    }
                         
    // STEP II - create a new quote/proposal object from the opportunity
    Apttus_Proposal__Proposal__c proposalSO = createProposalFromOpportunity(opptySO, recordTypeId);    
               
    // save the proposal 
    insert proposalSO;
    
    // create deal for proposal
    //createDealFromProposal(proposalSO);
    
    // get the quote/proposal id
    return proposalSO.Id;      
    
  }
  
  /**
   * Creates a new proposal from the given opportunity
   * @param opptySO the opportunity to create the proposal for 
   * @param recordTypeId the record type id for the proposal
   * @return the created proposal
   */
  @TestVisible private static Apttus_Proposal__Proposal__c createProposalFromOpportunity(Opportunity opptySO, ID recordTypeId) {
    
    // STEP I - create a new proposal sobject
    Apttus_Proposal__Proposal__c proposalSO = new Apttus_Proposal__Proposal__c();
    
    // initialize the proposal from the opportunity
    
    // STEP II - copy known opportunity fields
    // record type id
    if (recordTypeId != null) {
      proposalSO.RecordTypeId = recordTypeId;
      
    }
    
    // proposal name (max length = 50)
    String opptyName = opptySO.Name;
    if (opptyName != null && opptyName.length() > 50) {
      opptyName = opptyName.substring(0, 50);
      
    }
    
    Integer quoteCount = [select count() from Apttus_Proposal__Proposal__c
                            where Apttus_Proposal__Opportunity__c = :opptySO.Id
                            and Apttus_Proposal__Primary__c = true];
    Boolean isPrimaryQuote = (quoteCount == 0 ? true : false);
    
    // base fields
    proposalSO.Apttus_Proposal__Proposal_Name__c = opptyName;
    // opportunity
    proposalSO.Apttus_Proposal__Opportunity__c = opptySO.Id;
    // account
    proposalSO.Apttus_Proposal__Account__c = opptySO.AccountId;
    // primary contact
    proposalSO.Apttus_Proposal__Primary_Contact__c = getPrimaryContactIdForAccount(opptySO.AccountId);
    // description
    proposalSO.Apttus_Proposal__Description__c = opptySO.Description;
    // primary
    proposalSO.Apttus_Proposal__Primary__c = isPrimaryQuote;
    // price list id
    proposalSO.Apttus_QPConfig__PriceListId__c = opptySO.Price_List__c;
    // pricing date
    proposalSO.Apttus_QPConfig__PricingDate__c = Datetime.now();
    // valid until date
    proposalSO.Apttus_Proposal__Valid_Until_Date__c = Date.today().addDays(30);
    // ready to generate
    proposalSO.Apttus_Proposal__ReadyToGenerate__c = true;
    // ready to present
    proposalSO.Apttus_Proposal__ReadyToPresent__c = true;
    // owner
    proposalSO.OwnerId = opptySO.OwnerId;
   
    // custom fields
    
    
    // return the created proposal
    return proposalSO;
    
  }
  /**
    * Creates a deal using the given proposal
    * @param proposalSO the proposal to create the deal for
    * @return the id of the created deal
    */
    /*
  public static ID createDealFromProposal(Apttus_Proposal__Proposal__c proposalSO) {    
    
    // STEP I - create a new deal sobject
    Apttus_DealMgr__Deal__c dealSO = new Apttus_DealMgr__Deal__c();
    
    // initialize the deal from the proposal
    
    // base fields
    dealSO.Apttus_DealMgr__DealName__c = 'Deal for ' + proposalSO.Apttus_Proposal__Proposal_Name__c;
    // proposal
    dealSO.Quote_Proposal_ID__c = proposalSO.Id;
    // opportunity
    dealSO.Apttus_DealMgr__RelatedOpportunityId__c = proposalSO.Apttus_Proposal__Opportunity__c;
    // account
    dealSO.Apttus_DealMgr__AccountId__c = proposalSO.Apttus_Proposal__Account__c;
    // owner
    dealSO.OwnerId = UserInfo.getUserId();
    // requestor
    dealSO.Apttus_DealMgr__Requestor__c = UserInfo.getUserId();
    // description
    dealSO.Apttus_DealMgr__Description__c = proposalSO.Apttus_Proposal__Description__c;
    // relate object type
    dealSO.Apttus_DealMgr__BusinessObject__c = 'Apttus_Proposal__Proposal__c';
    // status
    dealSO.Approval_Status__c = 'Not Submitted';
    
    insert dealSO;
    
    // get the deal id
    return dealSO.Id;      
    
  }
  */
  
 /**
   * Gets the record type id associated with the given sobject name and record type name
   * @param sObjectName the sobject name
   * @param recordTypeName the record type name to get the record type for
   * @return the record type id
   */
  public static ID getRecordTypeIdForName(String sObjectName, String recordTypeName) {
    
    // get the record type 
    List<RecordType> recordTypes = [SELECT Id
                     FROM RecordType
                     WHERE SobjectType = :sObjectName AND 
                         (Name = :recordTypeName OR
                          DeveloperName = :recordTypeName)
                     LIMIT 1];
         
    return (!recordTypes.isEmpty() ? recordTypes[0].Id : null);
    
  }
  
  /**
   * Gets the primary contact id for the given account id
   * @param acctId the account id to to retrieve the contact for
   * @return the contact sobject id
   */
  private static ID getPrimaryContactIdForAccount(ID acctId) {
    
    // get the contacts for the account
    List<Contact> contacts = [SELECT Id,
                     Name,
                     Title,
                     Phone,
                     Email
                   FROM Contact
                   WHERE AccountId = :acctId
                   LIMIT 1];
                   
    return (!contacts.isEmpty() ? contacts[0].Id : null);
    
  }
  
  /**
   * Gets the instance url
   * @return the instance url 
   */
  public static String getInstanceUrl() {
        
        // get the system property dataset
        Apttus_Config2__ConfigSystemProperties__c prop = Apttus_Config2__ConfigSystemProperties__c.getInstance(PROP_SYSTEM_PROPERTIES);
                                
        return (prop != null && !nullOrEmpty(prop.Apttus_Config2__InstanceUrl__c) 
                ? prop.Apttus_Config2__InstanceUrl__c 
                : null);
                
  }
    
  /**
   * Checks if the given string value is null or empty.
   * @param strValue the string to check
   * @return <code>true</code> if the string value is null or empty, <code>false</code> otherwise
   */
  public static Boolean nullOrEmpty(String strValue) {
    // check if null or zero length string
    return (strValue == null || strValue.trim().length() == 0);
    
  }
  
  /**
   * Checks if the given string value holds a nil value.
   * @param strValue the string to check
   * @return <code>true</code> if the string holds a nil value, <code>false</code> otherwise
   */
  public static Boolean isNilValue(String strValue) {
    return (NILVALUE == strValue);
    
  }
  
  /**
   * Returns ifNull value when the value is null or empty.
   * Otherwise returns actual value
   */
  public static String nullValue(String value, String ifNull) {
    if (nullOrEmpty(value) || isNilValue(value)) {
        return ifNull;
            
    }
        
    return value;
        
  }
    
  /**
   * Gets the opportunity sobject for the given opportunity id
   * @param opptyId the opportunity id to retrieve
   * @return the opportunity sobject 
   */
  public static Opportunity getOpportunitySO(ID opptyId) {
    
    // get the opportunity
    List<Opportunity> opportunities = [SELECT Id,
                          Name,
                          Type,
                          StageName,
                          
                          Price_List__c,
                          OwnerId,
                          LeadSource,
                          Description,
                          CloseDate,
                          Amount,
                          AccountId
                       FROM Opportunity
                       WHERE Id = :opptyId LIMIT 1];
    
    return (!opportunities.isEmpty() ? opportunities[0] : null);
    
  }
    
    /**
     * Gets the product configuration sobject for the given product configuration id
     * @param cartId the cart id 
     * @return the product configuration sobject 
     */
    public static Apttus_Config2__ProductConfiguration__c getCartSO(ID cartId) {
        
        // get the product configurations
        List<Apttus_Config2__ProductConfiguration__c> configs = [SELECT Id,
                                                                        Name,
                                                                        Apttus_QPConfig__Proposald__c,
                                                                        Apttus_Config2__VersionNumber__c,
                                                                        Apttus_Config2__Status__c,
                                                                        Apttus_Config2__SummaryGroupType__c,
                                                                        Apttus_Config2__PrimordialId__c,
                                                                        Apttus_Config2__PriceListId__c, 
                                                                        Apttus_Config2__IsTransient__c,
                                                                        Apttus_Config2__FinalizedDate__c,   
                                                                        Apttus_Config2__ExpectedStartDate__c,   
                                                                        Apttus_Config2__ExpectedEndDate__c, 
                                                                        Apttus_Config2__EffectiveDate__c,   
                                                                        Apttus_Config2__Description__c, 
                                                                        Apttus_Config2__Comments__c,    
                                                                        Apttus_Config2__BusinessObjectType__c,
                                                                        Apttus_Config2__BusinessObjectId__c,                    
                                                                        Apttus_Config2__AncestorId__c
                                                                 FROM Apttus_Config2__ProductConfiguration__c 
                                                                 WHERE Id = :cartId];
        
        return (!configs.isEmpty() ? configs[0] : null);
    
    }
    
}