@isTest
public class Sustain_CreateVendorRecordBatchTest {
    @isTest
    static void method1(){
        List<sustain_app__EnergyConsumption__c> listobj  = new List<sustain_app__EnergyConsumption__c>();
        Id accountRecordTypeId = Schema.SObjectType.sustain_app__EnergyConsumption__c.getRecordTypeInfosByName().get('Private Jet').getRecordTypeId();
        System.debug(accountRecordTypeId);
         Vendor__c vend=new Vendor__c();
         //name
        //vend.Name='United Airlines';
        vend.Vendor_Name__c = 'sample name';
        insert vend;
       sustain_app__EnergyConsumption__c obj = new sustain_app__EnergyConsumption__c();
       obj.RecordTypeId =  accountRecordTypeId;
       
        obj.Name = 'adi';
        
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
        
        Test.startTest();
        Sustain_CreateVendorRecordBatch obj1 = new Sustain_CreateVendorRecordBatch(2);
        database.executeBatch(obj1);
        
        
        Test.stopTest();
    }
    
    
  
}