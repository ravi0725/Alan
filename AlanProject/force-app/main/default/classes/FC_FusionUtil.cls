public class FC_FusionUtil {
    public static String getFusionDate(Date d) {
        // DateTime dt = (DateTime) d;
        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
        return dt.format('Y-MM-dd');
    }
}