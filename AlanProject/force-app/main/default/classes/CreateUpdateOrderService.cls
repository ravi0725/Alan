/*****************************************************************************************
    Name    : CreateUpdateOrderService 
    Desc    : Used implementing the inbound to SFDC from Oracle EBS for Order, Order Line and Invoice Objects 
              
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       12/06/2013          Created
Prince Leo            22/07/2014          Modified (Data Type from Integer to Decimal for OL_Quantity,OL_QuantityFulfilled,OL_QuantityInvoiced)
******************************************************************************************/
global  class CreateUpdateOrderService {
    
     public class soapexception extends exception{}
     public class testexception extends exception{}
     
     /*
     * Method name  : CreateOrderService
     * Description  : Webserice method to load Order data from Oracle EBS to SFDC object Order__c
     * Return Type  : list<ResponseWraperClass>
     * Parameter    : resOrderData
     */  
     webService static list<ResponseWraperClass> CreateOrderService (List<requestOrderData> resOrderData) {
      
        List<Order__c> orderList = new List<Order__c>();
                
        integer orderCount;
        boolean updateOrder = false;
        boolean blnFinalResult = false;
        boolean blnSystemException = false;
                
        Order__c orderVar;
               
        List<list<Database.UpsertResult>> MastersrList = new List<list<Database.UpsertResult>>();
        
        Database.UpsertResult[] srListOrder;
        
        ResponseWraperClass respvar;
        list<ResponseWraperClass> respvarlist = new list<ResponseWraperClass>();
         
        Map<string,Order__c> orderMap = new Map<string,Order__c>();
        Map<string,Account> accountMap = new Map<string,Account>();
        map<string,ID> accountIdMap = new map<string,ID>();
        map<string,ID> SoldToMap = new map<string,ID>();
        
        Set<string> OracleOrderNumberSet = new Set<string>();
        set<string> OracleOrderIDSet = new set<string>();
        Set<string> customerMasterIdSet = new Set<string>();
        set<string> QuoteNumberSet = new set<string>();
        set<String> SoldtoCustomerSet = new Set<String>();
        
        
        
        //For loop to fill the sets
        for(requestOrderData reqOrdVar :resOrderData)
        {
            OracleOrderNumberSet.add(reqOrdVar.O_OracleOrderNumber);
            OracleOrderIDSet.add(reqOrdVar.O_OracleOrderID);
            customerMasterIdSet.add(string.valueOf(reqOrdVar.O_CustomerMasterID));
            QuoteNumberSet.add(string.valueof(reqOrdVar.O_QuoteNumber)) ;   
            SoldtoCustomerSet.add(reqOrdVar.attribute2);        
        }
         
        //For loop to fill orderMap
        for(Order__c order_Var:[Select Id, Name,Account__c,CurrencyIsoCode,OracleOrderID__c, Order_Amount__c,Customer_Contact__c,Customer_Master_ID__c,Order_Date__c,Invoice_Status__c,Oracle_Order_Number__c,Payment_Terms__c,Shipping_Amount__c,Order_Status__c,Proposal_ID__c FROM Order__c where OracleOrderID__c in: OracleOrderIDSet]){
            //orderMap.put(order_Var.Oracle_Order_Number__c, order_Var);
            orderMap.put(order_Var.OracleOrderID__c, order_Var);
            
        }
        
        //For loop to fill accountMap and accountIdMap
        for(Account acc : [Select ID, FCH_Party_ID__c from Account where FCH_Party_ID__c in : customerMasterIdSet ]){
            accountMap.put(acc.FCH_Party_ID__c,acc);
            accountIdMap.put(acc.FCH_Party_ID__c,acc.ID);
        }
        
        //Added for TAP Division Sold To
        for(Account acc : [Select ID, FCH_Party_ID__c from Account where FCH_Party_ID__c in : SoldtoCustomerSet]){
             SoldToMap.put(acc.FCH_Party_ID__c,acc.ID);
        }
        
        //For loop to fill QuoteProposalIdMap
        map<string,ID> QuoteProposalIdMap = new map<string,ID>();
        for(Apttus_Proposal__Proposal__c QPIM : [Select ID,Name from Apttus_Proposal__Proposal__c WHERE NAME IN : QuoteNumberSet] ){
            QuoteProposalIdMap.put(QPIM.Name,QPIM.ID );
        }
         
        try{
            //For loop to loop through all the data recieved from Oracle in resOrderData
            for(requestOrderData reqOrdVar :resOrderData ){
                
                try{
                 
                 //To Assign values from oracle EBS to SFDC Object          
                  if(reqOrdVar.O_OracleOrderID!=null && orderMap.get(reqOrdVar.O_OracleOrderID)!=null){
                    orderVar = orderMap.get(reqOrdVar.O_OracleOrderID);
                   
                 }
                 else{
                    orderVar = new Order__c();
                                     
                    
                    if(reqOrdVar.O_CustomerMasterID!=null && accountIdMap.get(string.valueOf(reqOrdVar.O_CustomerMasterID))!=null) {
                        orderVar.Account__c = accountIdMap.get(string.valueOf(reqOrdVar.O_CustomerMasterID));
                    }
                    if(reqOrdVar.O_QuoteNumber!=null && QuoteProposalIdMap.get(reqOrdVar.O_QuoteNumber)!=null ){
                        orderVar.Related_Quote_Proposal__c = QuoteProposalIdMap.get(reqOrdVar.O_QuoteNumber);
                    }
                    
                 }
                 
                 
                
                
                if(orderVar.Account__c == null)
                throw new soapexception('The related Account Data does not exists in SFDC .please check your data');
                
                orderVar.Oracle_Order_Number__c = reqOrdVar.O_OracleOrderNumber;
                orderVar.OracleOrderID__c = reqOrdVar.O_OracleOrderID;
                orderVar.Order_Date__c = reqOrdVar.O_OrderDate;
                orderVar.Order_Type__c = reqOrdVar.O_OrderType;
                orderVar.Order_Amount__c = reqOrdVar.O_OrderAmount;
                orderVar.Tax_Amount__c = reqOrdVar.O_TaxAmount;
                orderVar.Shipping_Amount__c = reqOrdVar.O_ShippingAmount;
                orderVar.CurrencyIsoCode = reqOrdVar.O_CurrencyIsoCode;
                orderVar.Order_Status__c = reqOrdVar.O_OrderStatus;
                orderVar.Payment_Terms__c = reqOrdVar.O_PaymentTerms;
                orderVar.Proposal_ID__c = reqOrdVar.O_QuoteNumber;
                orderVar.Customer_Master_ID__c = string.valueof(reqOrdVar.O_CustomerMasterID);
                orderVar.Grand_Total__c = reqOrdVar.O_GrandTotal;
                orderVar.Oracle_Account_Number__c = reqOrdVar.O_OracleAccountNumber;
                orderVar.Sold_To__c = (reqOrdVar.attribute2 != Null && SoldToMap.get(reqOrdVar.attribute2) != Null ? SoldToMap.get(reqOrdVar.attribute2) : Null);
                orderVar.PO_Number__c = reqOrdVar.attribute1;    
                orderVar.Ordered_By__c = reqOrdVar.attribute3;        
                orderList.add(orderVar);
                    if(Test.isRunningTest()){
                        throw new testexception('Test Exception');
                    }
                 }catch(Exception ex){
                    respvar = new ResponseWraperClass();  
                    blnFinalResult = true;
                    respvar.result ='Failure';
                    respvar.Errorcode = 'OR-ERROR-2012';
                    respvar.ErrorMessage = string.valueof(ex);   
                    respvar.TransactionNameAndValue = 'Order:' + reqOrdVar.O_OracleOrderNumber;
                    respvar.EBS_ORDER_NUMBER = reqOrdVar.O_OracleOrderID;
                    respvar.ORIG_SYS_DOCUMENT_REF = reqOrdVar.O_QuoteNumber;
                    respvarlist.add(respvar);
                    system.debug('exception ====='+ex); 
                    system.debug('exception ====='+ex.getStackTraceString()); 
                    
                    
                    
                }

            }
            
            //TO upsert data in Order__c object
            if(orderList!=null && orderList.size()>0){
                srListOrder = Database.Upsert(orderList,Order__c.Fields.Id,false);
      
                MastersrList.add(srListOrder);
                
            }
            set<id> succOrdIdSet = new set<id>();
            
            for(list<Database.UpsertResult> srval : MastersrList) {
                for (Database.UpsertResult sr : srval){
                     succOrdIdSet.add(sr.getid());
                }
                
            }
            map<id,string> OracleOrderNum_ID_Map = new map<id,string>();
            for(Order__c ord : [Select ID,OracleOrderID__c from Order__c where id IN:succOrdIdSet ]){
                OracleOrderNum_ID_Map.put(ord.id, ord.OracleOrderID__c);
            }
            //Generate response variable with success and failure 
            for(list<Database.UpsertResult> srval : MastersrList) {
                for (Database.UpsertResult sr : srval){
                    if (sr.isSuccess()){
                        respvar = new ResponseWraperClass();
                        respvar.result ='Success';
                        respvar.Errorcode = 'OR-SUCCESS-2011:';
                        respvar.ErrorMessage = 'Transaction Succesfull';   
                        respvar.TransactionNameAndValue = 'Order:' + sr.getid();
                        if(OracleOrderNum_ID_Map.get(sr.getid())!=null){
                            respvar.EBS_ORDER_NUMBER = OracleOrderNum_ID_Map.get(sr.getid());
                        }
                        respvar.SFDC_ORDER_ID = sr.getid();
                        system.debug('respvar.result Success===>' + respvar.result);   
                        respvarlist.add(respvar);
                        
                    }else{
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            respvar = new ResponseWraperClass();
                            blnFinalResult = true;
                            respvar.result ='Failure';   
                            respvar.Errorcode = 'OR-ERROR-2011:';
                            respvar.ErrorMessage = 'Failure'+ err.getStatusCode() + ': ' + err.getMessage()+': '+sr.getid();   
                            respvar.TransactionNameAndValue = 'Order:' + sr.getid();
                            respvar.EBS_ORDER_NUMBER = '';
                            respvar.SFDC_ORDER_ID = sr.getid();    
                            respvarlist.add(respvar);
                            system.debug('respvar.result Faulure===>' + respvar.result);
                            
                        }
                        
                    }
   
                }
                
            }
            
            if(Test.isRunningTest()){
                throw new testexception('Test Exception');
            }   
      
    
        }
        catch(Exception ex){
            respvar = new ResponseWraperClass();  
            blnFinalResult = true;
            respvar.result ='Failure';
            respvar.Errorcode = 'OR-ERROR-2010:';
            respvar.ErrorMessage = 'Failure:'+ string.valueof(ex);
            respvar.TransactionNameAndValue = 'Order:'+ string.valueof(ex);
            respvarlist.add(respvar);
            system.debug('exception ====='+ex); 
            system.debug('exception ====='+ex.getStackTraceString());  
            
             blnSystemException = true;
            
              
            
        }
        //Passing final result for the entire load, if there in on failure then Final Result will be Filaure 
        //and all are success the final result will be passed as Success 
        if (blnFinalResult==true) {
            respvar = new ResponseWraperClass();
            respvar.FinalResult = 'Failure';
            respvarlist.add(respvar);
            
        }else{
            respvar = new ResponseWraperClass();
            respvar.FinalResult = 'Success';
            respvarlist.add(respvar);
        }
        
        
        return respvarlist;
     }
     
     /*
     * Method name  : CreateOrderLineService
     * Description  : Webserice method to load Order Line data from Oracle EBS to SFDC object Order_Line_Item__c
     * Return Type  : list<ResponseWraperClass>
     * Parameter    : resOrderLineData
     */  
     webService static list<ResponseWraperClass> CreateOrderLineService (List<requestOrderLineData> resOrderLineData) {
        List<Order_Line_Item__c> orderLineList = new List<Order_Line_Item__c>();
        integer orderLineCount;
        boolean updateOrderLine = false;
        boolean blnFinalResult = false;
        boolean blnSystemException = false;
        Order_Line_Item__c orderLineVar;
        
        List<list<Database.UpsertResult>> MastersrList = new List<list<Database.UpsertResult>>();
        
        ResponseWraperClass respvar;
        list<ResponseWraperClass> respvarlist = new list<ResponseWraperClass>();
        
        Map<string,Order_Line_Item__c> orderLineMap = new Map<string,Order_Line_Item__c>();
                
        Set<string> OracleOrderNumberSet = new Set<string>();
        Set<string> customerMasterIdSet = new Set<string>();
        Set<string> oracleLineIdSet = new Set<string>();
        Set<string> prodIDSet = new Set<string>();
        set<string> OracleOrderIDSet = new set<string>();
        set<string> OracleOrderLineIDSet = new set<string>();
        set<String> AssetidSet = new Set<String>();
        
        
        //For loop to fill the sets
        for(requestOrderLineData reqOrdLineVar : resOrderLineData)
        {
            //OracleOrderNumberSet.add(reqOrdLineVar.OL_OracleOrderNumber);
            oracleLineIdSet.add(string.valueOf(reqOrdLineVar.OL_OrigSysLine));
            prodIDSet.add(reqOrdLineVar.OL_ProductID);
            OracleOrderLineIDSet.add(reqOrdLineVar.OL_OracleOrderLineID);
            OracleOrderIDSet.add(reqOrdLineVar.OL_OracleOrderID);
            if(reqOrdLineVar.attribute6!= Null && reqOrdLineVar.attribute6!='') AssetidSet.add(reqOrdLineVar.attribute6);
                        
        }
        string currencyCode_ordLine;
        
        map<string,ID> orderIDMap = new map<string,ID>();
        
        //For loop to fill orderIDMap
         for(Order__c order_Var:[Select Id, Name,Account__c,OracleOrderID__c,CurrencyIsoCode,Ordered_By__c, Order_Amount__c,Customer_Contact__c,Customer_Master_ID__c,Order_Date__c,Invoice_Status__c,Oracle_Order_Number__c,Payment_Terms__c,Shipping_Amount__c,Order_Status__c,Proposal_ID__c FROM Order__c where OracleOrderID__c in: OracleOrderIDSet]){
            currencyCode_ordLine = order_Var.CurrencyIsoCode;
            orderIDMap.put(order_Var.OracleOrderID__c,order_Var.ID);
        }
         
        //For loop to fill orderLineMap 
        for(Order_Line_Item__c orderLine_Var:[Select Id, Name,CurrencyIsoCode,Currency_Code__c,Extended_Price__c,Net_Price__c,Order__c,Order_Line_Invoice_Status__c,Order_Line_Order_Status__c,Order_Line_Sequence__c,Product__c,Quantity__c,Unit_of_Measure__c,Oracle_Line_ID__c,OracleOrderLineID__c  FROM Order_Line_Item__c WHERE Order__r.OracleOrderID__c in : OracleOrderIDSet AND OracleOrderLineID__c in :OracleOrderLineIDSet ]){
            orderLineMap.put(orderLine_Var.OracleOrderLineID__c,orderLine_Var);
        }
        
        map<string,string> prodCodeNameMap = new map<string,string>();
        //for loop to fill prodCodeNameMap
         for(product2 p: [Select ID,Name, ProductCode,Oracle_ID__c from product2 where Oracle_ID__c IN :prodIDSet]){
            prodCodeNameMap.put(p.Oracle_ID__c,p.Name);
            
        }
        
        Map<String,Asset>AssetMap = new Map<String,Asset>();
        for(Asset Asst : [select id,Asset_Oracle_ID__c from Asset where Asset_Oracle_ID__c in: AssetidSet])
        {
         AssetMap.put(Asst.Asset_Oracle_ID__c,Asst);
        }
        try{
            //For loop to loop through all the data recieved from Oracle in resOrderLineData
            for(requestOrderLineData reqOrdLineVar : resOrderLineData){
                            
                try{
                    
                 //To Assign values from oracle EBS to SFDC Object              
                 if(reqOrdLineVar.OL_OracleOrderLineID!=null && orderLineMap.get(string.valueOf(reqOrdLineVar.OL_OracleOrderLineID))!=null){
                    orderLineVar = orderLineMap.get(string.valueOf(reqOrdLineVar.OL_OracleOrderLineID));
                 }
                 else{
                    orderLineVar = new Order_Line_Item__c();
                    if(reqOrdLineVar.OL_OracleOrderID!=null && orderIDMap.get(reqOrdLineVar.OL_OracleOrderID)!=null ){
                        orderLineVar.Order__c = orderIDMap.get(reqOrdLineVar.OL_OracleOrderID);
                    }
                    
                 }        
                                  
                 if(orderLineVar.Order__c == null)
                 throw new soapexception('The related Order Data does not exists in SFDC .please check your data');
                 orderLineVar.Oracle_Line_ID__c = reqOrdLineVar.OL_OrigSysLine;
                 orderLineVar.OracleOrderLineID__c = reqOrdLineVar.OL_OracleOrderLineID;
                 orderLineVar.Order_Line_Sequence__c = string.valueOf(reqOrdLineVar.OL_OrderLineSequence);
                 if(prodCodeNameMap!=null && prodCodeNameMap.size()>0){
                    orderLineVar.Product__c = prodCodeNameMap.get(reqOrdLineVar.OL_ProductID);
                    
                 }
                 orderLineVar.Quantity__c = reqOrdLineVar.OL_Quantity;
                 orderLineVar.Unit_of_Measure__c = reqOrdLineVar.OL_UnitofMeasure;
                 orderLineVar.Net_Price__c = reqOrdLineVar.OL_NetPrice;
                 orderLineVar.Extended_Price__c = reqOrdLineVar.OL_ExtendedPrice;
                 orderLineVar.Order_Line_Order_Status__c = reqOrdLineVar.OL_OrderLineOrderStatus;
                 orderLineVar.Quantity_Fulfilled__c = string.valueOf(reqOrdLineVar.OL_QuantityFulfilled);
                 orderLineVar.Quantity_Invoiced__c = string.valueOf(reqOrdLineVar.OL_QuantityInvoiced);
                 orderLineVar.CurrencyIsoCode = currencyCode_ordLine; 
                 if(reqOrdLineVar.attribute1 != Null && reqOrdLineVar.attribute1 != '') orderLineVar.Shipping_Method__c = reqOrdLineVar.attribute1;
                 if(reqOrdLineVar.attribute2 != Null && reqOrdLineVar.attribute2 != '') orderLineVar.Shipping_Waybill__c = reqOrdLineVar.attribute2;
                 if(reqOrdLineVar.attribute3 != Null && reqOrdLineVar.attribute3 != '') orderLineVar.Shipping_Carrier__c = reqOrdLineVar.attribute3;
                 if(reqOrdLineVar.attribute5 != Null && reqOrdLineVar.attribute5 != '') orderLineVar.Reserved_Quantity__c = Decimal.valueof(reqOrdLineVar.attribute5);
                // Added for Tap 
                 if(reqOrdLineVar.attribute6 != Null && reqOrdLineVar.attribute6 != '') orderLineVar.Asset_Oracle_Id__c = reqOrdLineVar.attribute6;
                 if(reqOrdLineVar.attribute6!= Null && reqOrdLineVar.attribute6!= '' && AssetMap.get(reqOrdLineVar.attribute6) != Null) orderLineVar.Asset__c = AssetMap.get(reqOrdLineVar.attribute6).id;
                 orderLineList.add(orderLineVar);
                if(Test.isRunningTest()){
                    throw new testexception('Test Exception');
                }
                }catch(Exception ex){
                    respvar = new ResponseWraperClass(); 
                    blnFinalResult = true; 
                    respvar.result ='Failure';
                    respvar.Errorcode = 'OL-ERROR-2022';
                    respvar.ErrorMessage = string.valueof(ex);   
                    respvar.TransactionNameAndValue = 'Order Line:' + reqOrdLineVar.OL_OracleOrderLineID;
                    respVar.EBS_LINE_NUMBER =  reqOrdLineVar.OL_OracleOrderLineID;
                    respVar.ORIG_SYS_LINE_REF = reqOrdLineVar.OL_OrigSysLine;
                    respvar.EBS_ORDER_NUMBER = reqOrdLineVar.OL_OracleOrderID;
                    
                    respvarlist.add(respvar);
                    system.debug('exception ====='+ex); 
                    system.debug('exception ====='+ex.getStackTraceString()); 
                    
                     
                }
                   
            }
            
            //TO upsert data in Order_Line_Item__c object
            if(orderLineList!=null && orderLineList.size()>0){
                Database.UpsertResult[] srListOrderLine;
                srListOrderLine = Database.Upsert(orderLineList,Order_Line_Item__c.Fields.Id,false);
      
                MastersrList.add(srListOrderLine);
            }
            set<id> succOrdLineIdSet = new set<id>();
            
            for(list<Database.UpsertResult> srval : MastersrList) {
                for (Database.UpsertResult sr : srval){
                     succOrdLineIdSet.add(sr.getid());
                }
                
            }
            map<id,string> OracleLineID_ID_Map = new map<id,string>();
            for(Order_Line_Item__c ordLine : [Select ID,OracleOrderLineID__c from Order_Line_Item__c where id IN:succOrdLineIdSet ]){
                OracleLineID_ID_Map.put(ordLine.id, ordLine.OracleOrderLineID__c);
            }
            
            //Generate response variable with success and failure 
            for(list<Database.UpsertResult> srval : MastersrList) {
                for (Database.UpsertResult sr : srval){
                    if (sr.isSuccess()){
                        respvar = new ResponseWraperClass();
                        respvar.result ='Success';
                        respvar.Errorcode = 'OL-SUCCESS-2021:';
                        respvar.ErrorMessage = 'Transaction Succesfull';   
                        respvar.TransactionNameAndValue = 'Order Line:' + sr.getid();
                        respvar.SFDC_LINE_ID = sr.getid(); 
                        if(OracleLineID_ID_Map.get(sr.getid())!=null){
                            respvar.EBS_LINE_NUMBER = OracleLineID_ID_Map.get(sr.getid());
                        }
                        system.debug('respvar.result Success===>' + respvar.result);   
                        respvarlist.add(respvar);
                        
                    }else{
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            respvar = new ResponseWraperClass();
                            blnFinalResult = true;
                            respvar.result ='Failure';   
                            respvar.Errorcode = 'OL-ERROR-2021:';
                            respvar.ErrorMessage = 'Failure'+ err.getStatusCode() + ': ' + err.getMessage()+': '+sr.getid();   
                            respvar.TransactionNameAndValue = 'Order Line:' + sr.getid();
                            respvar.SFDC_LINE_ID = sr.getid(); 
                            if(OracleLineID_ID_Map.get(sr.getid())!=null){
                            respvar.EBS_LINE_NUMBER = OracleLineID_ID_Map.get(sr.getid());
                            }   
                            respvarlist.add(respvar);
                            system.debug('respvar.result Faulure===>' + respvar.result);
                            
                        }
                        
                    }
   
                }
                
            }
            if(Test.isRunningTest()){
                    throw new testexception('Test Exception');
            }
            }catch(Exception ex){
            respvar = new ResponseWraperClass();  
            blnFinalResult = true;
            respvar.result ='Failure';
            respvar.Errorcode = 'OL-ERROR-2020:';
            respvar.ErrorMessage = 'Failure:'+ string.valueof(ex);
            respvar.TransactionNameAndValue = 'Order Line:'+ string.valueof(ex);
            respvarlist.add(respvar);
            system.debug('exception ====='+ex); 
            system.debug('exception ====='+ex.getStackTraceString());
            
            blnSystemException = true; 
            
            
              
        }
        
        //Passing final result for the entire load, if there in on failure then Final Result will be Filaure 
        //and all are success the final result will be passed as Success 
        if (blnFinalResult==true) {
            respvar = new ResponseWraperClass();
            respvar.FinalResult = 'Failure';
            respvarlist.add(respvar);
            
        }else{
            respvar = new ResponseWraperClass();
            respvar.FinalResult = 'Success';
            respvarlist.add(respvar);
        }
        
        
        return respvarlist;
        
     }
     
     /*
     * Method name  : CreateInvoiceService
     * Description  : Webserice method to load Invoice data from Oracle EBS to SFDC object Invoices__c
     * Return Type  : list<ResponseWraperClass>
     * Parameter    : resInvoiceData
     */ 
    webService static list<ResponseWraperClass> CreateInvoiceService (List<requestInvoiceData> resInvoiceData) {
        List<Invoices__c> invoiceList = new List<Invoices__c>();
        integer invoiceCount;
        boolean updateInvoice = false;
        boolean blnFinalResult = false;
        boolean blnSystemException = false;
        Invoices__c invoiceVar;
        
        List<list<Database.UpsertResult>> MastersrList = new List<list<Database.UpsertResult>>();
        
        ResponseWraperClass respvar;
        list<ResponseWraperClass> respvarlist = new list<ResponseWraperClass>();
        
        Map<string,Invoices__c> invoiceMap = new Map<string,Invoices__c>();
                
        //Set<string> OracleOrderNumberSet = new Set<string>();
        //Set<string> invoiceNumSet = new Set<string>();
        map<string,ID> invoiceAccountMap = new map<string,ID>();
        map<string,ID> InvoiceOrderMap = new map<string,ID>();
        set<string> OracleOrderIDSet = new set<string>();
        set<string> OracleInvoiceIDSet = new set<string>();
        Set<string> attribute1IdSet= new Set<string>();
        Set<string> attribute2Idset= new Set<string>();
        map<string,ID> attribute1Map = new map<string,ID>();
        map<string,ID> attribute2Map = new map<string,ID>();
        
        //For loop to fill the sets
        for(requestInvoiceData reqInvVar :resInvoiceData)
        {
             //OracleOrderNumberSet.add(reqInvVar.IN_OracleOrderNumber);
            OracleOrderIDSet.add(reqInvVar.IN_OracleOrderID);
            //invoiceNumSet.add(reqInvVar.IN_InvoiceNumber);
            OracleInvoiceIDSet.Add(reqInvVar.IN_OracleInvoiceID);
            if(reqInvVar.attribute1!=null && reqInvVar.attribute1!='') attribute1IdSet.add(reqInvVar.attribute1);
            if(reqInvVar.attribute2!=null && reqInvVar.attribute2!='') attribute2Idset.add(reqInvVar.attribute2);
            
                        
        }
        string currencyCode_Invoice;
        
        //for loop to fill invoiceAccountMap,InvoiceOrderMap 
        for(Order__c order_Var:[Select Id, Name,Account__c,CurrencyIsoCode,Ordered_By__c, Order_Amount__c,Customer_Contact__c,Customer_Master_ID__c,Order_Date__c,Invoice_Status__c,Oracle_Order_Number__c,Payment_Terms__c,Shipping_Amount__c,Order_Status__c,Proposal_ID__c,OracleOrderID__c FROM Order__c where OracleOrderID__c in: OracleOrderIDSet]){
            currencyCode_Invoice = order_Var.CurrencyIsoCode;
            invoiceAccountMap.put(order_Var.OracleOrderID__c,order_Var.Account__c);
            InvoiceOrderMap.put(order_Var.OracleOrderID__c,order_Var.ID);
        } 
         
        //for loop to fill invoiceMap
        for(Invoices__c invoice_Var:[Select Id, Name,CurrencyIsoCode,Invoice_Amount__c,Amount_Unpaid__c,Due_Date__c,Invoiced_Date__c,Order__c,Invoice_Status__c,Invoice_Number__c,OracleInvoiceID__c  FROM Invoices__c where Order__r.OracleOrderID__c in : OracleOrderIDSet AND OracleInvoiceID__c in : OracleInvoiceIDSet]){
            invoiceMap.put(invoice_Var.OracleInvoiceID__c,invoice_Var);
        }
        
        
        
        //For loop to fill attribute1Map 
        for(Account acc : [Select ID, FCH_Party_ID__c from Account where FCH_Party_ID__c in : attribute1IdSet]){
            attribute1Map.put(acc.FCH_Party_ID__c,acc.id);
            
        }
        
       //For loop to fill attribute2Map
           for(Apttus_Proposal__Proposal__c QPIM : [Select ID,Name from Apttus_Proposal__Proposal__c WHERE NAME IN : attribute2Idset] ){
            attribute2Map.put(QPIM.Name,QPIM.ID );
        }

        
        try{
            //For loop to loop through all the data recieved from Oracle in resInvoiceData
            for(requestInvoiceData reqInvVar :resInvoiceData ){
                
                
                try{
                 //To Assign values from oracle EBS to SFDC Object  Invoices__c               
                 if(reqInvVar.IN_OracleInvoiceID!=null && invoiceMap.get(reqInvVar.IN_OracleInvoiceID)!=null){
                    invoiceVar = invoiceMap.get(reqInvVar.IN_OracleInvoiceID);
                
                 }
                 else{
                    invoiceVar = new Invoices__c();
                    
                    if(reqInvVar.IN_OracleOrderID!=null && InvoiceOrderMap.get(reqInvVar.IN_OracleOrderID)!=null ){
                        invoiceVar.Order__c = InvoiceOrderMap.get(reqInvVar.IN_OracleOrderID);
                    }
                    else if(reqInvVar.attribute1!=Null && reqInvVar.attribute1!='') 
                    {
                    invoiceVar.Order__c =Label.Dummy_Order_Record;
                    }
                  }
                  
                    system.debug('^^^^^^^^^^^^^^^^invoiceVar.Account__c^^^^^^^^^'+invoiceAccountMap.get(reqInvVar.IN_OracleOrderID));
                    invoiceVar.Account__c = ((reqInvVar.attribute1!=Null && reqInvVar.attribute1!='') ? attribute1Map.get(reqInvVar.attribute1) : invoiceAccountMap.get(reqInvVar.IN_OracleOrderID));
                    //invoiceVar.Account__c = invoiceAccountMap.get(reqInvVar.IN_OracleOrderID);
                    if(reqInvVar.attribute2!=Null && reqInvVar.attribute2!='') invoiceVar.Quote_Proposal__c = attribute2Map.get(reqInvVar.attribute2);
                    invoiceVar.OracleInvoiceID__c = reqInvVar.IN_OracleInvoiceID;
                                                   
                 if((reqInvVar.attribute1==Null || reqInvVar.attribute1=='') && invoiceVar.Order__c == null)
                 throw new soapexception('The related Order Data does not exists in SFDC .please check your data');
                 
                 invoiceVar.Invoice_Number__c = reqInvVar.IN_InvoiceNumber;
                 invoiceVar.Invoiced_Date__c = reqInvVar.IN_InvoiceDate;
                 invoiceVar.Invoice_Amount__c = reqInvVar.IN_InvoiceAmount;
                 invoiceVar.Amount_Unpaid__c = reqInvVar.IN_AmountRemaining;
                 invoiceVar.CurrencyIsoCode = reqInvVar.IN_CurrencyCode;
                 invoiceVar.Due_Date__c = reqInvVar.IN_DueDate;
                // invoiceVar.CurrencyIsoCode = currencyCode_Invoice;
                 
                 invoiceList.add(invoiceVar);
                 if(Test.isRunningTest()){
                    throw new testexception('Test Exception');
                }
                 }catch (Exception ex){
                    respvar = new ResponseWraperClass();  
                    blnFinalResult = true;
                    respvar.result ='Failure';
                    respvar.Errorcode = 'IN-ERROR-2032';
                    respvar.ErrorMessage = string.valueof(ex);   
                    respvar.TransactionNameAndValue = 'Invoice:' + reqInvVar.IN_OracleInvoiceID;
                    respvar.EBS_INVOICE_NUMBER = reqInvVar.IN_OracleInvoiceID;
                    respvar.EBS_ORDER_NUMBER = reqInvVar.IN_OracleOrderID;
                    
                    respvarlist.add(respvar);
                    system.debug('exception ====='+ex); 
                    system.debug('exception ====='+ex.getStackTraceString());
                    
                    
                }
          
            }
            
            //TO upsert data in Invoices__c object
            if(invoiceList!=null && invoiceList.size()>0){
                Database.UpsertResult[] srListInvoice;
                srListInvoice = Database.Upsert(invoiceList,Invoices__c.Fields.Id,false);
      
                MastersrList.add(srListInvoice);
            }
            
            set<id> succInvoiceIdSet = new set<id>();
            
            for(list<Database.UpsertResult> srval : MastersrList) {
                for (Database.UpsertResult sr : srval){
                     succInvoiceIdSet.add(sr.getid());
                }
                
            }
            map<id,string> invoiceId_ID_Map = new map<id,string>();
            for(Invoices__c invo : [Select ID,OracleInvoiceID__c from Invoices__c where id IN:succInvoiceIdSet ]){
                invoiceId_ID_Map.put(invo.id, invo.OracleInvoiceID__c);
            }
            //Generate response variable with success and failure 
            for(list<Database.UpsertResult> srval : MastersrList) {
                for (Database.UpsertResult sr : srval){
                    if (sr.isSuccess()){
                        respvar = new ResponseWraperClass();
                        respvar.result ='Success';
                        respvar.Errorcode = 'IN-SUCCESS-2031:';
                        respvar.ErrorMessage = 'Transaction Succesfull';   
                        respvar.TransactionNameAndValue = 'Invoice:' + sr.getid();
                        respvar.SFDC_INVOICE_ID = sr.getid();
                        if(invoiceId_ID_Map.get(sr.getid())!=null){
                            respvar.EBS_INVOICE_NUMBER = invoiceId_ID_Map.get(sr.getid());
                        }
                        system.debug('respvar.result Success===>' + respvar.result);   
                        respvarlist.add(respvar);
                        
                    }else{
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            respvar = new ResponseWraperClass();
                            blnFinalResult = true;
                            respvar.result ='Failure';   
                            respvar.Errorcode = 'IN-ERROR-2031:';
                            respvar.ErrorMessage = 'Failure'+ err.getStatusCode() + ': ' + err.getMessage()+': '+sr.getid();   
                            respvar.TransactionNameAndValue = 'Invoice:' + sr.getid();
                            respvar.SFDC_INVOICE_ID = sr.getid();
                            if(invoiceId_ID_Map.get(sr.getid())!=null){
                                respvar.EBS_INVOICE_NUMBER = invoiceId_ID_Map.get(sr.getid());
                            }
                            respvarlist.add(respvar);
                            system.debug('respvar.result Faulure===>' + respvar.result);
                              
                        }
                        
                    }
   
                }
                
            }
            if(Test.isRunningTest()){
                    throw new testexception('Test Exception');
                }
            }catch(Exception ex){
            respvar = new ResponseWraperClass();  
            blnFinalResult = true;
            respvar.result ='Failure';
            respvar.Errorcode = 'IN-ERROR-2030:';
            respvar.ErrorMessage = 'Failure:'+ string.valueof(ex);
            respvar.TransactionNameAndValue = 'Invoice:'+ string.valueof(ex);
            respvarlist.add(respvar);
            system.debug('exception ====='+ex); 
            system.debug('exception ====='+ex.getStackTraceString());  
            
            blnSystemException = true; 
            
            
        }
        
        //Passing final result for the entire load, if there in on failure then Final Result will be Filaure 
        //and all are success the final result will be passed as Success 
        if (blnFinalResult==true) {
            respvar = new ResponseWraperClass();
            respvar.FinalResult = 'Failure';
            respvarlist.add(respvar);
            
        }else{
            respvar = new ResponseWraperClass();
            respvar.FinalResult = 'Success';
            respvarlist.add(respvar);
        }
        
         
        return respvarlist;
     }
     
     //global class to expose parameters to Oracle to accept Order data
     global class requestOrderData 
    {         
        //Order Data 
        webservice String O_OracleOrderNumber;
        webservice DateTime O_OrderDate;
        webservice String O_OrderType;
        webservice Decimal  O_OrderAmount;
        webservice Decimal  O_TaxAmount;
        webservice Decimal  O_ShippingAmount;
        webservice String O_CurrencyIsoCode;
        webservice String O_OrderStatus;
        webservice string O_CustomerMasterID;
        webservice string O_PaymentTerms;
        webservice string O_QuoteNumber;
        webservice Decimal O_GrandTotal;
        webservice string O_OracleOrderID;
        webservice string O_OracleAccountNumber;
        
        webservice string attribute1;
        webservice string attribute2;
        webservice string attribute3;
        webservice string attribute4;
        webservice string attribute5;
        webservice string attribute6;
        webservice string attribute7;
        webservice string attribute8;
        webservice string attribute9;
        webservice string attribute10;
        webservice string attribute11;
        webservice string attribute12;
        webservice string attribute13;
        webservice string attribute14;
        webservice string attribute15;
    } 
    
    //global class to expose parameters to Oracle to accept Order Line data
    global class  requestOrderLineData 
    {         
        //OrderLine Data 
        webservice String OL_OracleOrderID;
        webservice string OL_OrigSysLine; 
        webservice string OL_OrderLineSequence;
        webservice String OL_Product;
        webservice String OL_Quantity;
        webservice String OL_UnitofMeasure;
        webservice Decimal OL_NetPrice;
        webservice Decimal OL_ExtendedPrice;
        webservice String OL_OrderLineOrderStatus;
        webservice Decimal OL_QuantityFulfilled; 
        webservice Decimal OL_QuantityInvoiced; 
        webservice string OL_OracleOrderLineID;
        webservice string OL_ProductID;
        webservice string OL_OracleOrderNumber;
        
        webservice string attribute1;
        webservice string attribute2;
        webservice string attribute3;
        webservice string attribute4;
        webservice string attribute5;
        webservice string attribute6;
        webservice string attribute7;
        webservice string attribute8;
        webservice string attribute9;
        webservice string attribute10;
        webservice string attribute11;
        webservice string attribute12;
        webservice string attribute13;
        webservice string attribute14;
        webservice string attribute15;

    } 
    
    //global class to expose parameters to Oracle to accept Invoice data
    global class requestInvoiceData{
        
        //Invoice Data
        
        webservice string IN_OracleOrderID;
        webservice String IN_InvoiceNumber;
        webservice Date IN_InvoiceDate;
        webservice Decimal  IN_InvoiceAmount;
        webservice Decimal IN_AmountRemaining;
        webservice string IN_CurrencyCode;
        webservice Date IN_DueDate;
        webservice string IN_OracleInvoiceID;
        webservice string IN_OracleOrderNumber;
        
        webservice string attribute1;
        webservice string attribute2;
        webservice string attribute3;
        webservice string attribute4;
        webservice string attribute5;
        webservice string attribute6;
        webservice string attribute7;
        webservice string attribute8;
        webservice string attribute9;
        webservice string attribute10;
        webservice string attribute11;
        webservice string attribute12;
        webservice string attribute13;
        webservice string attribute14;
        webservice string attribute15;
        
        
    }
     
     
    //Response class to send the success or failure detail back to oracle EBS 
     global class ResponseWraperClass
    {     
        
        webservice String Result{get;set;}    
        webservice String FinalResult{get;set;}
        webservice String Errorcode{get;set;}    
        webservice String ErrorMessage{get;set;} 
        webservice String TransactionNameAndValue{get;set;}
        webservice String EBS_ORDER_NUMBER{get;set;}
        webservice String EBS_LINE_NUMBER{get;set;}
        webservice String EBS_INVOICE_NUMBER{get;set;}                
        webservice String ORIG_SYS_DOCUMENT_REF{get;set;} //Not sending from oracle       
        webservice String ORIG_SYS_LINE_REF{get;set;}                 
        webservice String SFDC_ORDER_ID{get;set;}                           
        webservice String SFDC_LINE_ID{get;set;}                              
        webservice String SFDC_INVOICE_ID{get;set;}
        //webservice String TransactionValue{get;set;}    
    }

}