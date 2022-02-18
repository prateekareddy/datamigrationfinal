/***************************************************************************************************************
* Name - CreateVendorRecordBatchTest
* Description - This class is used as a test class for CreateVendorRecordBatch apex class.
* Author - Accenture (Aditya)
* Created Date -2/11/2022
* Last Modified By & Date - Accenture, 2/16/2022
* ***************************************************************************************************************/
@isTest(SeeAllData=False)
public class Sustain_CreateVendorRecordBatchTest {
    static testMethod void method1(){
        List<sustain_app__EnergyConsumption__c> listobj  = new List<sustain_app__EnergyConsumption__c>();
        Id accountRecordTypeId = Schema.SObjectType.sustain_app__EnergyConsumption__c.getRecordTypeInfosByName().get('Private Jet').getRecordTypeId();
        System.debug(accountRecordTypeId);
        Vendor__c vend=new Vendor__c();
        vend.Vendor_Name__c = 'sample name';
        insert vend;
        
        sustain_app__EnergyConsumption__c obj = new sustain_app__EnergyConsumption__c();
        obj.RecordTypeId =  accountRecordTypeId;
        obj.Name = 'obj_name';
        obj.sustain_app__VendorName__c='United Airlines';
        listobj.add(obj);
        database.insert(listobj,false);
        
        List<String> lstcons=new List<String>();
        lstcons.add(obj.Name);
        List<String> lstvend=new List<String>();
        lstvend.add(vend.Name);
        
        sustain_app__ServiceProvider__c pro=new sustain_app__ServiceProvider__c();
        pro.Name='United Airlines';
        insert pro;
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
            Test.startTest();
            Sustain_CreateVendorRecordBatch uca = new Sustain_CreateVendorRecordBatch(2, null, userInfo.getOrganizationId());
            Id batchId = Database.executeBatch(uca);
            Test.stopTest();
            system.assertNotEquals(null, batchId);
        }         
    }
}