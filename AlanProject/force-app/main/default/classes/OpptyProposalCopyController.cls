/**
 *  Apttus Config & Pricing
 *  OpptyProposalCopyController
 *   
 *  @2010-2011 Apttus Inc. All rights reserved.
 */
public with sharing class OpptyProposalCopyController {
  
  static final String PARAM_RECORDTYPE_ID = 'recordTypeId';
  
  // state
  
  // opportunity
  private ID opptyId = null;
  // proposal id
  private ID proposalId = null;
  // record type id
  private ID recordTypeId = null;
  // error indicator
  private Boolean hasErrors = false;
  
    /**
   * Class Constructor specifying initial values
   * @param stdController the standard controller
   */
    public OpptyProposalCopyController(ApexPages.StandardController stdController) {
      
    // get the opportunity id
    this.opptyId = stdController.getId();
    
    // read parameters
    
    // record type id
      String strValue = ApexPages.currentPage().getParameters().get(PARAM_RECORDTYPE_ID);
      if (!ProductCPQSupport.nullOrEmpty(strValue)) {
        this.recordTypeId = String.escapeSingleQuotes(strValue);
        
      }
    
    }
    
    /**
   * Callback invoked when the page is loaded
   * @return the page reference 
   */
    public PageReference onLoad() {
      
      PageReference pageRef = null;
      Savepoint sp = null;
      
      try {
        // get the database savepoint
        sp = Database.setSavepoint();
        
        // get the opportunity sobject
        Opportunity opptySO = ProductCPQSupport.getOpportunitySO(opptyId);
        
        // create the quote/proposal
        this.proposalId = ProductCPQSupport.createQuoteOrProposal(opptySO);
        
        // Call the standard detail page
        // navigate to the quote/proposal detail page
        //pageRef = new PageReference('/' + proposalId);
        pageRef = new PageReference('/apex/Apttus_QPAsset__ProposalConfiguration');
        //pageRef = new PageReference('/apex/Apttus_QPAsset__ProposalConfiguration?id=" &Id&"&useAdvancedApproval=true');
        pageRef.getParameters().put('id', proposalId);
        //pageRef.getParameters().put('method', 'csrFlow');
        pageRef.getParameters().put('useAdvancedApproval', 'true');
        //pageRef.getParameters().put('useDealOptimizer', 'true');
        
        String retPage = ApexPages.currentPage().getParameters().get('retPage');
        if (retPage != null) {
        pageRef.getParameters().put('retPage', retPage);
        }
        pageRef.setRedirect(true);
        
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
   * Checks if there were errors in loading the page
   * @return <code>true</code> if there were errors, <code>false</code> otherwise
   */
  public Boolean getHasErrors() {
    return hasErrors;
    
  }
  
  /**
   * Performs the cancel action
   * @return the next page reference 
   */
  public PageReference doCancel() {
    // navigate to the opportunity 
    return new PageReference('/' + opptyId);
    
  }
  
}