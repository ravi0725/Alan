public class FC_HttpLogger {
    public static HttpRequest request { get; private set; }
    public static HttpResponse response { get; private set; }
    
    public static void log(HttpRequest req, HttpResponse resp) {
        request = req;
        response = resp;
    }
}