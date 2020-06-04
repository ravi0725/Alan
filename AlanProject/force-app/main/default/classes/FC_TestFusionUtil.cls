@isTest
private class FC_TestFusionUtil {
    static testMethod void testFusionUtil() {
        Date sampleDate = Date.newInstance(2010, 10, 5);
        String fusionDate = FC_FusionUtil.getFusionDate(sampleDate);
        // System.assertEquals('2010-10-04', fusionDate);
    }

}