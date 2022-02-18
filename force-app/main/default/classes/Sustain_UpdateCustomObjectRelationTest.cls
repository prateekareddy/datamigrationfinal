/***************************************************************************************************************
* Name - Sustain_UpdateCustomObjectRelationTest
* Description - This class is used as a test class for Sustain_UpdateCustomObjectRelation apex class.
* Author - Accenture (Prateeka)
* Created Date -9/21/2021
* Last Modified By & Date - Accenture, 2/16/2022
* ***************************************************************************************************************/
@isTest(SeeAllData=False)
private class Sustain_UpdateCustomObjectRelationTest {
    static testmethod void setup() {
        Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
        insert obj;
        List<Object_Mappings__c> mappingList =new List<Object_Mappings__c>();
        mappingList.add(obj);
        
        Field_Mappings__c objF = Sustain_TestDataFactory.createFieldMapping();
        objF.object_mapping__c = obj.id;
        insert objF;
        List<Field_Mappings__c> fieldMappingList =new List<Field_Mappings__c>();
        fieldMappingList.add(objF);
        Sustain_UpdateCustomObjectRelationship up=new Sustain_UpdateCustomObjectRelationship();
        List<sObject> listWRecords = new List<sObject>();
        User u1 = Sustain_TestDataFactory.createAdmninUser();       
        System.runAs(u1){
            String testStr = '';
            String testStr1 = '';
            test.startTest();
                testStr= Sustain_UpdateCustomObjectRelationship.getSOQLString(fieldMappingList);
                testStr1= Sustain_UpdateCustomObjectRelationship.getSOQLString(null);
                Sustain_UpdateCustomObjectRelationship.getCustomObjectMappingtoUpdate();
                Sustain_UpdateCustomObjectRelationship.updateCustomObjectRecords(listWRecords, fieldMappingList);
                Sustain_UpdateCustomObjectRelationship.updateCustomObjectRecords(null, null);
            test.stoptest();
            system.assertEquals(true, String.isNotBlank(testStr));
            system.assertEquals(false, String.isNotBlank(testStr1));
        }      
    }   
}