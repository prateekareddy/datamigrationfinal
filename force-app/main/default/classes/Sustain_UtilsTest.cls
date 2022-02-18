/***************************************************************************************************************
* Name - Sustain_UtilsTest
* Description - This class is used as a test class for Sustain_Utils apex class.
* Author - Accenture (Gopalarao)
* Created Date -9/28/2021
* Last Modified By & Date - Accenture, 2/16/2022
* ***************************************************************************************************************/
@isTest(SeeAllData=False)
private class Sustain_UtilsTest {
    
    static testMethod void unitTestMethod() {
        List<SObject> newSObject = new List<SObject>();
        List<SObject> sObjectNew = new List<SObject>();
        List<Database.SaveResult> results =new List<Database.SaveResult>();
        List<String> assetContactIdList=new List<String>();
        List<String> assetContactIdList1=new List<String>();
        sustain_app__ServiceProvider__c supplier=new sustain_app__ServiceProvider__c();
        supplier.Name='Constellation Energy';
        insert supplier;
        
        Object_Mappings__c obj = new Object_Mappings__c();
        obj.Source_Object__c= 'Test__c';
        obj.Target_Object__c = 'GeneratedWaste';
        obj.Source_Object_Label__c = 'Test';
        obj.Mapping_Included__c = true;
        obj.Source_Record_Type__c='reference';
        obj.Target_Record_Type__c='string';
        obj.Sequence_Number__c=4;
        obj.Status__c='Completed';
        insert obj;
        List<Object_Mappings__c> mappingList =new List<Object_Mappings__c>();
        mappingList.add(obj);
        
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
        List<Field_Mappings__c> fieldMappingList =new List<Field_Mappings__c>();
        fieldMappingList.add(objF);
        
         User u1 = Sustain_TestDataFactory.createAdmninUser();
        
        Test.startTest();
            System.runAs(u1){
                Sustain_Utils.createGenericRecords(newSObject, fieldMappingList);
                Sustain_Utils.createGenericRecords(null, null);
                Sustain_Utils.createEnergyUseandItemRecords(newSObject, fieldMappingList);
                Sustain_Utils.createEnergyUseandItemRecords(null, null);
                Sustain_Utils.updateSourceObjectRecords(newSObject, sObjectNew, 'GeneratedWaste');
                Sustain_Utils.updateSourceObjectRecords(null, null, 'GeneratedWaste');
                Sustain_Utils.updateErrorResult(newSObject, results);
                Sustain_Utils.createOtherEmissionChildRecords(newSObject, fieldMappingList);
                Sustain_Utils.createOtherEmissionChildRecords(null, null);
                Sustain_Utils.createBuildingEnergyIntensityValueRecords(newSObject, fieldMappingList);
                Sustain_Utils.createBuildingEnergyIntensityValueRecords(null, null);
                Sustain_Utils.addAccountField(assetContactIdList,assetContactIdList, newSObject);
                Sustain_Utils.addAccountIDField(assetContactIdList,newSObject);
                Sustain_Utils.getTargetIds(assetContactIdList, 'sustain_app__BuildingEnergyIntensity__c');
                Sustain_Utils.getFootPrintIdScope3EmssnIdMap(assetContactIdList);
                Sustain_Utils.addToCarbonFootprintIdList('printId');            
            }
        Test.stopTest();
        String sql = 'select id from GeneratedWaste';
        list<Sobject> lst = database.query(sql);
        system.assertEquals(false, lst.size()>0);
    }
}