public class SwissRounding{
    public static Decimal ApplySwissRounding(decimal originalVal){
        decimal roundedVal = originalVal;
        if(originalVal != null){
            //Extended_Price_Disp_Rounding__c
            List<String> num= new List<String>();
            String ron;
            num= String.valueof(originalVal).split('\\.');
            if(num.size()==2){
                if(num[1].endsWith('0') || num[1].endsWith('1') ||num[1].endsWith('2') ){
                    ron= '.' + num[1].subString(0,1) + '0';
                    String FinalStr = num[0] + ron;
                    roundedVal = Decimal.valueof(FinalStr);
                }else if(num[1].endsWith('3') || num[1].endsWith('4') ||num[1].endsWith('5') || num[1].endsWith('6') ||num[1].endsWith('7')){
                    ron= '.' + num[1].subString(0,1) + '5';
                    String FinalStr = num[0] + ron;
                    roundedVal = Decimal.valueof(FinalStr);
                }else if(num[1].endsWith('8') || num[1].endsWith('9') ){
                    roundedVal = originalVal + (num[1].endsWith('8') ? 0.02 : 0.01);
                }
            }else{
                roundedVal = originalVal;
            }
        }
        return roundedVal;
    }
}