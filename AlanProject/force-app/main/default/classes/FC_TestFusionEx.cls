@isTest
private class FC_TestFusionEx {
    static testMethod void testFusionEx() {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);
        FC_FusionException ex = new FC_FusionException(resp);
        System.assertEquals('Fusion returned the HTTP status code of 200', ex.getMessage());
        
    }
    
}