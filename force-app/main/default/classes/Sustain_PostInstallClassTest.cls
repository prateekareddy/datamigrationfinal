/***************************************************************************************************************
* Name - Sustain_PostInstallClassTest
* Description - This class is used as a test class for Sustain_PostInstallClass apex class.
* Author - Accenture (Prateeka)
* Created Date -9/19/2021
* Last Modified By & Date - Accenture, 2/16/2022
* ***************************************************************************************************************/
@isTest(SeeAllData=False)
private class Sustain_PostInstallClassTest {
    static testMethod void testInstallScript() {
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){   
            Sustain_PostInstallClass postinstall = new Sustain_PostInstallClass();
            Test.testInstall(postinstall, null);
            Test.testInstall(postinstall, new Version(1,0), true);
        }
        list<Object_Mappings__c> obj=[select Id from Object_Mappings__c];    
        system.assertEquals(true, obj !=null);
    }
}