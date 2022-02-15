@istest
public class Sustain_FieldMappingTriggerHandlerTest {
    @testSetup
    public static void setup() {
        Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
        insert obj;
      
        Migration_Status__c mg=new Migration_Status__c();
        mg.Metadata_Created__c=true;
        insert mg;
    }
    @isTest static void testmethod1() {
        Object_Mappings__c obj=[select Id,Source_Object__c,Target_Object__c,Source_Object_Label__c,Mapping_Included__c,Source_Record_Type__c,Target_Record_Type__c,Sequence_Number__c,Status__c from Object_Mappings__c LIMIT 1];
        
        Field_Mappings__c objFldNewList = Sustain_TestDataFactory.createFieldMapping();
        objFldNewList.object_mapping__c = obj.id;
        objFldNewList.id = 'a0QB0000002PM0mMAG';
        
     
        
        Field_Mappings__c objFldNewOld = Sustain_TestDataFactory.createFieldMapping();
        objFldNewOld.New_Field__c = false;
        objFldNewOld.object_mapping__c = obj.id;
        objFldNewOld.id = 'a0QB0000002PM0mMAG';
        
       
        List<Field_Mappings__c> fieldMappingList=new List<Field_Mappings__c>();
        fieldMappingList.add(objFldNewList);
        
        Map<Id,Field_Mappings__c> oldmap=new Map<Id,Field_Mappings__c> ();
        oldmap.put('a0QB0000002PM0mMAG', objFldNewOld);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'newUser', Email='aforce@aforceorg.com',
                           EmailEncodingKey='UTF-8', LastName='aforce', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='aforce@aforceorg.com');
        //Database.insert(u1);
        System.runAs(u1){
            Test.startTest();
            Sustain_FieldMappingTriggerHandler.updateMigrationStatus(fieldMappingList,oldmap);
            //Sustain_FieldMappingTriggerHandler.updateMigrationStatus(null,null);
            Test.stopTest();
        }
       system.assertEquals(false, Migration_Status__c.getOrgDefaults().Metadata_Created__c);
       // system.assertNotEquals(obj.id, );
    }
    
}