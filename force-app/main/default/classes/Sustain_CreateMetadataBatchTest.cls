@isTest(SeeAllData=False)
private class Sustain_CreateMetadataBatchTest {
    @testSetup
    static void setup() {
      /*  Object_Mappings__c obj = new Object_Mappings__c();
        obj.Source_Object__c= 'Test__c';
        obj.Target_Object__c = 'GeneratedWaste';
        obj.Source_Object_Label__c = 'Test';
        obj.Mapping_Included__c = true;
        insert obj;
        
        Field_Mappings__c objF = new Field_Mappings__c();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_datetime__c';
        objF.Source_Field_Type__c = 'DateTime';
        objF.Source_Field_Label__c = 'test datetime';
        objF.Required__c = true;
        objF.object_mapping__c = obj.id;
        insert objF;
        
        objF = new Field_Mappings__c();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_picklist__c';
        objF.Source_Field_Type__c = 'Picklist';
        objF.Source_Field_Label__c = 'test picklist';
        objF.object_mapping__c = obj.id;
        insert objF;
        
        objF = new Field_Mappings__c();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_text_area_long__c';
        objF.Source_Field_Type__c = 'TextArea';
        objF.Source_Field_Label__c = 'test text area long';
        objF.object_mapping__c = obj.id;
        insert objF;
        
        objF = new Field_Mappings__c();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_url__c';
        objF.Source_Field_Type__c = 'URL';
        objF.Source_Field_Label__c = 'test url';
        objF.object_mapping__c = obj.id;
        insert objF;
        
        objF = new Field_Mappings__c();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_checkbox__c';
        objF.Source_Field_Type__c = 'Boolean';
        objF.Source_Field_Label__c = 'test_checkbox';
        objF.object_mapping__c = obj.id;
        insert objF;
        
        objF = new Field_Mappings__c();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_phone__c';
        objF.Source_Field_Type__c = 'Phone';
        objF.Source_Field_Label__c = 'test phone';
        objF.object_mapping__c = obj.id;
        insert objF;
        
        objF = new Field_Mappings__c();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_percentage__c';
        objF.Source_Field_Type__c = 'Percent';
        objF.Source_Field_Label__c = 'test percentage';
        objF.object_mapping__c = obj.id;
        insert objF;
        
        objF = new Field_Mappings__c();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_email__c';
        objF.Source_Field_Type__c = 'Email';
        objF.Source_Field_Label__c = 'test email';
        objF.object_mapping__c = obj.id;
        insert objF;*/
        
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
        objF3.Target_Field__c = 'CurrencyCode';
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
         Field_Mappings__c objF8 = Sustain_TestDataFactory.createFieldMapping();
        objF8.Calculated__c = false;
        objF8.New_Field__c = true;
        objF8.Object_Mapping__c = obj.id;
        objF8.Source_Field__c = 'Error_Details__c';
        objF8.Source_Field_Type__c = 'Long';
        objF8.Target_Field__c = 'Error_Details__c';
        objF8.Target_Field_Type__c = 'Long';
        objF8.Mapping_Included__c = true;
        lst.add(objF8);
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
        
        
    }
    
    @isTest static void test() {
        Test.startTest();
        Sustain_CreateMetadataBatch uca = new Sustain_CreateMetadataBatch();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        system.assertNotEquals(null, batchId);
    }
    
}