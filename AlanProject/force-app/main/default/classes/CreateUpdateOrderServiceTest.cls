@isTest
private class CreateUpdateOrderServiceTest{
    
    private static List<CreateUpdateOrderService.requestOrderData> reqOrderList = new List<CreateUpdateOrderService.requestOrderData>();
    private static List<CreateUpdateOrderService.requestOrderLineData> reqOrderLineList = new List<CreateUpdateOrderService.requestOrderLineData>();
    private static List<CreateUpdateOrderService.requestInvoiceData> reqInvoiceList = new List<CreateUpdateOrderService.requestInvoiceData>();
    private static Country_Region_Mapping__c cust;
    private static Geospatial_Country_Region_Mapping__c custRegMap ;
    private static UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
    private static Profile profile = [Select Id from Profile where name = 'System Administrator'];
    private static User portalAccountOwner ;
    private static Id recordType = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Lead (Customer) Record Type').getRecordTypeId();
    private static Account acct;
    private static Id acctRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account (Pending Customer) Record Type').getRecordTypeId();
    private static Order__c order ;
    private static Order_Line_Item__c orderLine;
    private static Apttus_Proposal__Proposal__c appProp ;
    private static Product2 prod;
    private static Invoices__c  inv;
    private static String acctId;
    private static String orderId ;
    
    static void setUpData(Boolean flag){
        
        cust = new Country_Region_Mapping__c(name='India',Region__c='India');
        insert cust;
        
        custRegMap = new Geospatial_Country_Region_Mapping__c(name='India',Region__c='India');
        insert custRegMap;
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
                
        acct = new Account(Name = 'Test Assign Case Account',RecordTypeId = acctRecTypeId,Account_Status__c = 'Pending',Requested_Account_Record_Type__c = 'Customer',
            BillingCountry = 'India',BillingCity = 'Pune',BillingStreet = 'A-202',FCH_Party_ID__c='300000010184140');
        insert acct;
        
        prod = new Product2();
        prod.IsActive = true;
        prod.Name = 'ABC';
        prod.ProductCode = 'T1';
        prod.Certificate__c = 'C1';
        insert prod;
        
        order = new Order__c(Account__c=acct.Id,Customer_Master_ID__c='300000010184140',Order_Amount__c=8050.0,
                    Order_Date__c=System.now(),OracleOrderID__c='12345',Order_Type__c='TIBV FR Direct Sale',Oracle_Order_Number__c='111',Tax_Amount__c=1610.0,
                    Shipping_Amount__c=0.0,CurrencyIsoCode='EUR',Order_Status__c='ENTERED',Payment_Terms__c='30 NET');
        insert order;   
        
        if(flag){
            orderId =  order.Id;
        }else{
            orderId = null;
        }
        
        orderLine = new Order_Line_Item__c(Order__c=orderId,OwnerId=thisUser.id ,Oracle_Line_ID__c='100',Order_Line_Sequence__c='1.1',Product__c=prod.Id,
                    Quantity__c='2',Unit_of_Measure__c='1',Net_Price__c=200.0,Extended_Price__c=50.0,Quantity_Fulfilled__c='2',Quantity_Invoiced__c='1',
                    Order_Line_Order_Status__c='AWAITING SHIPPING');
        insert orderLine;   
            
    
        appProp = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c=acct.id);
        insert appProp;
        
        inv = new Invoices__c(Account__c=acct.Id,Order__c=order.Id,Invoice_Number__c='100');
        insert inv;
        
        CreateUpdateOrderService.requestOrderData reqOrder = new CreateUpdateOrderService.requestOrderData();
        reqOrder.O_OracleOrderNumber = order.Oracle_Order_Number__c;
        reqOrder.O_OrderDate = order.Order_Date__c;
        reqOrder.O_OrderType = order.Order_Type__c;
        reqOrder.O_OrderAmount =order.Order_Amount__c;
        reqOrder.O_TaxAmount=order.Tax_Amount__c;
        reqOrder.O_ShippingAmount=order.Shipping_Amount__c;
        reqOrder.O_CurrencyIsoCode=order.CurrencyIsoCode;
        reqOrder.O_OrderStatus =order.Order_Status__c;
        reqOrder.O_CustomerMasterID=order.Customer_Master_ID__c;
        reqOrder.O_PaymentTerms =order.Payment_Terms__c;
        reqOrder.O_QuoteNumber = appProp.name;
        reqOrder.O_GrandTotal=100;
        reqOrder.attribute1 ='300000010184140';
        reqOrder.attribute2 ='300000010184140';
        reqOrder.attribute3 ='300000010184140';
        
    
        reqOrderList.add(reqOrder);
        
        CreateUpdateOrderService.requestOrderLineData reqOrderLine = new CreateUpdateOrderService.requestOrderLineData();
        reqOrderLine.OL_OracleOrderNumber = order.Oracle_Order_Number__c;
        reqOrderLine.OL_OrigSysLine =orderLine.Oracle_Line_ID__c; 
        reqOrderLine.OL_OrderLineSequence =orderLine.Order_Line_Sequence__c;
        reqOrderLine.OL_Product='T1';
        reqOrderLine.OL_Quantity=orderLine.Quantity__c;
        reqOrderLine.OL_UnitofMeasure=orderLine.Unit_of_Measure__c;
        reqOrderLine.OL_NetPrice=orderLine.Net_Price__c;
        reqOrderLine.OL_ExtendedPrice=orderLine.Extended_Price__c;
        reqOrderLine.OL_OrderLineOrderStatus=orderLine.Order_Line_Order_Status__c;
        reqOrderLine.OL_QuantityFulfilled=Integer.valueOf(orderLine.Quantity_Fulfilled__c);
        reqOrderLine.OL_QuantityInvoiced=Integer.valueOf(orderLine.Quantity_Invoiced__c);
        reqOrderLine.attribute1 ='300000010184140';
        reqOrderLine.attribute2 ='300000010184140';
        reqOrderLine.attribute3 ='300000010184140';
        reqOrderLine.attribute5 ='300000010184140';
        reqOrderLine.OL_OracleOrderID ='12345';
        
        reqOrderLineList.add(reqOrderLine);
        
        CreateUpdateOrderService.requestInvoiceData reqInvoice = new CreateUpdateOrderService.requestInvoiceData();
        reqInvoice.IN_OracleOrderNumber=order.Oracle_Order_Number__c;
        reqInvoice.IN_InvoiceNumber=inv.Invoice_Number__c;
        reqInvoice.IN_InvoiceDate = System.today();
        reqInvoice.IN_InvoiceAmount=0.0;
        reqInvoice.IN_AmountRemaining=0.0;
        reqInvoice.IN_CurrencyCode='EUR';
        reqInvoice.IN_DueDate = System.today();
        reqInvoice.attribute1 ='300000010184140';
        reqInvoice.attribute2 ='300000010184140';
        reqInvoice.attribute3 ='300000010184140';
        
        reqInvoiceList.add(reqInvoice);
            
    }

    
    private static testmethod void testCreateOrderService(){
        
        setUpData(true);
        Test.startTest();           
            List<CreateUpdateOrderService.ResponseWraperClass> resList = CreateUpdateOrderService.CreateOrderService(reqOrderList);
            System.assertEquals(resList[0].result,'Failure');
        Test.stopTest();
        
    }
    
    /*private static testmethod void testCreateOrderServiceExp(){
        
        setUpData(false);
        Test.startTest();
            List<CreateUpdateOrderService.ResponseWraperClass> resList = CreateUpdateOrderService.CreateOrderService(reqOrderList);
            System.assertEquals(resList[0].result,'Failure');
        Test.stopTest();
        
    }*/
    
    private static testmethod void testCreateOrderLineService(){
        
        setUpData(true);
        Test.startTest();           
            List<CreateUpdateOrderService.ResponseWraperClass> resList = CreateUpdateOrderService.CreateOrderLineService(reqOrderLineList);
            System.assertEquals(resList[0].result,'Failure');
        Test.stopTest();
        
    }
    
    private static testmethod void testCreateOrderLineServiceExp(){
        
        setUpData(false);
        Test.startTest();           
            List<CreateUpdateOrderService.ResponseWraperClass> resList = CreateUpdateOrderService.CreateOrderLineService(reqOrderLineList);
            //System.assertEquals(resList[0].result,'Failure');
        Test.stopTest();
        
    }
    
    private static testmethod void testCreateInvoiceService(){
        
        setUpData(true);
        Test.startTest();           
            List<CreateUpdateOrderService.ResponseWraperClass> resList = CreateUpdateOrderService.CreateInvoiceService(reqInvoiceList);
            System.assertEquals(resList[0].result,'Failure');
        Test.stopTest();
        
    }
    
    private static testmethod void testCreateInvoiceServiceExp(){
        
        setUpData(false);
        Test.startTest();           
            List<CreateUpdateOrderService.ResponseWraperClass> resList = CreateUpdateOrderService.CreateInvoiceService(reqInvoiceList);
            //System.assertEquals(resList[0].result,'Failure');
        Test.stopTest();
        
    }
}