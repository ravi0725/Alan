public class ConsoleCTISingleMatchCls {
	public static callData inputCallInfo {get;set;}
    
    public ConsoleCTISingleMatchCls(){
        
    }
    
    /*
     * This Page only will be initiate, ONLY One record (Contact or Account) matched.
     * 
     */
    @RemoteAction
    public static String returnAccountId(String jsonCallData){
        jsonCallData = jsonCallData.replace('id', 'ANI');
        jsonCallData = jsonCallData.replace('number', 'PHNumber');
        inputCallInfo = (callData)JSON.deserialize(jsonCallData, callData.class);
        system.debug(' inputCallInfo ==>'+inputCallInfo);
        
        // Query - Account, Lead or Contact
        inputCallInfo.PHNumber = inputCallInfo.PHNumber.replaceAll('[^\\d]', ''); // Remove all spl Chars and White spaces
        // Sub string ONLY Phone numbers
        inputCallInfo.PHNumber = inputCallInfo.PHNumber.length() > 10 ? inputCallInfo.PHNumber.substring(inputCallInfo.PHNumber.length() - 10) : inputCallInfo.PHNumber;
        return inputCallInfo.PHNumber;
    }
    
    public class callData{
        public String ANI {get;set;}
        public String isConnected {get;set;}
        public String state {get;set;}
        public String direction {get;set;}
        public String name {get;set;}
        public String interactionType {get;set;}
        public String PHNumber {get;set;}
    }
}