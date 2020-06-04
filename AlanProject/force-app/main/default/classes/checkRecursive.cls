public Class checkRecursive{
private static boolean firstRun = true;
private static boolean SyncfirstRun = true;
private static boolean ToLable= true;
Private Static Boolean Validate = True;

    public static boolean isFirstRun() {
        return firstRun;
    }
    public static void setFirstRunFalse(){
        firstRun = false;
    }
    public static boolean SyncisFirstRun() {
        return SyncfirstRun;
    }
    public static void setSyncFirstRunFalse(){
        SyncfirstRun = false;
    }
      public static boolean isToLable() {
        return ToLable;
    }
    public static void setToLable(){
        ToLable = false;
    }
    
    public static boolean isValidate() {
        return Validate;
    }
    public static void setValidate(){
        Validate = false;
    }
}