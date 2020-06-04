public class FC_FusionException extends Exception {
    private HTTPResponse resp;
    private Integer statusCode;
    
    public FC_FusionException(HTTPResponse resp) {
        this.resp = resp;
        statusCode = resp.getStatusCode();
    }
    
    public override String getMessage() {

        return 'Fusion returned the HTTP status code of ' + statusCode;

    }
}