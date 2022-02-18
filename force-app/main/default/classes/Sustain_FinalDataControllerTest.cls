/***************************************************************************************************************
* Name - Sustain_FinalDataControllerTest
* Description - This class is used as a test class for Sustain_FinalDataController apex class.
* Author - Accenture (Bindhyachal)
* Created Date -9/19/2021
* Last Modified By & Date - Accenture, 2/16/2022
* ***************************************************************************************************************/
@isTest(SeeAllData=False)
private class Sustain_FinalDataControllerTest {
    @testSetup 
    static void setup() {
        Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
        insert obj;
        Data_Load_Request__c dLReq = Sustain_TestDataFactory.createDataLoadRequest();
        insert dLReq;
        Migration_Status__c ms = new Migration_Status__c();
        ms.Current_Migration_Stage__c   = 'Org Data Scan Output';             
        ms.Ready_To_Launch__c = true;
        insert ms;
        
    }
    
    static testmethod void getDataMappingDetailsTest() {
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        Sustain_FinalDataController.mainWrapper obj;
        Data_Load_Request__c dLReq =[Select id,Name,End_Date_Time__c,Status__c,Data_Load_Type__c,LastModifiedDate from Data_Load_Request__c];
        Sustain_Report_Object__mdt repObj= new Sustain_Report_Object__mdt();
        repObj.Source_Object_Name__c='sustain_app__Contact__c';
        repObj.Report_Developer_Name__c='Asset_Contacts_YUl';
        System.runAs(u1){
            test.startTest();
            obj = Sustain_FinalDataController.getDataMappingDetails() ;
            test.stopTest();
        }
        system.assertEquals(true, obj != null);
    }
    static testmethod void updateMigrationStatusTest() {
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        boolean stepValue;
        System.runAs(u1){
            test.startTest();
            stepValue = Sustain_FinalDataController.updateMigrationStatus('step1');
            test.stopTest();
        }
        system.assertEquals(true, stepValue);
        
    }
    
    static testmethod void getLatestDataLoadTest() {
        list<string> lst = new list<string> ();
        lst.add('Object_Mappings__c');
        Data_Load_Request__c totalRcdCount;
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        boolean stepValue;
        System.runAs(u1){
            test.startTest();
            totalRcdCount = Sustain_FinalDataController.getLatestDataLoad();
            test.stopTest();
        }
        system.assertEquals(true, totalRcdCount !=null);        
    }    
    
    static testmethod void startFinalDataLoadTest() {
        Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
        obj.Source_Object__c = 'sustain_app__ProcurementDataset__c';
        obj.Source_Record_Type__c = 'Master';       
        obj.Target_Object__c = 'Scope3PcmtSummary';
        obj.Target_Record_Type__c = 'Master';
        obj.Status__c = 'Not Started';
        obj.Object_Type__c = 'standard';
        obj.Sequence_Number__c = 38;
        obj.Batch_Size__c = 500;
        insert obj;
        list<Field_Mappings__c> lst = new  list<Field_Mappings__c>();
        Field_Mappings__c objF = Sustain_TestDataFactory.createFieldMapping();
        objF.Calculated__c = false;
        objF.New_Field__c = true;
        objF.Object_Mapping__c = obj.id;
        objF.Source_Field__c = 'Name';
        objF.Source_Field_Type__c = 'Text(80)';
        objF.Target_Field__c = 'Name';
        objF.Target_Field_Type__c = 'Text(255)';
        objF.Mapping_Included__c = true;
        objF.Calculated__c = false;
        lst.add(objF);
        Field_Mappings__c objF1 = Sustain_TestDataFactory.createFieldMapping();
        objF1.Calculated__c = false;
        objF1.New_Field__c = true;
        objF1.Object_Mapping__c = obj.id;
        objF1.Source_Field__c = 'sustain_app__CalendarYear__c';
        objF1.Source_Field_Type__c = 'Picklist';
        objF1.Target_Field__c = 'CalendarYear';
        objF1.Target_Field_Type__c = 'Picklist';
        objF1.Mapping_Included__c = true;
        objF1.Calculated__c = false;
        lst.add(objF1);
        Field_Mappings__c objF2 = Sustain_TestDataFactory.createFieldMapping();
        objF2.Calculated__c = false;
        objF2.New_Field__c = true;
        objF2.Object_Mapping__c = obj.id;
        objF2.Source_Field__c = 'sustain_app__CarbonFootprint__c';
        objF2.Source_Field_Type__c = 'Lookup(Carbon Footprint)';
        objF2.Target_Field__c = 'Scope3CrbnFtprntId';
        objF2.Target_Field_Type__c = 'Lookup(Scope 3 Carbon Footprint)';
        objF2.Mapping_Included__c = true;
        objF2.Calculated__c = false;
        lst.add(objF2);
        Field_Mappings__c objF3 = Sustain_TestDataFactory.createFieldMapping();
        objF3.Calculated__c = false;
        objF3.New_Field__c = true;
        objF3.Object_Mapping__c = obj.id;
        objF3.Source_Field__c = 'sustain_app__Currency__c';
        objF3.Source_Field_Type__c = 'Picklist';
        objF3.Target_Field__c = 'Name';
        objF3.Target_Field_Type__c = 'Picklist';
        objF3.Mapping_Included__c = true;
        objF3.Calculated__c = false;
        lst.add(objF3);
        Field_Mappings__c objF4 = Sustain_TestDataFactory.createFieldMapping();
        objF4.Calculated__c = false;
        objF4.New_Field__c = true;
        objF4.Object_Mapping__c = obj.id;
        objF4.Source_Field__c = 'sustain_app__Description__c';
        objF4.Source_Field_Type__c = 'Text(255)';
        objF4.Target_Field__c = 'Description';
        objF4.Target_Field_Type__c = 'Long Text Area(1000)';
        objF4.Mapping_Included__c = true;
        objF4.Calculated__c = false;
        lst.add(objF4); 
        Field_Mappings__c objF5 = Sustain_TestDataFactory.createFieldMapping();
        objF5.Calculated__c = false;
        objF5.New_Field__c = true;
        objF5.Object_Mapping__c = obj.id;
        objF5.Source_Field__c = 'sustain_app__EmissionFactorScope3Dataset__c';
        objF5.Source_Field_Type__c = 'Lookup(Emission Factors Scope 3 Dataset)';
        objF5.Target_Field__c = 'PcmtEmssnFctrId';
        objF5.Target_Field_Type__c = 'Lookup(Procurement Emissions Factor Set)';
        objF5.Mapping_Included__c = true;
        objF5.Calculated__c = false;
        lst.add(objF5);
        Field_Mappings__c objF6 = Sustain_TestDataFactory.createFieldMapping();
        objF6.Calculated__c = false;
        objF6.New_Field__c = true;
        objF6.Calculated__c = false;
        objF6.New_Field__c = true;
        objF6.Object_Mapping__c = obj.id;
        objF6.Source_Field__c = 'sustain_app__InflationRateOverride__c';
        objF6.Source_Field_Type__c = 'Percent(12, 4)';
        objF6.Target_Field__c = 'InflationRateOverride';
        objF6.Target_Field_Type__c = 'Percent(12, 4)';
        objF6.Mapping_Included__c = true;
        objF6.Calculated__c = false;
        lst.add(objF6); 
        Field_Mappings__c objF7 = Sustain_TestDataFactory.createFieldMapping();
        objF7.Calculated__c = false;
        objF7.New_Field__c = true;
        objF7.Object_Mapping__c = obj.id;
        objF7.Source_Field__c = 'sustain_app__IsComplete__c';
        objF7.Source_Field_Type__c = 'Checkbox';
        objF7.Target_Field__c = 'IsComplete';
        objF7.Target_Field_Type__c = 'Checkbox';
        objF7.Mapping_Included__c = true;
        objF7.Calculated__c = false;
        lst.add(objF7);
        insert lst;
        
        sustain_app__ConsumptionReport__c carbonFt = Sustain_TestDataFactory.createCarbonFootPrnt();
        insert carbonFt;
        
        
        sustain_app__ProcurementDataset__c d = new sustain_app__ProcurementDataset__c();
        d.name = 'Scope 3 - FY19 - New procurement dataset';
        d.sustain_app__CalendarYear__c = '2020';
        d.sustain_app__Currency__c = 'USD';
        d.sustain_app__Description__c = 'Procurement Sourcing for NA';
        d.sustain_app__IsComplete__c = true;
        d.sustain_app__InflationRateOverride__c = 10.0;
        d.sustain_app__CarbonFootprint__c = carbonFt.id;
        insert d;
        
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        boolean stepValue;
        System.runAs(u1){
            test.startTest();
            stepValue = Sustain_FinalDataController.startFinalDataLoad();
            test.stopTest();
        }
        String obj1 = 'Select id from Scope3PcmtSummary limit 1';
        List<Sobject> obj2 = database.query(obj1);
        system.assertEquals(true, obj2 !=null);
        
    }
    
    static testmethod void checkRunningJobIsSampleFinalTest() {
        
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        boolean stepValue;
        System.runAs(u1){
            test.startTest();
            stepValue = Sustain_FinalDataController.checkRunningJobIsSampleFinal();
            test.stopTest();
        }
        system.assertEquals(true, stepValue);
        
    }
    
}