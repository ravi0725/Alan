/************************************************************************************
* Name          :    expressQuote
* Description   :    
* Author        :    Ashfaq

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
11/14/2013       Ashfaq Mohammed           Created
******************************************************************************************/

Public class expressQuote{
    Public ID AccountID;
    Public Id Oid;
    Public String AccName;
    Public List<Account> acclist = new List<Account>();
    Public Date dCloseDate = system.now().date();
    public string testString{get;set;}
    public Opportunity opty{get;set;}
    
    private static final String RECORDTYPE_PLANCAL_PROPOSAL = 'Plancal Proposal';
    
    public expressQuote(ApexPages.StandardController controller) {
        opty = new Opportunity(); 
        AccountID = ApexPages.CurrentPage().getParameters().get('id');
        acclist = [Select Name,OwnerID from Account where ID =: AccountID];
        for(account a : accList){
            AccName = a.Name;
            Oid = a.OwnerID;
        }
    }
    
    public PageReference cancel(){
        
        PageReference pageReference = new PageReference('/'+AccountID); 
        return pageReference ;
    }
    
    public Pagereference next(){
        
        PageReference pageRef = null;
        Savepoint sp = null;
        String proposalId;
        ID opptyId;
        ID priceLstId;
        
        Boolean hasErrors = false;
        
        try {
            // get the database savepoint
            sp = Database.setSavepoint();
            
            //Create new opportunity
            Opportunity opp = new Opportunity();
            opp.Name = AccName + dCloseDate.month()+dCloseDate.day()+dCloseDate.year();
            opp.StageName='4 - Proposal/Price Quote';
            opp.AccountId = AccountID;
            opp.OwnerId = Oid; 
            opp.CloseDate=dCloseDate ;
            
            opp.Price_List__c = opty.Price_List__c;
            insert opp;
            opptyId =opp.id;
            // priceLstId=opp.Price_list__c;
            
            // get the opportunity sobject
            // Opportunity opptySO = AdobeCPQSupport.getOpportunitySO(opp.id);
            Opportunity opptySO = getOpportunitySO(opp.id);
            //System.debug('opptySO ' +opptySO );
            // create the quote/proposal
            //proposalId = createQuoteOrProposal(opptySO);
            system.debug('proposalId' + proposalId );
            //proposalId = 'a1Fc0000000YP7o';
            
            // Call the standard detail page
            // navigate to the quote/proposal detail page
            
            
            // pageRef= new PageREference('/apex/Apttus_QPAsset__ProposalConfiguration?id='+proposalId+'&method=csrFlow&useAdvancedApproval=true&useDealOptimizer=true');
            pageRef= new PageREference('/apex/Apttus_QPAsset__ProposalConfiguration?id='+proposalId+'&useAdvancedApproval=true');
        } catch (Exception ex) {
            // report error
            ApexPages.addmessages(ex);  
            // indicate error
            hasErrors = true;
            // if a savepoint was set, rollback updates
            if (sp != null) {
                Database.rollback(sp);
                
            }
            
            return null;
            
        }
        
        
        pageRef.setRedirect(true);
        return pageRef; 
        
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
                                           Primary_Contact__c, 
                                           Bill_To_Contact__c,
                                           Price_List__c,
                                           OwnerId,
                                           LeadSource,
                                           Description,
                                           CloseDate,
                                           Register_To__c,
                                           Reseller__c,
                                           Partner_2__c,
                                           Number_of_Months__c,
                                           Ship_to_Address1__c,
                                           Ship_to_Address1__r.Account__c,
                                           Bill_to_Address__c,
                                           Bill_To_Account__c,
                                           Customer_Type__c,
                                           Payment_Term__c,
                                           Industry__c,
                                           Bill_to_Address__r.Account__c,Service_Start_Date__c,Service_End_Date__c,Duration__c,Duration_UOM__c,
                                           Amount,
                                           CurrencyISOCode,
                                           AccountId,
                                           Price_List_Name__c
                                           FROM Opportunity
                                           WHERE Id = :opptyId LIMIT 1];
        
        return (!opportunities.isEmpty() ? opportunities[0] : null);
        
    }
    
    /**
* Creates a quote/proposal using the given opportunity
* @param opptySO the opportunity to create the quote for
* @return the id of the created quote/proposal
*/
    public static ID createQuoteOrProposal(Opportunity opptySO, String accountId){    
        
        // STEP I - get the proposal record type id
        // get the record type name
        //String recordTypeName = 'DELL';
        
        ID recordTypeId = null;             
        recordTypeId = getRecordTypeIdForName(''+Apttus_Proposal__Proposal__c.getSObjectType(), Label.Plancal_Proposal);
        
        // STEP II - create a new quote/proposal object from the opportunity
        
        Apttus_Proposal__Proposal__c proposalSO = createProposalFromOpportunity(opptySO, recordTypeId, accountId);           
        // save the proposal 
        insert proposalSO;
        
        // create deal for proposal
        //createDealFromProposal(proposalSO);
        
        // get the quote/proposal id
        return proposalSO.Id;      
        
    }
    
    /**
* Creates a quote/proposal using the given opportunity
* @param opptySO the opportunity to create the quote for
* @return the id of the created quote/proposal
*/
    public static ID createQuoteOrProposalFromAgreement(Opportunity opptySO, Id accountId, Id agreementId){   
        Apttus__APTS_Agreement__c agreement = [select Apttus_QPComply__RelatedProposalId__c from Apttus__APTS_Agreement__c where Id = :agreementId];
        
        // STEP I - get the proposal record type id
        // get the record type name
        //String recordTypeName = 'DELL';
        
        ID recordTypeId = null;             
        recordTypeId = getRecordTypeIdForName(''+Apttus_Proposal__Proposal__c.getSObjectType(), Label.Plancal_Proposal);
        
        // STEP II - create a new quote/proposal object from the opportunity
        Apttus_Proposal__Proposal__c proposalSO = createProposalFromOpportunity(opptySO, recordTypeId, accountId);
        proposalSO.Initial_Quote_Proposal__c = agreement.Apttus_QPComply__RelatedProposalId__c;
        proposalSO.Initial_Agreement__c = agreement.Id;
        
        // save the proposal 
        insert proposalSO;
        
        // create deal for proposal
        //createDealFromProposal(proposalSO);
        
        // get the quote/proposal id
        return proposalSO.Id;      
        
    }  
    
    /**
* Gets the record type id associated with the given sobject name and record type name
* @param sObjectName the sobject name
* @param recordTypeName the record type name to get the record type for
* @return the record type id
*/
    public static ID getRecordTypeIdForName(String sObjectName, String recordTypeName){
        // get the record type 
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SobjectType = :sObjectName AND DeveloperName =: recordTypeName LIMIT 1];
        return (!(recordTypes != null && recordTypes.isEmpty()) ? recordTypes[0].Id : null);
    }
    
    /**
* Creates a new proposal from the given opportunity
* @param opptySO the opportunity to create the proposal for 
* @param recordTypeId the record type id for the proposal
* @return the created proposal
*/
    @TestVisible  
    private static Apttus_Proposal__Proposal__c createProposalFromOpportunity(Opportunity opptySO, ID recordTypeId, String accountId) {
        
        List<Account> BillToAccount = [select id,Payment_Method__c,Shipping_Method__c,Freight_Term__c from Account where id=:opptySo.Bill_To_Account__c];
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
        
        Integer quoteCount = [select count() from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c =: opptySO.Id and Apttus_Proposal__Primary__c = true];
        Boolean isPrimaryQuote = (quoteCount == 0 ? true : false);
        
        // base fields
        proposalSO.Apttus_Proposal__Proposal_Name__c = opptyName;
        // opportunity
        proposalSO.Apttus_Proposal__Opportunity__c = opptySO.Id;
        // account
        proposalSO.Apttus_Proposal__Account__c = opptySO.AccountId;
        // primary contact
        proposalSO.Apttus_Proposal__Primary_Contact__c = opptySO.Primary_Contact__c;
        // Bill to Contact
        proposalSO.Bill_To_Contact__c = opptySO.Bill_To_Contact__c; 
        // description
        proposalSO.Apttus_Proposal__Description__c = opptySO.Description;
        // primary
        proposalSO.Apttus_Proposal__Primary__c = isPrimaryQuote;
        // price list id
        proposalSO.Apttus_QPConfig__PriceListId__c = opptySO.Price_List__c;
        // pricing date
        proposalSO.Apttus_QPConfig__PricingDate__c = Datetime.now();
        // valid until date
        // TT 129321: Quote's Valid Until Date should be same as Opportunity CloseDate for MEP
        if(opptySO.Price_List_Name__c != null && opptySO.Price_List_Name__c.startsWith('TIBV')){
            proposalSO.Customer_Request_Date__c = system.today();
            proposalSO.Apttus_Proposal__Valid_Until_Date__c = opptySO.CloseDate;
        }
        else
            proposalSO.Apttus_Proposal__Valid_Until_Date__c = Date.today().addDays(30);
        // ready to generate
        proposalSO.Apttus_Proposal__ReadyToGenerate__c = true;
        // ready to present
        proposalSO.Apttus_Proposal__ReadyToPresent__c = true;
        // owner
        proposalSO.OwnerId = opptySO.OwnerId;
        
        proposalSO.Apttus_Proposal__Payment_Term__c =opptySo.Payment_Term__c;
        proposalSO.Apttus_QPConfig__BillToAccountId__c = opptySO.Bill_to_Address__r.Account__c;
        proposalSO.Ship_To_Account__c = opptySO.Ship_to_Address1__r.Account__c;
        // custom fields
        proposalSO.Customer_Type__c = opptySO.Customer_Type__c;
        //proposalSO.Registered_To__c = opptySO.Reseller__c;
        proposalSO.Number_of_Months__c= opptySO.Number_of_Months__c;
        //proposalSO.Register_To__c= opptySO.Register_To__c;
        proposalSO.Ship_to_Address1__c=opptySO.Ship_to_Address1__c;
        proposalSO.Bill_to_Address__c= opptySO.Bill_to_Address__c;
        proposalSO.CurrencyISOCode = opptySO.CurrencyISOCode;
        // soc.initializeOptyRecords();
        proposalSO.Service_Start_Date__c = opptySO.Service_Start_Date__c;
        proposalSO.Service_End_Date__c = opptySO.Service_End_Date__c;
        proposalSO.Duration__c = opptySO.Duration__c;
        proposalSO.Duration_UOM__c = opptySO.Duration_UOM__c;
        proposalSO.Reseller__c= opptySO.Reseller__c;
        proposalSO.Partner_2__c= opptySO.Partner_2__c;
        if(BillToAccount.size()>0){
        proposalSO.Freight_Method__c = BillToAccount.get(0).Shipping_Method__c;
        proposalSO.Payment_Method__c = BillToAccount.get(0).Payment_Method__c;
        proposalSO.Freight_Terms__c = BillToAccount.get(0).Freight_Term__c;
        }
        proposalSO.Industry__c = opptySO.Industry__c;
        // return the created proposal
        return proposalSO;
    }
    
    /**
* Creates a deal using the given proposal
* @param proposalSO the proposal to create the deal for
* @return the id of the created deal
*/
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
}