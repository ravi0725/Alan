@isTest
private class FC_TestFieldMapUtil {
    static testMethod void testUtil() {
        System.assertEquals('test', FC_FieldMapUtil.getDefaultValue('test'));
        System.assertEquals(UserInfo.getUserName(), FC_FieldMapUtil.getDefaultValue('$CurrentUserName'));
        System.assertEquals(String.valueOf(Datetime.now()), FC_FieldMapUtil.getDefaultValue('$CurrentDateTime'));
        System.assertEquals(String.valueOf(Date.today()), FC_FieldMapUtil.getDefaultValue('$CurrentDate'));
    }
}