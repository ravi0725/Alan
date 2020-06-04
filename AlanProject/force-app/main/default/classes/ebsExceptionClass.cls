/*****************************************************************************************
    Name    : ebsExceptionClass 
    Desc    : Used to invoke EBS service to for exception handling 
              
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       03/28/2014          Created
******************************************************************************************/
public class ebsExceptionClass{
    
    //public static void ebsExceptionCall(string QuoId, string exMessage, string exStackTrace, string ErrType, string ResStatus){
    //public static void ebsExceptionCall(list<ebsExceptionWrapper.clsMessageTransaction> resWrapMsgTranList,list<ebsExceptionWrapper.clsErrorCode> resWrapErrCodeList,List<ebsExceptionWrapper.clsTransactionData> resWrapTranData ){
    
    public static void ebsExceptionCall(list<ebsExceptionWrapper> resWrapList){
        try{
            
            string errorType;
           
            trimblecorpComTnvreceiveexternalerrors.MessageTransactions[] mtArr = new trimblecorpComTnvreceiveexternalerrors.MessageTransactions[]{};
            trimblecorpComTnvreceiveexternalerrors.MessageTransactions  mt = new trimblecorpComTnvreceiveexternalerrors.MessageTransactions();
            trimblecorpComTnvreceiveexternalerrors.MessageTransactionData mtd;
            
            
            
            trimblecorpComTnvreceiveexternalerrors.Transactions[] tdArr;// = new trimblecorpComTnvreceiveexternalerrors.Transactions[]{};
            trimblecorpComTnvreceiveexternalerrors.Transactions td;// = new trimblecorpComTnvreceiveexternalerrors.Transactions();
            trimblecorpComTnvreceiveexternalerrors.TransactionData  txnd;
            
            
            
            trimblecorpComTnvreceiveexternalerrors.ErrorCodes[] erArr = new trimblecorpComTnvreceiveexternalerrors.ErrorCodes[]{};
            trimblecorpComTnvreceiveexternalerrors.ErrorCodes   er;
            
            
            
            trimblecorpComTnvreceiveexternalerrors.ErrorType et = new trimblecorpComTnvreceiveexternalerrors.ErrorType();
            
            et.Source_System ='SFDC';
            //et.Composite_Name = '';
            et.Composite_Instance_Id = '';
            et.Timestamp = string.valueof(system.now());
            integer i;
            for(ebsExceptionWrapper exw :resWrapList ){
                et.Error_Type = exw.Error_Type;
                et.Interface_Name = exw.Interface_Name;
                et.Composite_Name = exw.Composite_Name;
                for(ebsExceptionWrapper.clsMessageTransaction cmt :exw.MessageTransactionList){
                mtd = new trimblecorpComTnvreceiveexternalerrors.MessageTransactionData();
                mtd.Name = cmt.Name; 
                mtd.Value = cmt.Value;
                mt.MessageTXNData = mtd;
                
                mtArr.add(mt); 
                //break;
                } 
                
                for(ebsExceptionWrapper.clsErrorCode cec :exw.ErrorCodeList ){
                    er = new trimblecorpComTnvreceiveexternalerrors.ErrorCodes();
                    er.Error_Code = cec.Error_Code;
                    er.Error_Message = cec.Error_Message;
                    er.Error_Trace = cec.Error_Trace;
                    tdArr = new trimblecorpComTnvreceiveexternalerrors.Transactions[]{};
                    for(ebsExceptionWrapper.clsTransactionData ctd :cec.TransactionDataList ){
                        
                        txnd = new trimblecorpComTnvreceiveexternalerrors.TransactionData();
                        td= new trimblecorpComTnvreceiveexternalerrors.Transactions();
                        txnd.Name = ctd.Name;
                        txnd.Value = ctd.Value;
                        td.TXNData = txnd;
                        tdArr.add(td);
                    }
                    er.Transactions = tdArr; 
                    erArr.add(er);
                    
                }
                errorType = exw.Error_Type;//'BUSINESS ERROR/SYSTEM ERROR';
                
            }
            et.Error_Type = errorType;
            et.MessageTransaction =mtArr;
             
            et.ErrorCodes = erArr;
            
            trimblecorpComTnvreceiveexternalerrors.Response op = new trimblecorpComTnvreceiveexternalerrors.Response();
            trimblecorpComBpelTnvreceiveexternale.tnvReceiveExternalErrorsBPELProcess_pt targetportvar = new trimblecorpComBpelTnvreceiveexternale.tnvReceiveExternalErrorsBPELProcess_pt();
            op=targetportvar.process(et);
            
        }catch(Exception ex){
            system.debug('exception ====='+ex); 
            system.debug('exception ====='+ex.getStackTraceString());
        }
    }
}