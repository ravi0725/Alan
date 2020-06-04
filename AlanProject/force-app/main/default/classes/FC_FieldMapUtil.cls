public class FC_FieldMapUtil {
    public static final String CURRENT_USERNAME_SYSTEM_VARIABLE = '$CurrentUserName';
    public static final String CURRENT_DATE_SYSTEM_VARIABLE = '$CurrentDate';
    public static final String CURRENT_DATETIME_SYSTEM_VARIABLE = '$CurrentDateTime';
    
    public static String getDefaultValue(String defaultString) {
        defaultString = defaultString == null ? '' : defaultString;
        String textNodeValue = '';
        if (defaultString.equalsIgnoreCase(CURRENT_USERNAME_SYSTEM_VARIABLE)) {
            textNodeValue = UserInfo.getUserName();
        } else if (defaultString.equalsIgnoreCase(CURRENT_DATETIME_SYSTEM_VARIABLE)) {
            textNodeValue = String.valueOf(Datetime.now());
        } else if (defaultString.equalsIgnoreCase(CURRENT_DATE_SYSTEM_VARIABLE)) {
            textNodeValue = String.valueOf(Date.today());
        } else {
            textNodeValue = defaultString;
        }
        return textNodeValue;
    }
}