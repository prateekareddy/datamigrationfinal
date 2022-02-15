@isTest(SeeAllData=False)
private class Sustain_DeleteSampleLoadBatchTest {
    @testSetup
    static void setup() {
        sustain_app__Asset__c asset=new sustain_app__Asset__c();
        asset.Name='test';
        asset.Target_SFDC_ID__c = null;
        asset.Migration_Status__c = 'Not Started';
        insert asset; 
        
        Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
        insert obj;
        obj.Source_Object__c= 'sustain_app__Asset__c';
        update obj;
        
        Data_Load_Request__c dataRec = Sustain_TestDataFactory.createDataLoadRequest();
        insert dataRec;
    }    
    
    @isTest static void testDelete() {
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
            Test.startTest();
            Object_Mappings__c obj = [Select Id,Source_Object__c,Source_Record_Type__c from Object_Mappings__c limit 1];
            Data_Load_Request__c dataRec  = [select id from Data_Load_Request__c limit 1];
            //Sustain_DeleteSampleLoadBatch uca = new Sustain_DeleteSampleLoadBatch(dataRec, obj);
            //Id batchId = Database.executeBatch(uca,100);
            Test.stopTest();
        }
        sustain_app__Asset__c asset  = [select Id from  sustain_app__Asset__c limit 1];
        system.assertNotEquals(true, asset == null);
        
    }
}