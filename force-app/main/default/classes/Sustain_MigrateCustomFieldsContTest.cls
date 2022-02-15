@isTest(SeeAllData=False)
private class Sustain_MigrateCustomFieldsContTest {
    static testMethod void unitTestMethod(){     
        List <MetadataService.CustomField> fieldList = new List <MetadataService.CustomField>();
        Map<String,List <MetadataService.CustomField>> objFieldsMapping = new Map<String,List<MetadataService.CustomField>>();
        
        List<String> my_list = new List<String>();
        my_list.add('test');
        Set<String> set1 = new Set<String>{'New York', 'Paris'};

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
        
        Map<String,List<Field_Mappings__c>> refFieldMap=new Map<String,List<Field_Mappings__c>>();
        MetadataService.SaveResult saveResult=new MetadataService.SaveResult ();
        
       // Sustain_MigrateCustomFieldsController.createCustomField(objFieldsMapping, 'sustain_app__AssetContact__c', refFieldMap);
       // Sustain_MigrateCustomFieldsController.createCustomField(null, null, null);
        Sustain_MigrateCustomFieldsController.processFieldMappings(refFieldMap);
        Sustain_MigrateCustomFieldsController.processFieldMappings(null);
        Sustain_MigrateCustomFieldsController.handleSaveResults(saveResult, set1);
         Sustain_MigrateCustomFieldsController.handleSaveResults(null, null);
        Sustain_MigrateCustomFieldsController.readCustomObjectSync(my_list, 'AirTravelEnrgyUse', set1, refFieldMap);
       
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'newUser', Email='aforce@aforceorg.com',
                           EmailEncodingKey='UTF-8', LastName='aforce', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='aforce@aforceorg.com');
     
        
        System.runAs(u1){
            Test.startTest();
            
            Test.stopTest();
        }
        system.assertNotEquals(u1.Id,null);
    }
}