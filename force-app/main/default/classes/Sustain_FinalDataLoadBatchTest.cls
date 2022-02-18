/***************************************************************************************************************
* Name - Sustain_FinalDataLoadBatchTest
* Description - This class is used as a test class for Sustain_FinalDataLoadBatch apex class.
* Author - Accenture (Bindhyachal)
* Created Date -9/19/2021
* Last Modified By & Date - Accenture, 2/14/2022
* ***************************************************************************************************************/
@isTest(SeeAllData=False)
private class Sustain_FinalDataLoadBatchTest {
    
    static testmethod void finalLoad(){
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
            test.startTest();
            sustain_app__Asset__c asset=Sustain_TestDataFactory.createAsset();
            insert asset;
            
            sustain_app__Contact__c contact  = Sustain_TestDataFactory.createContact();
            insert contact;
            
            sustain_app__EmissionFactorElectricity__c electric  = Sustain_TestDataFactory.createElectricity();
            insert electric;
            
            sustain_app__EmissionFactorOther__c other  = Sustain_TestDataFactory.createOther();
            insert other;
            
            sustain_app__ServiceProvider__c provide  = Sustain_TestDataFactory.createProvider();
            insert provide;
            
            sustain_app__Contract__c contract  = Sustain_TestDataFactory.createContract();
            insert contract;
            
            
            
            List<String> lstAsset=new List<String>();
            Map<String,List<Field_Mappings__c>> fldMap = new Map<String,List<Field_Mappings__c>> ();
            
            
            lstAsset.add(asset.id);
            
            sustain_app__EnergyConsumption__c consumption = Sustain_TestDataFactory.createEnergyConsumption();
            consumption.sustain_app__Asset_Contact__c=contact.id;
            consumption.sustain_app__Asset__c = asset.id;
            consumption.sustain_app__Contract__c = contract.id;
            consumption.sustain_app__ElectricityEmissionFactor__c = electric.id;
            consumption.sustain_app__Other_Emission_Factor__c = other.id;
            consumption.sustain_app__Refrigerant_GWP_Factor__c = other.id;
            consumption.sustain_app__ServiceProvider__c = provide.id;
            
            
            Data_Load_Request__c dataRec = Sustain_TestDataFactory.createDataLoadRequest();
            dataRec.Request_Job_Name__c = 'Complete Data Load';
            dataRec.Data_Load_Type__c = 'Complete Data Load';
            dataRec.Start_Date_Time__c = system.now();
            dataRec.End_Date_Time__c = system.now();
            insert dataRec;
            
            Object_Mappings__c obj = Sustain_TestDataFactory.createObjectMapping();
            obj.Source_Object__c= 'sustain_app__Asset__c';
            obj.Source_Record_Type__c = 'sustain_app__General';
            obj.Target_Object__c = 'Scope3EmssnSrc';
            obj.Target_Record_Type__c = 'Master';
            obj.Source_Object_Label__c = 'Test';
            obj.Mapping_Included__c = true;
            obj.Sequence_Number__c = 1;
            obj.Status__c = 'Not Started';
            obj.Batch_Size__c = 500;
            insert obj;
            list<Field_Mappings__c> lst = new  list<Field_Mappings__c>();
            Field_Mappings__c objF = Sustain_TestDataFactory.createFieldMapping();
            objF.Mapping_Included__c= true;
            objF.New_Field__c = true;
            objF.Calculated__c = false;
            objF.Source_Field__c = 'Name';
            objF.Source_Field_Type__c = 'Text(80)';
            objF.Target_Field__c = 'Name';
            objF.Target_Field_Type__c = 'Text(255)';
            objF.object_mapping__c = obj.id;
            // lst.add(objF);
            
            Field_Mappings__c objF1 = Sustain_TestDataFactory.createFieldMapping();
            objF1.Mapping_Included__c= true;
            objF1.New_Field__c = true;
            objF1.Calculated__c = false;
            objF1.Source_Field__c = 'sustain_app__AssetType__c';
            objF1.Source_Field_Type__c = 'Picklist';
            objF1.Target_Field__c = 'Scope3EmissionSourceType';
            objF1.Target_Field_Type__c = 'Picklist';
            objF1.object_mapping__c = obj.id;
            lst.add(objF1);
            
            Field_Mappings__c objF2 = Sustain_TestDataFactory.createFieldMapping();
            objF2.Mapping_Included__c= true;
            objF2.New_Field__c = true;
            objF2.Calculated__c = false;
            objF2.Source_Field__c = 'sustain_app__BusinessRegion__c';
            objF2.Source_Field_Type__c = 'Picklist';
            objF2.Target_Field__c = 'BusinessRegion';
            objF2.Target_Field_Type__c = 'Picklist';
            objF2.object_mapping__c = obj.id;
            lst.add(objF2);
            
            Field_Mappings__c objF3 = Sustain_TestDataFactory.createFieldMapping();
            objF3.Mapping_Included__c= true;
            objF3.New_Field__c = true;
            objF3.Calculated__c = false;
            objF3.Source_Field__c = 'sustain_app__City__c';
            objF3.Source_Field_Type__c = 'Text(255)';
            objF3.Target_Field__c = 'City';
            objF3.Target_Field_Type__c = 'Text(255)';
            objF3.object_mapping__c = obj.id;
            lst.add(objF3);
            
            Field_Mappings__c objF4 = Sustain_TestDataFactory.createFieldMapping();
            objF4.Mapping_Included__c= true;
            objF4.New_Field__c = true;
            objF4.Calculated__c = false;
            objF4.Source_Field__c = 'sustain_app__Country__c';
            objF4.Source_Field_Type__c = 'Picklist';
            objF4.Target_Field__c = 'Country';
            objF4.Target_Field_Type__c = 'Picklist';
            objF4.object_mapping__c = obj.id;
            lst.add(objF4);
            
            Field_Mappings__c objF5 = Sustain_TestDataFactory.createFieldMapping();
            objF5.Mapping_Included__c= true;
            objF5.New_Field__c = true;
            objF5.Calculated__c = false;
            objF5.Source_Field__c = 'sustain_app__Description__c';
            objF5.Source_Field_Type__c = 'Long Text Area(32768)';
            objF5.Target_Field__c = 'Description';
            objF5.Target_Field_Type__c = 'Long Text Area(32768)';
            objF5.object_mapping__c = obj.id;
            lst.add(objF5);
            
            Field_Mappings__c objF6 = Sustain_TestDataFactory.createFieldMapping();
            objF6.Mapping_Included__c= true;
            objF6.New_Field__c = true;
            objF6.Calculated__c = false;
            objF6.Source_Field__c = 'sustain_app__ParentAsset__c';
            objF6.Source_Field_Type__c = 'Lookup (Asset__C)';
            objF6.Target_Field__c = 'ParentEmissionSourceId';
            objF6.Target_Field_Type__c = 'Lookup(Scope 3 Emissions Source)';
            objF6.object_mapping__c = obj.id;
            lst.add(objF6);
            
            Field_Mappings__c objF7 = Sustain_TestDataFactory.createFieldMapping();
            objF7.Mapping_Included__c= true;
            objF7.New_Field__c = true;
            objF7.Calculated__c = false;
            objF7.Source_Field__c = 'sustain_app__State__c';
            objF7.Source_Field_Type__c = 'Text(128)';
            objF7.Target_Field__c = 'State';
            objF7.Target_Field_Type__c = 'Text(128)';
            objF7.object_mapping__c = obj.id;
            lst.add(objF7);
            
            Field_Mappings__c objF8 = Sustain_TestDataFactory.createFieldMapping();
            objF8.Mapping_Included__c= true;
            objF8.New_Field__c = true;
            objF8.Calculated__c = false;
            objF8.Source_Field__c = 'sustain_app__ZipCode__c';
            objF8.Source_Field_Type__c = 'Text(20)';
            objF8.Target_Field__c = 'PostalCode';
            objF8.Target_Field_Type__c = 'Text(20)';
            objF8.object_mapping__c = obj.id;
            lst.add(objF8);
            
            insert lst;
            lst = [select id,Mapping_Included__c,New_Field__c,Calculated__c,Source_Field__c,
                   Source_Field_Type__c,Target_Field__c,Target_Field_Type__c,object_mapping__c,Object_Mapping__r.id,
                   Object_Mapping__r.Source_Object__c,Object_Mapping__r.Source_Record_Type__c,Object_Mapping__r.Target_Object__c,
                   Object_Mapping__r.Target_Record_Type__c,Object_Mapping__r.Mapping_Included__c,Object_Mapping__r.Sequence_Number__c
                   from  Field_Mappings__c];
            
            map<String, list<Object_Mappings__c>> objMap =  new map<String, list<Object_Mappings__c>>();
            string key = obj.Source_Object__c + '-' +obj.Source_Record_Type__c.replaceAll('sustain_app__','').replaceAll('Sustain_app__','');
            objMap.put(key, new list<Object_Mappings__c>{obj});
            fldMap.put(obj.id, lst);
            Sustain_FinalDataLoadBatch nextBatch = new Sustain_FinalDataLoadBatch(objMap, fldMap,1, lstAsset, dataRec.id);
            Id batchId =  database.executeBatch(nextBatch,  200);
            test.stopTest();
        }
        system.assertNotEquals(u1.Id,null);
        
    }
    
    static testmethod void SampleLoad(){
        User u2 = Sustain_TestDataFactory.createAdmninUser();
        insert u2;
        System.runAs(u2){
            test.startTest();
            sustain_app__Asset__c asset=Sustain_TestDataFactory.createAsset();
            insert asset;
            
            sustain_app__Contact__c contact  = Sustain_TestDataFactory.createContact();
            insert contact;
            
            sustain_app__EmissionFactorElectricity__c electric  = Sustain_TestDataFactory.createElectricity();
            insert electric;
            
            sustain_app__EmissionFactorOther__c other  = Sustain_TestDataFactory.createOther();
            insert other;
            
            sustain_app__ServiceProvider__c provide  = Sustain_TestDataFactory.createProvider();
            insert provide;
            
            sustain_app__Contract__c contract  = Sustain_TestDataFactory.createContract();
            insert contract;
            
            
            
            List<String> lstAsset=new List<String>();
            Map<String,List<Field_Mappings__c>> fldMap = new Map<String,List<Field_Mappings__c>> ();
            
            
            lstAsset.add(asset.id);
            
            sustain_app__EnergyConsumption__c consumption = Sustain_TestDataFactory.createEnergyConsumption();
            consumption.sustain_app__Asset_Contact__c=contact.id;
            consumption.sustain_app__Asset__c = asset.id;
            consumption.sustain_app__Contract__c = contract.id;
            consumption.sustain_app__ElectricityEmissionFactor__c = electric.id;
            consumption.sustain_app__Other_Emission_Factor__c = other.id;
            consumption.sustain_app__Refrigerant_GWP_Factor__c = other.id;
            consumption.sustain_app__ServiceProvider__c = provide.id;
            
            
            Data_Load_Request__c dataRec1 = new Data_Load_Request__c();
            dataRec1.Request_Job_Name__c = 'Sample Data Load';
            dataRec1.Data_Load_Type__c = 'Sample Data Load';
            dataRec1.Start_Date_Time__c = system.now();
            dataRec1.End_Date_Time__c = system.now();
            insert dataRec1;
            
            Object_Mappings__c obj = new Object_Mappings__c();
            obj.Source_Object__c= 'sustain_app__Asset__c';
            obj.Source_Record_Type__c = 'sustain_app__General';
            obj.Target_Object__c = 'Scope3EmssnSrc';
            obj.Target_Record_Type__c = 'Master';
            obj.Source_Object_Label__c = 'Test';
            obj.Mapping_Included__c = true;
            obj.Sequence_Number__c = 21;
            obj.Status__c = 'Not Started';
            obj.Batch_Size__c = 500;
            insert obj;
            list<Field_Mappings__c> lst = new  list<Field_Mappings__c>();
            Field_Mappings__c objF = new Field_Mappings__c();
            objF.Mapping_Included__c= true;
            objF.New_Field__c = true;
            objF.Calculated__c = false;
            objF.Source_Field__c = 'Name';
            objF.Source_Field_Type__c = 'Text(80)';
            objF.Target_Field__c = 'Name';
            objF.Target_Field_Type__c = 'Text(255)';
            objF.object_mapping__c = obj.id;
            // lst.add(objF);
            
            Field_Mappings__c objF1 = new Field_Mappings__c();
            objF1.Mapping_Included__c= true;
            objF1.New_Field__c = true;
            objF1.Calculated__c = false;
            objF1.Source_Field__c = 'sustain_app__AssetType__c';
            objF1.Source_Field_Type__c = 'Picklist';
            objF1.Target_Field__c = 'Scope3EmissionSourceType';
            objF1.Target_Field_Type__c = 'Picklist';
            objF1.object_mapping__c = obj.id;
            lst.add(objF1);
            
            Field_Mappings__c objF2 = new Field_Mappings__c();
            objF2.Mapping_Included__c= true;
            objF2.New_Field__c = true;
            objF2.Calculated__c = false;
            objF2.Source_Field__c = 'sustain_app__BusinessRegion__c';
            objF2.Source_Field_Type__c = 'Picklist';
            objF2.Target_Field__c = 'BusinessRegion';
            objF2.Target_Field_Type__c = 'Picklist';
            objF2.object_mapping__c = obj.id;
            lst.add(objF2);
            
            Field_Mappings__c objF3 = new Field_Mappings__c();
            objF3.Mapping_Included__c= true;
            objF3.New_Field__c = true;
            objF3.Calculated__c = false;
            objF3.Source_Field__c = 'sustain_app__City__c';
            objF3.Source_Field_Type__c = 'Text(255)';
            objF3.Target_Field__c = 'City';
            objF3.Target_Field_Type__c = 'Text(255)';
            objF3.object_mapping__c = obj.id;
            lst.add(objF3);
            
            Field_Mappings__c objF4 = new Field_Mappings__c();
            objF4.Mapping_Included__c= true;
            objF4.New_Field__c = true;
            objF4.Calculated__c = false;
            objF4.Source_Field__c = 'sustain_app__Country__c';
            objF4.Source_Field_Type__c = 'Picklist';
            objF4.Target_Field__c = 'Country';
            objF4.Target_Field_Type__c = 'Picklist';
            objF4.object_mapping__c = obj.id;
            lst.add(objF4);
            
            Field_Mappings__c objF5 = new Field_Mappings__c();
            objF5.Mapping_Included__c= true;
            objF5.New_Field__c = true;
            objF5.Calculated__c = false;
            objF5.Source_Field__c = 'sustain_app__Description__c';
            objF5.Source_Field_Type__c = 'Long Text Area(32768)';
            objF5.Target_Field__c = 'Description';
            objF5.Target_Field_Type__c = 'Long Text Area(32768)';
            objF5.object_mapping__c = obj.id;
            lst.add(objF5);
            
            Field_Mappings__c objF6 = new Field_Mappings__c();
            objF6.Mapping_Included__c= true;
            objF6.New_Field__c = true;
            objF6.Calculated__c = false;
            objF6.Source_Field__c = 'sustain_app__ParentAsset__c';
            objF6.Source_Field_Type__c = 'Lookup (Asset__C)';
            objF6.Target_Field__c = 'ParentEmissionSourceId';
            objF6.Target_Field_Type__c = 'Lookup(Scope 3 Emissions Source)';
            objF6.object_mapping__c = obj.id;
            lst.add(objF6);
            
            Field_Mappings__c objF7 = new Field_Mappings__c();
            objF7.Mapping_Included__c= true;
            objF7.New_Field__c = true;
            objF7.Calculated__c = false;
            objF7.Source_Field__c = 'sustain_app__State__c';
            objF7.Source_Field_Type__c = 'Text(128)';
            objF7.Target_Field__c = 'State';
            objF7.Target_Field_Type__c = 'Text(128)';
            objF7.object_mapping__c = obj.id;
            lst.add(objF7);
            
            Field_Mappings__c objF8 = new Field_Mappings__c();
            objF8.Mapping_Included__c= true;
            objF8.New_Field__c = true;
            objF8.Calculated__c = false;
            objF8.Source_Field__c = 'sustain_app__ZipCode__c';
            objF8.Source_Field_Type__c = 'Text(20)';
            objF8.Target_Field__c = 'PostalCode';
            objF8.Target_Field_Type__c = 'Text(20)';
            objF8.object_mapping__c = obj.id;
            lst.add(objF8);
            
            insert lst;
            lst = [select id,Mapping_Included__c,New_Field__c,Calculated__c,Source_Field__c,
                   Source_Field_Type__c,Target_Field__c,Target_Field_Type__c,object_mapping__c,Object_Mapping__r.id,
                   Object_Mapping__r.Source_Object__c,Object_Mapping__r.Source_Record_Type__c,Object_Mapping__r.Target_Object__c,
                   Object_Mapping__r.Target_Record_Type__c,Object_Mapping__r.Mapping_Included__c,Object_Mapping__r.Sequence_Number__c
                   from  Field_Mappings__c];
            
            map<String, list<Object_Mappings__c>> objMap =  new map<String, list<Object_Mappings__c>>();
            string key = obj.Source_Object__c + '-' +obj.Source_Record_Type__c.replaceAll('sustain_app__','').replaceAll('Sustain_app__','');
            objMap.put(key, new list<Object_Mappings__c>{obj});
            fldMap.put(obj.id, lst);
            Sustain_FinalDataLoadBatch nextBatch = new Sustain_FinalDataLoadBatch(objMap, fldMap,21, lstAsset, dataRec1.id);
            Id batchId =  database.executeBatch(nextBatch,  200);
            test.stopTest();
        }
        system.assertNotEquals(u2.Id,null);
        
    }
}