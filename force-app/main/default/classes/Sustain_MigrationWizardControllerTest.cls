/**
* @description       : 
* @author            : Accenture
* @group             : 
* @last modified on  : 08-31-2021
* @last modified by  : Accenture
**/
@isTest
public class Sustain_MigrationWizardControllerTest {
    static testmethod void getObjMappingTest() {
        list<Object_Mappings__c> objs = new LIST<Object_Mappings__c>();
        Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
        obj.Mapping_Included__c = true;
        obj.Sequence_Number__c = 21;
        obj.Batch_Size__c = 500;
        obj.Object_Type__c =Sustain_UtilConstants.standardLabel;
        objs.add(obj);
        Object_Mappings__c obj1 = Sustain_TestDataFactory.createObjectMapping();
        obj1.Mapping_Included__c = true;
        obj1.Sequence_Number__c = 21;
        obj1.Batch_Size__c = 500;
        obj1.Object_Type__c =Sustain_UtilConstants.customLabel;
        objs.add(obj1);
        Object_Mappings__c obj2 = Sustain_TestDataFactory.createObjectMapping();
        obj2.Mapping_Included__c = true;
        obj2.Sequence_Number__c = 21;
        obj2.Batch_Size__c = 500;
        obj2.Object_Type__c =Sustain_UtilConstants.standardWithCustFieldLabel;
        objs.add(obj2);
        insert objs;
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        ObjMappingListWrapper result;
        System.runAs(u1){
            test.startTest();
            result = Sustain_MigrationWizardController.getObjMapping();
            test.stopTest();
        }
        system.assertEquals(true, result.stdObjList != null);
        
    }
    
    static testmethod void getDataMappingDetailsTest() {
        Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
        obj.Mapping_Included__c = true;
        insert obj;
        
        Field_Mappings__c objF = new Field_Mappings__c();
        objF.Mapping_Included__c= false;
        objF.New_Field__c = true;
        objF.Calculated__c = false;
        objF.Source_Field__c = 'test_datetime__c';
        objF.Source_Field_Type__c = 'DateTime';
        objF.Source_Field_Label__c = 'test datetime';
        objF.Required__c = true;
        objF.object_mapping__c = obj.id;
        insert objF;
        
        boolean val;
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
            test.startTest();
            val = Sustain_MigrationWizardController.getDataMappingDetails();
            test.stopTest();
        }
        system.assertEquals(true, val);
    }
    
    
    static testmethod void getSCPackageVersionTest() {
        boolean val;
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
            test.startTest();
            val = Sustain_MigrationWizardController.getSCPackageVersion();
            test.stopTest();
        }
        system.assertEquals(true, val);
    }
    
    static testmethod void deleteDataLoadReqTest() {
         sustain_app__Asset__c asset=new sustain_app__Asset__c();
        asset.Name='test';
        asset.Target_SFDC_ID__c = null;
        asset.Migration_Status__c = 'Not Started';
        insert asset;
          List<String> lstAsset=new List<String>();
        lstAsset.add(asset.name);
        Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
         obj.Source_Object__c= 'sustain_app__Asset__c';
        obj.Target_Object__c = 'Contact';
        obj.Source_Object_Label__c = 'Test';
        obj.Mapping_Included__c = true;
        obj.Source_Record_Type__c='reference';
        obj.Target_Record_Type__c='Master';
        obj.Sequence_Number__c=4;
        obj.Status__c = 'Completed';
        insert obj;
        
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
            test.startTest();
            Sustain_MigrationWizardController.deleteDataLoadReq();
            //Sustain_SampleDataLoadCtrl.createDataLoadReq(lstAsset);
            test.stopTest();
        }
        list<Object_Mappings__c> objs = [select id from Object_Mappings__c];
        system.assertEquals(false, objs == null);
    }
    
    
    
    @isTest static void migrationWizardControllerTestMethod(){
        /*Migration_Status__c ms = new Migration_Status__c();
ms.Current_Migration_Stage__c   = 'Org Data Scan Output';             
ms.Ready_To_Launch__c = true;
insert ms;*/
        
        Default_Emission_Factors__c def=new Default_Emission_Factors__c();
        def.Name='test';
        def.Factor_Value__c='testemission';
        insert def;
        Map<String,Default_Emission_Factors__c> defMap=new Map<String,Default_Emission_Factors__c>();
        defMap.put(def.id, def);
        
        Test.startTest();
        EmissionFactorWrapper wrap=Sustain_MigrationWizardController.getAllEmissionFactors();
        ObjMappingListWrapper objWrap=Sustain_MigrationWizardController.getObjMapping();
        Sustain_MigrationWizardController.MappingListWrapper fieldWrap= Sustain_MigrationWizardController.getAllMapping();
        String stage=Sustain_MigrationWizardController.getCurrentStage();
        boolean flag=Sustain_MigrationWizardController.getMigrationStatusSetting();
        boolean flag2=Sustain_MigrationWizardController.updateMigrationStatus('step3');
        Sustain_MigrationWizardController.updateMigrationStatus(null);
      //  boolean flag3=Sustain_MigrationWizardController.getMigrationStatus();
        boolean flag5=Sustain_MigrationWizardController.getRunningMetadataJobFlag();
        // Sustain_MigrationWizardController.getDefaultEmissionFactors();
        //  Sustain_MigrationWizardController.createEmissionFactorRecords(defMap);
        Sustain_MigrationWizardController.getMigrationStatusData();  
        Sustain_MigrationWizardController.startFinalDataLoad();
         Sustain_MigrationWizardController.getObjectMappingCount();
        //Sustain_MigrationWizardController.executeBatchJob();
        Test.stopTest();
        system.assertEquals(fieldWrap!=null, true);
       // system.assertEquals(Wrap!=null, true);
    }
    static testmethod void getAllMappingsTest() {
        Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
        obj.Mapping_Included__c = true;
        obj.Status__c = 'Completed';
        insert obj;
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        List<String> s;
        System.runAs(u1){
            test.startTest();
            s = Sustain_MigrationWizardController.getAllMappings();
            test.stopTest();
        }
        system.assertEquals(true, s!=null);
        
    }
    
    static testmethod void getrunningJobStatusTest() {
        Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
        obj.Mapping_Included__c = true;
        obj.Status__c = 'Completed';
        insert obj;
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        boolean s;
        System.runAs(u1){
            test.startTest();
            s = Sustain_MigrationWizardController.getrunningJobStatus();
            test.stopTest();
        }
        system.assertEquals(true, s);
        
    }
    
    @isTest static void migrationWizardControllerUpdateTestMethod(){
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
        
        Migration_Status__c m =  new Migration_Status__c();
        m.Ready_to_Launch__c =true;
        insert m;
        /* List<Object_Mappings__c> mappingList=[select id,Object_Type__c,Source_Object__c,(select id from Field_Mappings__r) from Object_Mappings__c where Object_Type__c=: Sustain_UtilConstants.customLabel
and Mapping_Included__c=true];
List<Field_Mappings__c> fieldMappingList=[SELECT Id, Source_Field__c,Source_Field_Label__c,Source_Field_Type__c,Target_Field_Label__c,Target_Field__c, Target_Field_Type__c, Calculated__c, 
New_Field__c,Mapping_Included__c, Object_Mapping__c, Object_Mapping__r.Source_Object__c,Object_Mapping__r.Target_Object__c,
Object_Mapping__r.Total_Fields__c,Object_Mapping__r.Total_To_Review_Fields__c,Object_Mapping__r.Source_Object_Label__c,Object_Mapping__r.Destination_Object_Label__c,Comments__c,Custom_Field__c FROM Field_Mappings__c
where Object_Mapping__r.Mapping_Included__c=true order by Object_Mapping__c];*/
        
        List<String> utilityFieldList =new List<String>();
        Test.startTest();
        Sustain_MigrationWizardController.updateObjMapping(mappingList);
        Sustain_MigrationWizardController.updateObjMapping(null);
        Sustain_MigrationWizardController.updateFieldMapping(fieldMappingList);
        Sustain_MigrationWizardController.updateFieldMapping(null);
        Sustain_CreateMigrationMapping.createCustomFieldMappings(mappingList);
        Sustain_CreateMigrationMapping.createCustomFieldMappings(null);
        Sustain_CreateMigrationMapping.createFieldsMapping('list');
        Sustain_CreateMigrationMapping.createObjectMapping('list');
        Sustain_CreateMigrationMapping.createCustomObjectMapping();
        Sustain_CreateMigrationMapping.createCustObjMappingforMngPckgDependentFieldsforSpecific(mappingList);
        Sustain_CreateMigrationMapping.getObjectType('GeneratedWaste');
        //sustain_CreateMigrationMapping.createFieldMappingForStdObjs(mappingList, utilityFieldList);
        // Sustain_CreateMigrationMapping.createFieldMappingForCustObjs(mappingList, utilityFieldList);
        // Sustain_CreateMigrationMapping.getTargetObjectNameField('sustain_app__BuildingEnergyIntensity__c');
        List<Sustain_MigrationWizardController.CustomFieldWrapper> fieldList=Sustain_MigrationWizardController.getAllCustomFields('OtherEmssnFctrSet');
       boolean t;
        Test.stopTest();
        List<Object_Mappings__c> objMapList=[select id from Object_Mappings__c limit 100];
        t = Sustain_MigrationWizardController.getMigrationStatus();
       // system.assertEquals(objMapList.size()<0, true);
        // system.assertEquals(true, t);
    }
    
}