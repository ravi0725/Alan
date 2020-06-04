@isTest
private class CalculateDurationTest{
 private static testmethod void TestCase1(){
 Date Startdate = date.newinstance(2016,01,31);
 Date Enddate = date.newinstance(2016,05,30);
 String Result;
 Result = CalculateDuration.MonthsandDays(Startdate ,Enddate);
 }
 private static testmethod void TestCase2(){
 Date Startdate = date.newinstance(2016,01,15);
 Date Enddate = date.newinstance(2016,05,30);
 String Result;
 Result = CalculateDuration.MonthsandDays(Startdate ,Enddate);
 }
 private static testmethod void TestCase3(){
 Date Startdate = date.newinstance(2016,01,01);
 Date Enddate = date.newinstance(2016,05,30);
 String Result;
 Result = CalculateDuration.MonthsandDays(Startdate ,Enddate);
 }
}