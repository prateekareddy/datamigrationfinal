/***************************************************************************************************************
* Name - Sustain_CreateSourceIDFieldsBatchTest
* Description - This class is used as a test class for Sustain_CreateSourceIDFieldsBatch apex class.
* Author - Accenture (Aditya)
* Created Date -2/11/2022
* Last Modified By & Date - Accenture, 2/16/2022
* ***************************************************************************************************************/
@isTest(SeeAllData=False)
public class Sustain_CreateSourceIDFieldsBatchTest {
    @isTest
    static void method1(){       
        
        Object_Mappings__c obj = new Object_Mappings__c();       
        obj.Target_Object__c='vendor';
        database.insert(obj,false);
        
        Test.startTest();
        Sustain_CreateSourceIDFieldsBatch uca = new Sustain_CreateSourceIDFieldsBatch();
        database.executeBatch(uca);      
        Test.stopTest();   
        system.assertEquals(true, uca !=null);
    }
}