/***************************************************************************************************************
* Name - Sustain_UpdateCustomObjectRefBatchTest
* Description - This class is used as a test class for Sustain_UpdateCustomObjectRefBatch apex class.
* Author - Accenture (Bindhyachal)
* Created Date -9/14/2021
* Last Modified By & Date - Accenture, 9/14/2021
* ***************************************************************************************************************/

@isTest(SeeAllData=False)
private class Sustain_UpdateCustomObjectRefBatchTest{
    
    static testMethod void testMothod() { 
         Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
        obj.Source_Object__c = 'sustain_app__ProcurementDataset__c';
        obj.Source_Record_Type__c = 'Master';
        // obj.Source_Record_Type__c = 'Master';
        obj.Target_Object__c = 'Scope3PcmtSummary';
        obj.Target_Record_Type__c = 'Master';
        obj.Status__c = 'Not Started';
        obj.Object_Type__c = 'standard';
        obj.Sequence_Number__c = 38;
        obj.Batch_Size__c = 500;
        insert obj;
        list<Field_Mappings__c> lst = new  list<Field_Mappings__c>();       
        
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
        System.runAs(u1){
            test.startTest();
            Sustain_UpdateCustomObjectRefBatch uca = new Sustain_UpdateCustomObjectRefBatch(obj,'sample data load');
            Id batchId =database.executeBatch(uca);
            test.stopTest();
            system.assertEquals(true, batchId !=null);
        }
    }
}