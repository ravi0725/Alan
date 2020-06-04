/*****************************************************************************************
    Name        : CalculateDuration
    Desc        : Calculates the No of Months and no of Days for Given Dates
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo             25/05/2016        Created
Suresh Babu Murugan    28/02/2019        MODIFIED: to fix month calculation for Feb month
******************************************************************************************/
public class CalculateDuration {

    public Static String MonthsandDays(Date ServiceStartDate,Date ServiceEndDate) {
        String FinalResult;
        Integer FinalMonth = 0,FinalDays = 0;
        Date startDate = ServiceStartDate;
        Date endDate = ServiceEndDate;
        enddate = enddate + 1;
        Date ActualEndDate = enddate - 1;

        decimal n = 0.0;

        if( startDate.month()== endDate.month() && startDate.year()== endDate.year() ){
            n =  decimal.valueOf((startDate.daysBetween(endDate) + 1 ))
                 / decimal.valueOf(date.daysInMonth(startDate.year(),startDate.month()));
        }
        else if(startDate.day()== 1){
            Integer monthsBetween = startDate.monthsBetween(endDate)-1;

            decimal firstMonth = decimal.valueOf(date.daysInMonth(startDate.year() , startDate.month()) - startDate.day())
                                 / decimal.valueOf(date.daysInMonth(startDate.year(), startDate.month()));

            decimal lastMonth =  decimal.valueOf(endDate.toStartOfMonth().daysBetween(endDate))
                                 / decimal.valueOf(date.daysInMonth(endDate.year(), endDate.month()));

            system.debug('^^^^^^^^^^'+monthsBetween);
            system.debug('^^^^^^^^^^'+firstMonth);
            system.debug('^^^^^^^^^^'+lastMonth);
            n =  firstMonth + monthsBetween + lastMonth;


            system.debug('>>>>>>No of Months>>>>>'+n);
            system.debug('>>>>>>Integer.valueof(n)>>>>>'+Integer.valueof(n));
            startDate = startDate;
            startDate = startDate.addmonths(Integer.valueof(n));
            system.debug('>>>>>>New Start Date>>>>>'+startDate);
            Integer NoDays = startDate.daysbetween(enddate);
            system.debug('>>>>'+enddate.day());
            system.debug('>>>>'+date.daysInMonth(enddate.year(),enddate.month()));

            if(ActualEndDate.day() == date.daysInMonth(ActualEndDate.year(),ActualEndDate.month())){
                n = n + 1;
                NoDays = 0;
            }
            system.debug('>>>>>>No of Months>>>>>'+n);
            system.debug('>>>>>>No of NoDays>>>>>'+NoDays);
            FinalMonth = Integer.valueof(n);
            FinalDays = NoDays;
        }
        else if(startdate.day() == Date.DaysinMonth(Startdate.year(),startdate.month())){
            Integer monthsBetween = startDate.monthsBetween(endDate) - 1;

            decimal firstMonth = decimal.valueOf(date.daysInMonth(startDate.year() , startDate.month()) - startDate.day() + 1)
                                 / decimal.valueOf(date.daysInMonth(startDate.year(), startDate.month()));

            decimal lastMonth =  decimal.valueOf(endDate.toStartOfMonth().daysBetween(endDate) + 1)
                                 / decimal.valueOf(date.daysInMonth(endDate.year(), endDate.month()));

            system.debug('^^^^^^^^^^'+monthsBetween);
            system.debug('^^^^^^^^^^'+firstMonth);
            system.debug('^^^^^^^^^^'+lastMonth);
            n =  firstMonth + monthsBetween + lastMonth;



            system.debug('>>>>>>Integer.valueof(n)>>>>>'+Integer.valueof(n));
            startDate = startDate.addmonths(Integer.valueof(n));
            Date TempStartDate = date.newinstance(startDate.year(),startDate.month(),Date.DaysinMonth(startDate.Year(),StartDate.month()));
            if(startDate.day() != Date.DaysInmonth(startDate.year(),Startdate.month()) - 1){
                startdate = TempStartDate - 1;
            }
            system.debug('>>>>>>New Start Date>>>>>'+startDate);
            Integer NoDays = startDate.daysbetween(enddate - 1);

            system.debug('>>>>>>No of Months>>>>>'+n);
            system.debug('>>>>>>No of NoDays>>>>>'+NoDays);
            FinalMonth = Integer.valueof(n);
            FinalDays = NoDays;
        }


        else{
            Integer monthsBetween = startDate.monthsBetween(endDate) - 1;

            decimal firstMonth = decimal.valueOf(date.daysInMonth(startDate.year() , startDate.month())-startDate.day() + 1)
                                 / decimal.valueOf(date.daysInMonth(startDate.year(), startDate.month()));

            decimal lastMonth =  decimal.valueOf(endDate.toStartOfMonth().daysBetween(endDate) + 1)
                                 / decimal.valueOf(date.daysInMonth(endDate.year(), endDate.month()));

            system.debug('^^^^^^^^^^'+monthsBetween);
            system.debug('^^^^^^^^^^'+firstMonth);
            system.debug('^^^^^^^^^^'+lastMonth);
            n =  firstMonth + monthsBetween + lastMonth;
            system.debug('>>>>>>Integer.valueof(n)>>>>>'+Integer.valueof(n));
            startDate = startDate - 1;
            startDate = startDate.addmonths(Integer.valueof(n));
            system.debug('>>>>>>New Start Date>>>>>'+startDate);
            if(startdate.day() == Date.DaysInMonth(Startdate.year(),Startdate.month()))
                startdate = startdate - 1;
            Integer NoDays = startDate.daysbetween(enddate - 1);
            system.debug('>>>>>>No of Months>>>>>'+n);
            system.debug('>>>>>>No of NoDays>>>>>'+NoDays);
            FinalMonth = Integer.valueof(n);
            FinalDays = NoDays;
        }

        if(FinalDays >= 30){
            FinalDays = 0;
            FinalMonth = FinalMonth + 1;
        }
        FinalResult = String.valueof(FinalMonth)  + ':' + String.valueof(FinalDays);

        system.debug('I am the Last String Result Value'+FinalResult);
        return FinalResult;
    }
}