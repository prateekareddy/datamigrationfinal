/***************************************************************************************************************
* Name - Sustain_SampleDataLoadCtrlTest
* Description - This class is used as a test class for Sustain_SampleDataLoadCtrl apex class.
* Author - Accenture (Prateeka)
* Created Date -9/1/2021
* Last Modified By & Date - Accenture, 9/1/2021
* ***************************************************************************************************************/

@isTest(SeeAllData = false)
private class Sustain_SampleDataLoadCtrlTest {
    static testMethod void unitTestMethod(){
        
        Sustain_SampleDataLoadCtrl ms=new Sustain_SampleDataLoadCtrl();
        
        sustain_app__Asset__c asset=new sustain_app__Asset__c();
        asset.Name='test';
        asset.Target_SFDC_ID__c = null;
        asset.Migration_Status__c = 'Not Started';
        insert asset;
        
        List<String> lstAsset=new List<String>();
        lstAsset.add(asset.Name);
        
        Data_Load_Request__c dataRec = new Data_Load_Request__c();
        dataRec.Request_Job_Name__c = 'Sample Data Load';
        dataRec.Start_Date_Time__c = system.now();
        dataRec.Data_Load_Type__c = 'Sample Data Load';
        dataRec.Status__c='Completed';
        insert dataRec;
        
        List<String> lstdatareq=new List<String>();
        lstdatareq.add(dataRec.Request_Job_Name__c);
        Object_Mappings__c obj = new Object_Mappings__c();
        obj.Source_Object__c= 'sustain_app__Asset__c';
        obj.Target_Object__c = 'Contact';
        obj.Source_Object_Label__c = 'Test';
        obj.Mapping_Included__c = true;
        obj.Source_Record_Type__c='reference';
        obj.Target_Record_Type__c='Master';
        obj.Sequence_Number__c=4;
        obj.Status__c='Completed';
        insert obj;
        
      /*  obj = new Object_Mappings__c();
        obj.Target_Object__c='OtherEmssnFctrSet';
        obj.Source_Object__c='sustain_app__EmissionFactorOther__c';
        obj.Source_Record_Type__c='Mobile_Fuels';
        obj.Target_Record_Type__c ='Master';
        obj.Status__c = 'Not Started' ;
        obj.Object_Type__c = 'standard'; 
        obj.mapping_included__c=true  ;
        obj.sequence_number__c=3;
        obj.Delete_Sequence_No__c=3;
        insert obj;*/
        
        Field_Mappings__c objF = new Field_Mappings__c();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        
        objF.Required__c = true;
        
        objF.Reference_To__c='empty';
        
        objF.Source_Field_Type__c='Number(10, 8)';
        objF.object_mapping__c = obj.id;
        insert objF;
        
        
        objF = new Field_Mappings__c();
        objF.Mapping_Included__c= true;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_datetime__c';
        objF.Source_Field_Type__c = 'DateTime';
        objF.Source_Field_Label__c = 'test datetime';
        objF.Required__c = true;
        objF.object_mapping__c = obj.id;
        insert objF;
          Sustain_DeleteTargetRecordsBatch batchRecords = new Sustain_DeleteTargetRecordsBatch(dataRec, obj, false);
        ID batchProcessId = database.executeBatch(batchRecords, 1000);
        Sustain_SampleDataLoadCtrl.fetchLookUpValues('bufdg', lstAsset);
        Sustain_SampleDataLoadCtrl.fetchLookUpValues('q', lstAsset);
        Sustain_SampleDataLoadCtrl.fetchLookUpValues('bufdg', null);
        //Sustain_SampleDataLoadCtrl.createDataLoadReq(lstAsset);
          System.assertNotEquals(null, batchProcessId);
        
    }
         @isTest static void test() {
        Test.startTest();
       
     
        
        Sustain_SampleDataLoadCtrl.getOrgAssetData();
       
        Sustain_SampleDataLoadCtrl.getlatestDataLoad();
       Sustain_SampleDataLoadCtrl.deleteDataLoadReq();
        Sustain_SampleDataLoadCtrl.checkRunningJobIsSampleFinal();
        
        Test.stopTest();
           
     
    }
    
}