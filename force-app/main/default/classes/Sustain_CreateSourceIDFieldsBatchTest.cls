@isTest
public class Sustain_CreateSourceIDFieldsBatchTest {
@isTest
    static void method1(){
       
      
        Object_Mappings__c ab = new Object_Mappings__c();
       
        ab.Target_Object__c='vendor';
        database.insert(ab,false);
        Test.startTest();
        Sustain_CreateSourceIDFieldsBatch obj = new Sustain_CreateSourceIDFieldsBatch();
        database.executeBatch(obj);
      
        Test.stopTest();
        
        
    }
}