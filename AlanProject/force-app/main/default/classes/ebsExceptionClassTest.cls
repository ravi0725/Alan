@isTest
private class ebsExceptionClassTest{

    private static List<ebsExceptionWrapper.clsMessageTransaction> resWrapTrans = new List<ebsExceptionWrapper.clsMessageTransaction>();
    private static List<ebsExceptionWrapper.clsErrorCode> resWrapErrCode = new List<ebsExceptionWrapper.clsErrorCode>();
    private static List<ebsExceptionWrapper> res = new List<ebsExceptionWrapper>();
    
    static void setUpData(){
        
        ebsExceptionWrapper.clsMessageTransaction resWrapTransObj = new ebsExceptionWrapper.clsMessageTransaction();
        resWrapTransObj.name = 'Test Msg';
        resWrapTransObj.value = 'Test Value';
        resWrapTrans.add(resWrapTransObj);
        
        ebsExceptionWrapper.clsErrorCode resWrapErrCodeObj = new ebsExceptionWrapper.clsErrorCode();
        List<ebsExceptionWrapper.clsTransactionData> transDataList = new List<ebsExceptionWrapper.clsTransactionData>();
        
        ebsExceptionWrapper.clsTransactionData transDataObj = new ebsExceptionWrapper.clsTransactionData();
        transDataObj.name = 'Test Trans Msg';
        transDataObj.value = 'Test Trans Value';
        transDataList.add(transDataObj);
        
        resWrapErrCodeObj.Error_Code = '100E';
        resWrapErrCodeObj.Error_Message = 'Error in Processsing';
        resWrapErrCodeObj.Error_Trace = 'Err Track';
        //resWrapErrCodeObj.ec_Error_Type = 'Exception';
        //resWrapErrCodeObj.ec_Error_Resolution_Status = 'Warnning';
        resWrapErrCodeObj.TransactionDataList = transDataList;
        resWrapErrCode.add(resWrapErrCodeObj);
        
        ebsExceptionWrapper wrapObj = new ebsExceptionWrapper();
        wrapObj.MessageTransactionList = resWrapTrans ;
        wrapObj.ErrorCodeList = resWrapErrCode ;
        res.add(wrapObj);
        
    }   
    
    private static testmethod void testebsExceptionClass(){
        
            setUpData();
            Test.startTest();
                ebsExceptionClass.ebsExceptionCall(res);                
            Test.stopTest();
    } 
    

}