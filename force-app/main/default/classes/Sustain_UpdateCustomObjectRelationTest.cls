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
        Sustain_UpdateCustomObjectRelationship up=new Sustain_UpdateCustomObjectRelationship();  List<sObject> listWRecords = new List<sObject>();
        User u1 = Sustain_TestDataFactory.createAdmninUser();       
        System.runAs(u1){
            String testStr = '';
            test.startTest();
            testStr= Sustain_UpdateCustomObjectRelationship.getSOQLString(fieldMappingList);
            Sustain_UpdateCustomObjectRelationship.getCustomObjectMappingtoUpdate();
            Sustain_UpdateCustomObjectRelationship.updateCustomObjectRecords(listWRecords, fieldMappingList);
            Sustain_UpdateCustomObjectRelationship.updateCustomObjectRecords(null, null);
            test.stoptest();
           system.assertEquals(true, String.isNotBlank(testStr));
        }
        
       
    }
    
}