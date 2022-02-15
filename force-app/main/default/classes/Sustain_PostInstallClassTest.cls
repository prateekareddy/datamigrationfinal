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
        //system.assertEquals(false, obj !=null && obj.size()>0);
        
    }
}