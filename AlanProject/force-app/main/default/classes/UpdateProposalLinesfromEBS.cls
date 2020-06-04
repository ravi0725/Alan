/*****************************************************************************************
    Name    : UpdateProposalLinesfromEBS
    Desc    : Used to update Line Items / Proposal lines for Timedout Error
                                          
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo            24/08/2016          Created
******************************************************************************************/
global class UpdateProposalLinesfromEBS {
Public static boolean AP_Var = False;
Public Static boolean Validate_Var = False;
public string quoteid;
     /*
     * Method name  : UpdateLines
     * Description  : 
     * Return Type  : list<ResponseWrapper>
     
     */
    webService static list<ResponseWrapper> UpdateLines(HeaderData requestParam, List<InputLineData> requestParamList){
    Map<String,String>LineOutMap = new Map<String,String>();
    List<ResponseWrapper>OutPutWrapper = new List<ResponseWrapper>();
    Map<String,InputLineData>EbsResponse = new Map<String,InputLineData>();
    Map<String,Decimal>QtyMap = new Map<String,Decimal>();
    try{
    for(InputLineData InpVar : requestParamList)
     {
          
          system.debug('>>>>>>>InpVar.PROPOSAL_LINE_ID>>>>>>>'+InpVar.PROPOSAL_LINE_ID);
          system.debug('>>>>>>>InpVar.SELLING_PRICE_EBS_CALCULATED>>>>>>>'+InpVar.SELLING_PRICE_EBS_CALCULATED);
      if(InpVar.PROPOSAL_LINE_ID !=Null && InpVar.SELLING_PRICE_EBS_CALCULATED!=Null)
           LineOutMap.put(InpVar.PROPOSAL_LINE_ID,InpVar.SELLING_PRICE_EBS_CALCULATED);
           EbsResponse.put(InpVar.PROPOSAL_LINE_ID,InpVar);
           
      }
      for(String IDVar : LineOutMap.keyset()){
     if(string.valueof(IDVar).startswith('LI'))
     AP_Var = True;
     else if(String.valueof(IDVar).startswith('QL'))
     Validate_Var = True;
     }
     
     system.debug('----AP_Var-----'+AP_Var);
     system.debug('----Validate_Var-----'+Validate_Var);
     if(AP_Var ==True){
           List<Apttus_Config2__LineItem__c> UpdateLineList = new List<Apttus_Config2__LineItem__c>();
           List<Apttus_Config2__LineItem__c> LineList = new List<Apttus_Config2__LineItem__c>();
           LineList = [select id,Name,Apttus_Config2__LineType__c,Apttus_Config2__NetAdjustmentPercent__c,Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__ListPrice__c,Apttus_Config2__Quantity__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ExtendedPrice__c from Apttus_Config2__LineItem__c where Name in:LineOutMap.keyset()];
              for(Apttus_Config2__LineItem__c li : LineList)
               {
               QtyMap.Put(li.Name,li.Apttus_Config2__Quantity__c);
               }
               
               for(Apttus_Config2__LineItem__c li : LineList)
               {
                   if(QtyMap.get(Li.Name) != Null && Decimal.valueof(LineOutMap.get(Li.Name)) > =0 && (Li.Apttus_Config2__NetAdjustmentPercent__c== Null || (Li.Apttus_Config2__NetAdjustmentPercent__c != Null && Li.Apttus_Config2__NetAdjustmentPercent__c== 0))){
                   
                   Li.Apttus_Config2__ListPrice__c = Decimal.valueof(LineOutMap.get(Li.Name));
                   li.Apttus_Config2__NetPrice__c = Decimal.valueof(LineOutMap.get(Li.Name)) * QtyMap.get(Li.Name);
                   li.Apttus_Config2__ExtendedPrice__c = Decimal.valueof(LineOutMap.get(Li.Name)) *  QtyMap.get(Li.Name);
                   li.Apttus_Config2__BaseExtendedPrice__c = Decimal.valueof(LineOutMap.get(Li.Name)) *  QtyMap.get(Li.Name);
                   Li.Apttus_Config2__BasePrice__c = Decimal.valueof(LineOutMap.get(Li.Name)); 
                   Li.Apttus_Config2__BasePriceOverride__c = Decimal.valueof(LineOutMap.get(Li.Name));  
                   }
                   if((EbsResponse.get(li.Name)!=Null)){
                   system.debug('>>>>>>>>>>>>>li.Apttus_Config2__NetPrice__c>>>>>>>>>>>>>>>'+li.Apttus_Config2__NetPrice__c);
                   system.debug('>>>>>>>>>>>>>Apttus_Config2__ExtendedPrice__c >>>>>>>>>>>>>>>'+li.Apttus_Config2__ExtendedPrice__c);
                   system.debug('>>>>>>>>>>>>>Qty>>>>>>>>>>>>>>>'+QtyMap.get(Li.Name));
                   system.debug('>>>>>>>>>>>>>Service_Start_Date__c>>>>>>>>>>>>>>>'+EbsResponse.get(li.Name).SERV_START_DATE);
                   system.debug('>>>>>>>>>>>>>Service_End_Date__c>>>>>>>>>>>>>>>'+EbsResponse.get(li.Name).SERV_END_DATE);
                   li.Service_Start_Date__c = Date.valueof(EbsResponse.get(li.Name).SERV_START_DATE);
                   li.Service_End_Date__c = date.valueof(EbsResponse.get(li.Name).SERV_END_DATE);
                   if(EbsResponse.get(li.Name).DISCOUNT_EBS_CALCULATED != Null)
                   li.EBS_Discount_Percentage__c = decimal.valueof(EbsResponse.get(li.Name).DISCOUNT_EBS_CALCULATED);
                   if(li.Apttus_Config2__LineType__c!='Option' && li.Apttus_Config2__IsOptionRollupLine__c == FALSE)li.Apttus_Config2__IsCustomPricing__c = True;
                   }
                   
                
                   system.debug('>>>>>>>>>>>>>li>>>>>>>>>>>>>>>'+li);
                   UpdateLineList.add(Li);
               }
           
           if(UpdateLineList.size()>0){
           update UpdateLineList;
         }  
         
         Apttus_Proposal__Proposal__c appQ = [SELECT  Tax__c ,Bill_to_Address_Changed__c,CREDIT_LIMIT_AVAILABLE__C,CREDIT_EXISTING_EXPOSURE__C,CREDIT_CALCULATED_EXPOSURE__c,CREDIT_TOTAL_EXPOSURE__c,Oracle_Error__c,Shipping_Instructions__c,Oracle_Account_Number__c FROM Apttus_Proposal__Proposal__c WHERE Name  =: requestParam.X_PROPOSAL_ID];
            
            appQ.Oracle_Error__c = '';
            appQ.Oracle_Account_Number__c = requestParam.X_EBS_ACCOUNT_NUMBER; 
         
                if(requestParam.X_STATUS == 'SUCCESS'){
                    appQ.Advanced_Pricing_Completed__c = True;
                    appQ.Bill_to_Address_Changed__c = False;
                }
                appQ.Oracle_Error__c = requestParam.X_STATUS; 
                       
            update appQ;
            
      ResponseWrapper ResponseObj = new ResponseWrapper();
      ResponseObj.recordid =appQ.Id;
      ResponseObj.ErrorCode ='S';
      ResponseObj.ErrorMessage ='AP - SUCCESS';
      OutPutWrapper.add(ResponseObj);
        }
        
        // Check if the Call from EBS is for Validate / Submit Order
        else if(Validate_Var == True)
        {
         List<Apttus_Proposal__Proposal_Line_Item__c> QuoteLineList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
         List<Apttus__APTS_Agreement__c>AggList = new List<Apttus__APTS_Agreement__c>();
         Apttus_Proposal__Proposal__c appQ = [SELECT  Name,Tax__c ,Quote_Validated__c,CREDIT_LIMIT_AVAILABLE__C,CREDIT_EXISTING_EXPOSURE__C,CREDIT_CALCULATED_EXPOSURE__c,CREDIT_TOTAL_EXPOSURE__c,Oracle_Error__c,Shipping_Instructions__c,Oracle_Account_Number__c FROM Apttus_Proposal__Proposal__c WHERE Name =: requestParam.X_PROPOSAL_ID];
         QuoteLineList  = [Select Name,Apttus_Proposal__Product__r.Product_Category_Type__c,Type__c,Apttus_QPConfig__AssetId__c,Apttus_Proposal__Product__r.Contract_Item_Type_Code__c,Apttus_Proposal__Product__r.Oracle_ID__c,Apttus_QPConfig__NetAdjustmentPercent__c,Apttus_Proposal__Product__r.Product_Line_Description__c,Parent_Line_Number__c ,Actual_List_Price__c,Pre_Billing__c,Manual_Discount_Amount__c,Defer_Billing__c,Duration_Sequence__c,Duration__c,Duration_UOM__c,Line_Item_Description__c,Customer_PO__c,Bill_to_Address__r.FCH_Party_Site_ID__c,Ship_to_Address1__r.FCH_Party_Site_ID__c,Schedule_Ship_Date__c,Service_Start_Date__c,Service_End_Date__c,Apttus_Proposal__Product__c,Unit_Selling_Price__c,Apttus_Proposal__Product__r.Name,Apttus_Proposal__Product__r.ProductCode,Apttus_Proposal__Product__r.Description,Apttus_QPConfig__OptionId__r.Contract_Item_Type_Code__c,Apttus_Proposal__Quantity__c,Apttus_QPConfig__Quantity2__c,Apttus_QPConfig__PriceUom__c,Apttus_QPConfig__ListPrice__c,Apttus_QPConfig__NetPrice__c,Apttus_QPConfig__SellingTerm__c,Apttus_QPConfig__SellingFrequency__c ,Apttus_QPConfig__LineType__c,Apttus_QPConfig__OptionId__r.ProductCode,Apttus_QPConfig__OptionId__r.Name,Asset_Oracle_ID__c,Apttus_QPConfig__LineNumber__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__r.Name =:requestParam.X_PROPOSAL_ID AND ((Apttus_QPConfig__ChargeType__c = 'Maintenance Fee' AND Apttus_QPConfig__LineType__c = 'Product/Service' AND (Asset_Oracle_ID__c!=null OR Apttus_Proposal__Product__r.Product_Category_Type__c = 'SaaS' OR Apttus_Proposal__Product__r.Product_Category_Type__c = 'Subscription' OR Apttus_Proposal__Product__r.Product_Category_Type__c = 'Maintenance' )) OR (Apttus_QPConfig__LineType__c != 'Option' AND Apttus_QPConfig__ChargeType__c != 'Maintenance Fee') OR (Apttus_QPConfig__LineType__c = 'Option' AND (Apttus_QPConfig__OptionId__r.Contract_Item_Type_Code__c = 'WARRANTY' OR Apttus_QPConfig__OptionId__r.Contract_Item_Type_Code__c = 'SERVICE')))order by Name,Duration_Sequence__c ASC];
         AggList = [Select id,ProServ_Type__c,Apttus__Status_Category__c,Credit_Approved__c,Apttus__Status__c ,CREDIT_LIMIT_AVAILABLE__C,CREDIT_EXISTING_EXPOSURE__C,CREDIT_CALCULATED_EXPOSURE__c,CREDIT_TOTAL_EXPOSURE__c,Credit_Status__c,Fusion_Project_Number__c,Total_Agreement_Value_Formula__c,Apttus__Contract_Start_Date__c,Send_to_Enterprise_Contracts__c, Apttus__Contract_End_Date__c from Apttus__APTS_Agreement__c where Apttus_QPComply__RelatedProposalId__r.Name =: requestParam.X_PROPOSAL_ID and Apttus__Status_Category__c ='In Effect' and Apttus__Status__c='Activated'];
              
            appQ.Oracle_Error__c = '';
            appQ.Oracle_Account_Number__c = requestParam.X_EBS_ACCOUNT_NUMBER; 
             if(requestParam.X_STATUS == 'ERROR' && AggList.size()>0){
             if(requestParam.X_CREDIT_STATUS=='N' && requestParam.X_ISORDER=='1'){
                appQ.Credit_Status__c = requestParam.X_CREDIT_STATUS;
                AggList.get(0).Credit_Status__c = requestParam.X_CREDIT_STATUS;
                appQ.Apttus_Proposal__Approval_Stage__c= 'Credit Check Hold';
                AggList.get(0).Apttus__Status_Category__c = 'Credit Check Hold';
                AggList.get(0).Apttus__Status__c ='Hold';
                }
                appQ.Oracle_Error__c = requestParam.X_MESSAGE; 
                        
            }else{
                if(requestParam.X_TAX_AMOUNT!=null){
                    appQ.Quote_Validated__c = True;
                    appQ.Tax__c = requestParam.X_TAX_AMOUNT;
                }
        }
         
                               
              appQ.Oracle_Error__c = requestParam.X_STATUS; 
                
               
                 if((requestParam.X_CREDIT_STATUS=='Y' || requestParam.X_CREDIT_STATUS=='X') && requestParam.X_ISORDER=='1' && AggList.size()>0){
                 AggList.get(0).Credit_Status__c = requestParam.X_CREDIT_STATUS;
                 AggList.get(0).Send_to_Enterprise_Contracts__c= True;
                 appQ.Credit_Status__c = requestParam.X_CREDIT_STATUS;
                 
                 }
                 
             if(requestParam.X_ISORDER =='1' && AggList.size()>0)
               {
                appQ.CREDIT_LIMIT_AVAILABLE__C = requestParam.X_CREDIT_LIMIT_AVAILABLE;
                appQ.CREDIT_EXISTING_EXPOSURE__C = requestParam.X_CREDIT_EXISTING_EXPOSURE;
                appQ.CREDIT_CALCULATED_EXPOSURE__c = requestParam.X_CREDIT_CALCULATED_EXPOSURE;
                appQ.CREDIT_TOTAL_EXPOSURE__c  = requestParam.X_CREDIT_TOTAL_EXPOSURE; 
                AggList.get(0).CREDIT_LIMIT_AVAILABLE__C = requestParam.X_CREDIT_LIMIT_AVAILABLE;
                AggList.get(0).CREDIT_EXISTING_EXPOSURE__C = requestParam.X_CREDIT_EXISTING_EXPOSURE;
                AggList.get(0).CREDIT_CALCULATED_EXPOSURE__c = requestParam.X_CREDIT_CALCULATED_EXPOSURE;
                AggList.get(0).CREDIT_TOTAL_EXPOSURE__c  = requestParam.X_CREDIT_TOTAL_EXPOSURE;                         
                
                CreditHistoryLogs ch = new CreditHistoryLogs();
                String CreditStatus = (requestParam.X_CREDIT_STATUS== null ? ' ' : requestParam.X_CREDIT_STATUS);
                Decimal CreditTotExp =  (requestParam.X_CREDIT_TOTAL_EXPOSURE== null ? 0 : requestParam.X_CREDIT_TOTAL_EXPOSURE);
                Decimal creditcalcExp = (requestParam.X_CREDIT_CALCULATED_EXPOSURE == null ? 0 : requestParam.X_CREDIT_CALCULATED_EXPOSURE);
                Decimal creditLimtAv = (requestParam.X_CREDIT_LIMIT_AVAILABLE == null ? 0 : requestParam.X_CREDIT_LIMIT_AVAILABLE );
                Decimal creditExtExp = (requestParam.X_CREDIT_EXISTING_EXPOSURE == null ? 0 : requestParam.X_CREDIT_EXISTING_EXPOSURE);
                String LogStr = 'CREDIT_STATUS : '+CreditStatus+'; CREDIT_TOTAL_EXPOSURE : '+CreditTotExp+'; CREDIT_CALCULATED_EXPOSURE : '+creditcalcExp+'; CREDIT_LIMIT_AVAILABLE : '+creditLimtAv+'; CREDIT_EXISTING_EXPOSURE : '+creditExtExp;
                ch.CreateLog(LogStr,appQ.Id,AggList.get(0).Id); 
               }
               
            
                update appQ;
                if(AggList.size()>0)
                update AggList.get(0);
                
                if(requestParam.X_STATUS == 'ERROR'){
             if(requestParam.X_CREDIT_STATUS=='N' && requestParam.X_ISORDER =='1' && AggList.size()>0){
                String AggId = (AggList.size()>0)? AggList.get(0).Id : '';
                SendEmailonSubmitOrderController  email = new SendEmailonSubmitOrderController();
                email.SendEmailToCredit(appQ.Id,AggId);
                }
              }  
              
      ResponseWrapper ResponseObj = new ResponseWrapper();
      ResponseObj.recordid =appQ.Id;
      ResponseObj.ErrorCode ='S';
      ResponseObj.ErrorMessage ='SO - SUCCESS';
      OutPutWrapper.add(ResponseObj);  
      
         
          }      
    /*  //Send Email Notification to User that Process is Completed. 
       List<String> toAdd = new List <String>();
       List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         mail.setSenderDisplayName('Trimble SFDC');
         mail.setToAddresses(toAdd);
         mail.setSubject('Prposal Lines Update Completed For the Quote - '+requestParam.X_PROPOSAL_ID);
      String body = 'Hi <Br/><BR />';
      body += 'The Proposal Lines for the Quote '+requestParam.X_PROPOSAL_ID+ ' is updated, Please continue with further Process.<BR /><BR />';
      body += '<BR/><BR/>Thanks,<BR/><BR/>';
      body += 'SFDC Admin<BR/>';
    
         mail.setHtmlBody(body);
         mails.add(mail);
         Messaging.sendEmail(mails); 
      */
          }
    
    
    catch (exception Ex){
      ResponseWrapper ResponseObj = new ResponseWrapper();
      ResponseObj.recordid =requestParam.X_PROPOSAL_ID;
      ResponseObj.ErrorCode ='E';
      ResponseObj.ErrorMessage ='Error - '+Ex;
      OutPutWrapper.add(ResponseObj);
    }
     return OutPutWrapper;
    }
   
  
 global class HeaderData{
        webservice String X_PROPOSAL_ID {get;set;}
        webservice Decimal X_TAX_AMOUNT {get;set;}
        webservice Decimal X_SHIPPING_AMOUNT{get;set;}
        webservice String X_EBS_ACCOUNT_NUMBER{get;set;}
        webservice String X_STATUS{get;set;}
        webservice String X_MESSAGE{get;set;}
        webservice String X_ISORDER{get;set;}
        webservice String X_CREDIT_STATUS{get;set;}
        webservice Decimal X_CREDIT_TOTAL_EXPOSURE{get;set;}
        webservice Decimal X_CREDIT_CALCULATED_EXPOSURE{get;set;}
        webservice Decimal X_CREDIT_LIMIT_AVAILABLE{get;set;}
        webservice Decimal X_CREDIT_EXISTING_EXPOSURE{get;set;}
  
 }  
    
  global class InputLineData{
        webservice String PROPOSAL_ID{get;set;}
        webservice String PROPOSAL_LINE_ID{get;set;}
        webservice String PROPOSAL_SERV_REF_LINE{get;set;}
        webservice DateTime SERV_START_DATE{get;set;}
        webservice DateTime SERV_END_DATE{get;set;}
        webservice String DISCOUNT_EBS_CALCULATED{get;set;}
        webservice String SELLING_PRICE_EBS_CALCULATED{get;set;}
  
  }
  
  global class ResponseWrapper{
  webservice String recordid {get;set;}    
  webservice String recordType {get;set;}    
  webservice String result{get;set;}
  webservice String ErrorCode{get;set;}
  webservice String ErrorMessage{get;set;}
  }
    }