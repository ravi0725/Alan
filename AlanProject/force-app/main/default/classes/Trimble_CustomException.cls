public class Trimble_CustomException extends Exception {
    private String errorMsg;
  
    public Trimble_CustomException(String message, boolean flag){
        errorMsg = message;
    }
  
    public override String getMessage() { 
        return errorMsg; 
    }
}