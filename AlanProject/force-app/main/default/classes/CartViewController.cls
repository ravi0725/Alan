/**
 *  Apttus CPQ Approval
 *  CartViewController
 *   
 *  @2012-2013 Apttus Inc. All rights reserved.
 */
public with sharing class CartViewController  {
    
    
    // context id
    private ID contextId = null;
    // approval type
    private String approvalType = null;
    
    /**
     * Class Constructor 
     * @param stdController the standard controller
     */
    public CartViewController(ApexPages.StandardController stdController) {
        
        // get context id
        contextId = stdController.getId();
        
        // get default approval context type
        //approvalType = SystemUtil.getDefaultApprovalCtxType();
        approvalType = 'cart';
        
    }

    /**
     * Gets context object Id
     */
    public ID getCtxObjectId() {
        return contextId;
    }
    
    /**
     * Gets cart approval context type
     */
    public String getCtxApprovalType() {
        return approvalType;
    }
}