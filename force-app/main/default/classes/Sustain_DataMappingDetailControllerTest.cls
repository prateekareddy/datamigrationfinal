/***************************************************************************************************************
* Name - Sustain_DataMappingDetailControllerTest
* Description - This class is used as a test class for Sustain_DataMappingDetailController apex class.
* Author - Accenture (Bindhyachal)
* Created Date -9/19/2021
* Last Modified By & Date - Accenture, 2/16/2022
* ***************************************************************************************************************/
@isTest(SeeAllData=False)
private class Sustain_DataMappingDetailControllerTest {
    static testMethod void setup() {
        Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
        obj.Source_Object__c= 'Test__c';
        obj.Target_Object__c = 'GeneratedWaste';
        obj.Source_Object_Label__c = 'Test';
        obj.Mapping_Included__c = true;
        insert obj;
        
        Field_Mappings__c objF = Sustain_TestDataFactory.createFieldMapping();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_datetime__c';
        objF.Source_Field_Type__c = 'DateTime';
        objF.Source_Field_Label__c = 'test datetime';
        objF.Required__c = true;
        objF.object_mapping__c = obj.id;
        insert objF;
        
        List<String> objNames=new List<String>(); 
        
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
            test.startTest();       
            Sustain_DataMappingDetailController.getDataMappingDetails();            
            Sustain_DataMappingDetailController.updateMigrationStatus('step2');
            Sustain_DataMappingDetailController.getTotalRecordCount(objNames);
            Sustain_FinalDataController.updateMigrationStatus('step2');         
            test.stopTest();
        }
        system.assertNotEquals(u1.Id,null);       
    }
}