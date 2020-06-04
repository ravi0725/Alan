/*****************************************************************************************
Name    : ValidateEndDate
Desc    : Used to validate End Date of Each Line Item


Modification Log : 
---------------------------------------------------------------------------
Developer              Date            Description
---------------------------------------------------------------------------
Prince Leo           28/07/2015          Created
******************************************************************************************/
public class ValidateEndDate{
    Public date MaxDate {get;set;}
    Public Decimal SplitYear {get;set;}
    public Boolean Check(decimal Duration, String AccountId, String Productline, String PrId){
    Boolean ResultFlag = False;
    List<Asset>AssetList = new List<Asset>();
    
    AssetList = [ Select id,createddate,LastModifieddate,(Select id,Name,EndDate from Entitlements e order by Enddate DESC) from Asset where Accountid=:AccountId and Product2id=:PrId and Product2.Product_Line__c =:Productline Order By LastModifiedDate DESC];
   
   Date Largerdate = System.today();
   
    for(Asset Ast: AssetList)
    {
      for(Entitlement Et : Ast.Entitlements)
      {
       System.debug('>>>>>>>>>>>>>>Entitlements>>>>>>>>>>'+Et.Enddate);
       if(Et.Enddate > Largerdate)
        Largerdate = Et.Enddate;
      }
    }
   System.debug('>>>>>>>>>>>>>>Largerdate>>>>>>>>>>'+Largerdate);
   System.debug('>>>>>>>>>>>>>>MaximumLockDuration>>>>>>>>>>'+system.today().adddays(Integer.valueof(Duration)*365));
   Decimal Yrs;
   Yrs = Decimal.valueof(system.today().monthsbetween(Largerdate)).divide(12,2);
   Yrs = Yrs.round(System.RoundingMode.UP);
    System.debug('>>>>>>>>>>>>>>Yrs >>>>>>>>>>'+Yrs);
    System.debug('>>>>>>>>>>>>>>Yrs >>>>>>>>>>'+(system.today().monthsbetween(Largerdate)));
 /*  if(Largerdate < system.today().adddays(Integer.valueof(Duration)*365) && Largerdate!= System.today())
   
   {
   ResultFlag = True;
   MaxDate = Largerdate;
   }
   else
   {
   ResultFlag = False;
   }
    System.debug('>>>>>>>>>>>>>>ResultFlag>>>>>>>>>>'+ResultFlag);
   return ResultFlag;*/
   if(Yrs!=Duration && AssetList.size()>0)
   {
   ResultFlag = True;
   MaxDate = Largerdate;
   SplitYear = Yrs;
   }
   return ResultFlag;
    }
    
     public Boolean CheckSAAS(decimal Duration, String AccountId, String Productline, String BusinessArea){
    Boolean ResultFlag = False;
    List<Asset>AssetList = new List<Asset>();
    
    AssetList = [ Select id,createddate,LastModifieddate,(Select id,Name,EndDate from Entitlements e order by Enddate DESC) from Asset where Accountid=:AccountId and Product2.Product_Line__c =:Productline and Product2.Business_Area__c =:BusinessArea Order By LastModifiedDate DESC];
   
   Date Largerdate = System.today();
   
    for(Asset Ast: AssetList)
    {
      for(Entitlement Et : Ast.Entitlements)
      {
       System.debug('>>>>>>>>>>>>>>Entitlements>>>>>>>>>>'+Et.Enddate);
       if(Et.Enddate > Largerdate)
        Largerdate = Et.Enddate;
      }
    }
   System.debug('>>>>>>>>>>>>>>Largerdate>>>>>>>>>>'+Largerdate);
   System.debug('>>>>>>>>>>>>>>MaximumLockDuration>>>>>>>>>>'+system.today().adddays(Integer.valueof(Duration)*365));
   Decimal Yrs;
   Yrs = Decimal.valueof(system.today().monthsbetween(Largerdate)).divide(12,2);
   Yrs = Yrs.round(System.RoundingMode.UP);
    System.debug('>>>>>>>>>>>>>>Yrs >>>>>>>>>>'+Yrs);
    System.debug('>>>>>>>>>>>>>>Yrs >>>>>>>>>>'+(system.today().monthsbetween(Largerdate)));
 /*  if(Largerdate < system.today().adddays(Integer.valueof(Duration)*365) && Largerdate!= System.today())
   
   {
   ResultFlag = True;
   MaxDate = Largerdate;
   }
   else
   {
   ResultFlag = False;
   }
    System.debug('>>>>>>>>>>>>>>ResultFlag>>>>>>>>>>'+ResultFlag);
   return ResultFlag;*/
   if(Yrs!=Duration && AssetList.size()>0)
   {
   ResultFlag = True;
   MaxDate = Largerdate;
   SplitYear = Yrs;
   }
   return ResultFlag;
    }
    }