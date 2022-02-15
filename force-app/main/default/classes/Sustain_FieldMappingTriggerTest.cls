@isTest(SeeAllData=False)
private class Sustain_FieldMappingTriggerTest {
    // private Sustain_FieldMappingTriggerTest(){
    //  system.debug('Constructor');
    // }
    
    @isTest static void unitTest() {
        //Sustain_FieldMappingTriggerHandler fm=new Sustain_FieldMappingTriggerHandler();
        // List<Field_Mappings__c> fieldMappingList=[SELECT Id, Source_Field__c,Source_Field_Label__c,Source_Field_Type__c,Target_Field_Label__c,Target_Field__c, Target_Field_Type__c, Calculated__c, New_Field__c,Mapping_Included__c, Object_Mapping__c from Field_Mappings__c]; 
        
        Map<Id,Field_Mappings__c> oldmap=new Map<Id,Field_Mappings__c> ();
        
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
        
        Field_Mappings__c objF = new Field_Mappings__c();
        List<Field_Mappings__c> fieldMappingList=new  List<Field_Mappings__c>();
        fieldMappingList.add(objF);
        objF.Mapping_Included__c= true;
        objF.New_Field__c = false;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_datetime__c';
        objF.Source_Field_Type__c = 'DateTime';
        objF.Source_Field_Label__c = 'test datetime';
        objF.Required__c = true;
        objF.object_mapping__c = obj.id;
        insert objF;
        fieldMappingList.add(objF);
        oldmap.put(objF.id, objF);
        objF.Target_Field_Label__c = objF.Source_Field_Label__c;
        objF.Target_Field__c = objF.Source_Field__c;
        objF.Target_Field_Type__c = objF.Source_Field_Type__c;
        update objF;
        Migration_Status__c mg=new Migration_Status__c();
        mg.Metadata_Created__c=false;
        insert mg;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'newUser', Email='aforce@aforceorg.com',
                           EmailEncodingKey='UTF-8', LastName='aforce', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='aforce@aforceorg.com');
        //Database.insert(u1);
        System.runAs(u1){
            Test.startTest();
            //Sustain_FieldMappingTriggerHandler.updateMigrationStatus(fieldMappingList,oldmap);
            //Sustain_FieldMappingTriggerHandler.updateMigrationStatus(null,null);
            objF.New_Field__c = true;
            update objF;
            Test.stopTest();
        }
        system.assertEquals(false, Migration_Status__c.getOrgDefaults().Metadata_Created__c);
        
    }
}