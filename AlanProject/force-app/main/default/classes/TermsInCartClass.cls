/*****************************************************************************************
    Name    : TermsInCartClass
    Desc    : Used to display the Terms from Term object. User can select Terms in from 
              TermsPage, the selected Terms, will be added to ProposalTerms which will be
              be referred in a template used by Quote/Proposal.                              
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta          12/12/2013          Created
******************************************************************************************/
public class TermsInCartClass{
        
    public Id CartDetailView{get;set;}
    public ID configRequestId {get;set;}
    public ID AggID {get;set;}
    public boolean Quote = False;
    Public boolean Agree = False;
    public String termName{get;set;}
    public String condition{get;set;}                    
    public String ProposalID{get;set;}     
    public String priceList{get;set;}
    public String contextItem{get;set;}
    public String lang{get;set;}
    public string flowUI;
    
    private static final String PARAM_ID = 'Id';
    private static final String PARAM_CONFIG_REQUEST_ID = 'configRequestId';

    public Set<Id> selectedContactIds;        
    public List<Term__c> reservedList;    
    public List<TermsWrapperCls> pageTerms{get;set;}
    public List<Term__c> addedTermsList{get;set;}       
    
    public Integer size{get;set;}
    public Integer noOfRecords{get; set;}
        
    public Term__c selectedTerm{get;set;}
   
    /**
      * Method name  : TermsInCartClass
      * Description  : Constructor of the Controller class - Initializes all the variables.
      *                
      * Return Type  : none
      * Parameter    : 
     **/     
     public TermsInCartClass(){
        selectedTerm = new Term__c();        
        addedTermsList = new List<Term__c>();
        pageTerms = new List<TermsWrapperCls>();        
        selectedContactIds = new Set<Id>();
        Id configRequest_Id = ApexPages.CurrentPage().getParameters().get('configRequestId');
        AggID = ApexPages.CurrentPage().getParameters().get('AggID');
        flowUI = System.currentPageReference().getParameters().get('flow'); 
        lang = UserInfo.getLanguage(); 
        String ProposalData = '';
        List<Apttus_Config2__TempObject__c> tempList = new List<Apttus_Config2__TempObject__c>();
        tempList = [SELECT Name, Apttus_Config2__Data__c FROM Apttus_Config2__TempObject__c WHERE ID =: configRequest_Id];
        
        
        for(Apttus_Config2__TempObject__c tempData : tempList){
           ProposalData = tempData.Apttus_Config2__Data__c;
        }
        if(ProposalData != '')
           ProposalID = ProposalData.substringBetween('<BusinessObjectId>','</BusinessObjectId>');
           
          
           
        List<Apttus_Config2__ProductConfiguration__c> cList = new List<Apttus_Config2__ProductConfiguration__c>();
        cList = [Select ID FROM Apttus_Config2__ProductConfiguration__c where Apttus_Config2__BusinessObjectId__c =: ProposalID];            
        for(Apttus_Config2__ProductConfiguration__c pConf : cList){
           CartDetailView = pConf.ID;
        }
          
        String configIdStr = ApexPages.currentPage().getParameters().get(PARAM_ID);
        
        if(configIdStr != null){
           Id configId = String.escapeSingleQuotes(configIdStr);
           List<Apttus_Config2__ProductConfiguration__c> configList = [select Id, Apttus_QPConfig__Proposald__c, Apttus_QPConfig__Proposald__r.Apttus_QPConfig__PriceListId__r.Name  
                                                                         from Apttus_Config2__ProductConfiguration__c where Id = :configId];
           if((configList != null) && (!configList.isEmpty())) {
              ProposalID = configList[0].Apttus_QPConfig__Proposald__c;
              priceList = configList[0].Apttus_QPConfig__Proposald__r.Apttus_QPConfig__PriceListId__r.Name;
           } 
        }
    
        // config request id
        String configRequestIdStr = ApexPages.currentPage().getParameters().get(PARAM_CONFIG_REQUEST_ID);
        if(configRequestIdStr != null){
          configRequestId = String.escapeSingleQuotes(configRequestIdStr);
        }
                                  
        List<Proposal_Term__c> existingTermsList = new List<Proposal_Term__c >();
        
        existingTermsList = [Select Id, Name, Description__c, EditableTerm__c, Related_Product_Category__c,Agreement__c, Quote_Proposal_ID__c, Title__c from 
        Proposal_Term__c where Quote_Proposal_ID__c =: ProposalID or Agreement__c=:ProposalID];
        for(Proposal_Term__c pt : existingTermsList){
          Term__c t = new term__c();
          t.Term_Name__c = pt.Name;
          t.Title__c = pt.Title__c;
          t.Description__c = pt.Description__c;
          t.Related_Product_Category__c = pt.Related_Product_Category__c;
          t.Editable__c  = pt.EditableTerm__c;
          addedTermsList.add(t); 
        }

        pageTerms = calculcatePageTerms();   
     }                   
     
     /**
      * Method name  : getConds
      * Description  : This method is used to set the SelectOptions values - AND & OR.
      * Return Type  : List<SelectOption>
      * Parameter    : none
      **/     
     public List<SelectOption> getConds() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('OR','OR')); 
        options.add(new SelectOption('AND','AND')); 
        return options; 
     }                             
     
     public static List<SelectOption> getProposalTypeValues(){ 
        list<SelectOption> options = new list<SelectOption>();
                
        // Get the object type of the SObject.
        Schema.sObjectType objType = Term__c.getSObjectType(); 
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values = fieldMap.get('Proposal_Type__c').getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        if(UserInfo.getLanguage() == 'DE'){
            options.add(new SelectOption('None', '--Keine--')); 
            options.add(new SelectOption('Quote', 'Angebot'));
            options.add(new SelectOption('Agreement', 'Vertrag'));
        }else if(UserInfo.getLanguage() == 'FR'){
            options.add(new SelectOption('None', '--Aucun--'));
            options.add(new SelectOption('Quote', 'Devis'));
            options.add(new SelectOption('Agreement', 'Contrat'));
        }else{
           options.add(new SelectOption('None', '--None--'));   
           for (Schema.PicklistEntry a : values){ 
             options.add(new SelectOption(a.getLabel(), a.getValue())); 
           }
        }   
        return options;
     }    
  
     /**
      * Method name  : calculcatePageTerms
      * Description  : This method is used to query Terms from Term__C object.
      * Return Type  : List<TermsWrapperCls>
      * Parameter    : none
      **/
     public List<TermsWrapperCls> calculcatePageTerms(){
        List<TermsWrapperCls> pageTermsList = new List<TermsWrapperCls>();
        
        reservedList = new List<Term__c>();
        
        
         /* Modified by Suresh - 03-Feb-2016 : Due to Terms are not showing by Order in Cart*/
         if(priceList.contains('GCCM')){ // Olny for GCCM PriceLists
             List<Term__c> lstTerm = [SELECT Id, Description__c,Term_Name__c, NAME, Related_Product_Category__c, Editable__c, Title__c, Sequence__c FROM Term__c where Pricelist__c INCLUDES(:priceList)];
             Map<Integer, Term__c> nMp = new Map<Integer, Term__c>();
             List<Integer> listIntr = new List<Integer>();
             for(Term__c t : lstTerm){
                 if(t.Term_Name__c.contains('-')){
                     nMp.put(Integer.valueOf(t.Term_Name__c.substringBefore('-').trim()), t);
                     listIntr.add(Integer.valueOf(t.Term_Name__c.substringBefore('-').trim()));
                 }
             }
             listIntr.sort();
             for(Integer i : listIntr){
                 reservedList.add(nMp.get(i));
             }
         }
         else if(priceList.contains('TIBV')){ // For TIBV Ordering Terms in Page
            reservedList = [SELECT Id, Description__c,Term_Name__c, NAME, Related_Product_Category__c, Editable__c, Title__c, Sequence__c FROM Term__c where Pricelist__c INCLUDES(:priceList) ORDER BY Sequence__c ASC NULLS LAST];
         }
         else{ //All Other PriceLists
             reservedList = [SELECT Id, Description__c,Term_Name__c, NAME,  Related_Product_Category__c, Editable__c, Title__c, Sequence__c FROM Term__c where Pricelist__c INCLUDES(:priceList)];
         }
        
         /*******/
        //reservedList = [SELECT Id, Description__c,Term_Name__c, NAME,  Related_Product_Category__c, Editable__c, Title__c, Sequence__c FROM Term__c where Pricelist__c INCLUDES(:priceList)];        
        boolean isMatch;
         
        for(Term__c tn : reservedList){
            isMatch = false;
            for(Term__c tc : addedTermsList){
                if (tn.Term_Name__c == tc.Term_Name__c){
                    isMatch = true;
                    break;
                }
            }
            if (!isMatch){
               pageTermsList.add(new TermsWrapperCls(tn));
            }
        }        
        return pageTermsList;        
     }
     
    /**
      * Method name  : Save
      * Description  : This method is used to save Terms into Proposal_Term__C object.
      * Return Type  : void
      * Parameter    : none
      **/
     public PageReference Save(){
        PageReference pageReference;
        try{
          List<Proposal_Term__c> deleteOldProposalList = new List<Proposal_Term__c>();
          deleteOldProposalList = [Select Id from Proposal_Term__c where Quote_Proposal_ID__c =: ProposalID or Agreement__c=: ProposalID ];
          if(deleteOldProposalList.size() > 0){
            delete deleteOldProposalList;
          }        
          Integer Index = 0;
          List<Proposal_Term__c> proposalTermsList = new List<Proposal_Term__c>();
          for(Term__c t : addedTermsList){
            Proposal_Term__c pt = new Proposal_Term__c();
            pt.Name = t.Term_Name__c;
            pt.Title__c = t.Title__c;
            pt.Description__c = t.Description__c;
            pt.Related_Product_Category__c = t.Related_Product_Category__c;
            pt.Quote_Proposal_ID__c = ProposalID;
            if(AggID !=Null) pt.Agreement__c = AggID;
            pt.Order_Number__c = Index;
            pt.EditableTerm__c = t.Editable__c;
            proposalTermsList.add(pt); 
            Index++;
          }
          if(proposalTermsList.size() > 0)
            insert proposalTermsList;
          
          if(ApexPages.currentPage().getParameters().get('ret') != null && AggID != Null){
            pageReference = new PageReference('/'+AggID);  
          }
          else if(ApexPages.currentPage().getParameters().get('ret') != null){
            pageReference = new PageReference('/'+ProposalID);  
          }
          else if(flowUI=='Angular'){
         pageReference = new PageReference('/apex/Apttus_Config2__Cart?id='+CartDetailView+'&configRequestId='+configRequestId+'&flow='+flowUI);
        }
    else {
     pageReference = new PageReference('/apex/Apttus_Config2__CartDetailView?id='+CartDetailView+'&configRequestId='+configRequestId+'&flow=Default');
        }    
                   
          pageReference.setRedirect(true);
        }catch(Exception e){
          System.debug(e.getMessage());
        }  
          return pageReference;
     }
     
     /**
      * Method name  : addTerms
      * Description  : This method is used to add Terms from pageTermsList.
      * Return Type  : void
      * Parameter    : none
      **/
     public void addTerms(){
        Integer i = 0;                     
        boolean flag = true;         
        for(TermsWrapperCls cWrapper : pageTerms){  
           if(cWrapper.isSelected){        
              flag = false;
              addedTermsList.add(cWrapper.cTerms);
           }
        }
        if(flag){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Select_one_term);
           ApexPages.addMessage(msg); 
           return;
        }
        boolean isMatch;
        pageTerms = new List<TermsWrapperCls>();
        for(Term__c twc : reservedList){
            isMatch = false;
            for(Term__c tc : addedTermsList){
                if (twc.Term_Name__c == tc.Term_Name__c){
                    isMatch = true;
                    break;
                }
            }
            if (!isMatch){
               pageTerms.add(new TermsWrapperCls(twc));
            }
        }        
     }
          
     /**
      * Method name  : removeRow
      * Description  : This method is used to remove Terms from addedTermsList.
      * Return Type  : void
      * Parameter    : none
      **/
     public void removeRow(){
        Integer i = 0;
        system.debug('addedTermsList>>>>'+addedTermsList);
        for(Term__c t : addedTermsList){
            if(t.Term_Name__c == termName){
              break;
            }   
            i = i + 1;  
            System.debug('i: '+i);
        }           
        addedTermsList.remove(i);
        pageTerms = new List<TermsWrapperCls>();        
        
        boolean isMatch;         
        for(Term__c tn : reservedList){
            isMatch = false;
            for(Term__c tc : addedTermsList){
                if (tn.Term_Name__c == tc.Term_Name__c){
                    isMatch = true;
                    break;
                }
            }
            if (!isMatch){
               pageTerms.add(new TermsWrapperCls(tn));
            }
        }
     }         
     
     /**
      * Method name  : filterTerms
      * Description  : This method is used to filter Terms from Term__C object.
      * Return Type  : void
      * Parameter    : none
      **/
     public void filterTerms(){        
        try{
            pageTerms = new List<TermsWrapperCls>();
            List<Term__c> termsList = new List<Term__c>();
            List<TermsWrapperCls> pageTermsList = new List<TermsWrapperCls>();
            List<Proposal_Term__c> proposalTermsList = new List<Proposal_Term__c>();
            
            String query = 'SELECT Id, Name, Description__c, Term_Name__c,  Editable__c, Related_Product_Category__c, Title__c, Customer_Type__c, Sequence__c FROM Term__c where Pricelist__c INCLUDES(\'' + priceList + '\') and ';
            if(selectedTerm.Proposal_Type__c == 'None' && selectedTerm.Customer_Type__c == null && selectedTerm.Language__c == null){
               ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Proposal_Customer_Type);
               ApexPages.addMessage(msg); 
               return;
            }
            
            if(selectedTerm.Language__c != null){
                query = query + 'Language__c = \'' + selectedTerm.Language__c + '\'';             
            }
            
            boolean flag = false;                
            if(selectedTerm.Proposal_Type__c != 'None' && selectedTerm.Customer_Type__c == null){   
                if(selectedTerm.Language__c != null){
                   query = query + ' AND ';
                }     
                query = query + 'Proposal_Type__c INCLUDES(\'' + selectedTerm.Proposal_Type__c + '\')';            
            }else if(selectedTerm.Proposal_Type__c == 'None' && selectedTerm.Customer_Type__c != null){
                if(selectedTerm.Language__c != null){
                   query = query + ' AND ';
                }
                query = query + 'Customer_Type__c =\'' + selectedTerm.Customer_Type__c + '\'';            
            }else if(selectedTerm.Proposal_Type__c != 'None' && selectedTerm.Customer_Type__c != null){
                flag = true;                
                if(condition == null || condition == ''){
                   ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Select_Condition);
                   ApexPages.addMessage(msg); 
                   return;
                }
                if(selectedTerm.Language__c != null){
                   query = query + ' AND ';
                }                          
                if(condition == 'AND'){
                   query = query + 'Proposal_Type__c INCLUDES(\'' + selectedTerm.Proposal_Type__c + '\')';
                   query = query + ' AND ';              
                   query = query + ' Customer_Type__c =\''+selectedTerm.Customer_Type__c+'\'';
                   query = query + ' ORDER BY Sequence__c ASC NULLS LAST';
                   termsList = (List<Term__c>)Database.query(query);
                }else{                  
                    query = query + ' Customer_Type__c =\''+selectedTerm.Customer_Type__c+'\'';
                    termsList = (List<Term__c>)Database.query(query);
                    List<Term__c> termsList1 = new List<Term__c>();
                    
                    query = 'SELECT Id, Name, Term_Name__c,Description__c,Editable__c, Related_Product_Category__c, Title__c, Customer_Type__c, Sequence__c FROM Term__c where Pricelist__c INCLUDES(\'' + priceList + '\') and ';
                    if(selectedTerm.Language__c != null){
                       query = query + 'Language__c = \'' + selectedTerm.Language__c + '\' AND ';             
                    }
                    query = query + 'Proposal_Type__c INCLUDES(\'' + selectedTerm.Proposal_Type__c + '\')';          
                    query = query + ' ORDER BY Sequence__c ASC NULLS LAST';
                    termsList1 = (List<Term__c>)Database.query(query);                            
                    termsList.addAll(termsList1);                      
                }
            }        
            System.debug('query: '+query);
            boolean isMatch;                                                           
            if(!flag){
                query = query + ' ORDER BY Sequence__c ASC NULLS LAST';
                termsList = (List<Term__c>)Database.query(query);
            }
            if(termsList.size() > 0){                      
               /* Modified by Suresh - 03-Feb-2016: Due to Order Terms in Cart page*/
               if(priceList.contains('GCCM')){ // Olny for GCCM PriceLists
                   Map<Integer, Term__c> nMp = new Map<Integer, Term__c>();
                   List<Integer> listIntr = new List<Integer>();
                   for(Term__c t : termsList){
                       if(t.Term_Name__c.contains('-')){
                           nMp.put(Integer.valueOf(t.Term_Name__c.substringBefore('-').trim()), t);
                           listIntr.add(Integer.valueOf(t.Term_Name__c.substringBefore('-').trim()));
                       }
                   }
                   listIntr.sort();
                   // Clear termsList to add ordered Terms
                   termsList.clear();
                   for(Integer i : listIntr){
                       termsList.add(nMp.get(i));
                   }
               }
               /**********/
               for(Term__c tn : termsList){
                  isMatch = false;
                  for(Term__c tc : addedTermsList){
                    if(tn.Term_Name__c == tc.Term_Name__c){
                        isMatch = true;
                        break;
                    }
                  }
                  if(!isMatch){
                     pageTerms.add(new TermsWrapperCls(tn));
                  }
               }
            }else{
               ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.No_Records_Found);
               ApexPages.addMessage(msg); 
            }
         }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(msg);
         }                       
     }
     
     /**
      * Method name  : clearfilterTerms
      * Description  : This method is used to clear all the filters applied by user on vf page.
      * Return Type  : void
      * Parameter    : none
      **/
     public void clearfilterTerms(){
        selectedTerm = new Term__c();       
        condition = '';
        pageTerms = new List<TermsWrapperCls>();
        pageTerms = calculcatePageTerms();        
     }
}