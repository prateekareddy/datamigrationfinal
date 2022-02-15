@isTest(SeeAllData=False)
private class Sustain_DataMappingDetailControllerTest {
    //private Sustain_DataMappingDetailControllerTest(){
       // system.debug('Constructor');
  //  }
  
   static testMethod void setup() {
        Object_Mappings__c obj = new Object_Mappings__c();
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
      //  List<String> objNames=new List<String> {'supplier','asset'};
           
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'newUser', Email='aforce@aforceorg.com',
                           EmailEncodingKey='UTF-8', LastName='aforce', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='aforce@aforceorg.com');
        //Database.insert(u1);
        System.runAs(u1){
        test.startTest();
       // User u2= [select Id,Alias,Email from User LIMIT 1];
       
        Sustain_DataMappingDetailController.getDataMappingDetails();
        //Sustain_DataMappingDetailController.getTotalRecordCount(objNames);
        Sustain_DataMappingDetailController.updateMigrationStatus('step2');
        Sustain_FinalDataController.updateMigrationStatus('step2');
        //Sustain_DataMappingDetailController.getTotalRecordCount(objNames);
        test.stopTest();
        }
        system.assertNotEquals(u1.Id,null);
       
    }
}