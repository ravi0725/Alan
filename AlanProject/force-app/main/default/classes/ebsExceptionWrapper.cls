/*****************************************************************************************
    Name    : ebsExceptionWrapper 
    Desc    : Wrapper class used in ebsExceptionClass  
              
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       03/28/2014          Created
******************************************************************************************/
public class ebsExceptionWrapper{
    public string Interface_Name{get;set;}
    public string Source_System{get;set;}
    public string Composite_Name{get;set;}
    public string Composite_Instance_Id{get;set;}
    public string Timestamp{get;set;}
    public List<clsMessageTransaction> MessageTransactionList{get;set;}
    public List<clsErrorCode> ErrorCodeList{get;set;}
    public string Error_Type{get;set;}
    public string Error_Resolution_Status{get;set;}
    public string Reprocess{get;set;}
    public string Reprocess_Status{get;set;}
    
    
    public class clsMessageTransaction{
      public string name{get;set;}
      public string value{get;set;}
    }
    
    public class clsErrorCode{
      public string Error_Code{get;set;}
      public string Error_Message{get;set;}
      public string Error_Trace{get;set;}
      public List<clsTransactionData> TransactionDataList{get;set;}
            
    }
    
    public class clsTransactionData{
      public string name{get;set;}
      public string value{get;set;}
    }
    
}