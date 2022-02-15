/***************************************************************************************************************
* Name - Sustain_OrgScanOutputCtrlTest
* Description - This class is used as a test class for Sustain_OrgScanOutputCtrl apex class.
* Author - Accenture (Bindhyachal)
* Created Date -9/1/2021
* Last Modified By & Date - Accenture, 9/1/2021
* ***************************************************************************************************************/

@isTest(SeeAllData=False)
private class Sustain_OrgScanOutputCtrlTest{
    static testMethod void validateFetchOrgScanDetails() {         
        OrgScanOutputWrapper osw;
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
            Test.startTest();
            osw = Sustain_OrgScanOutputCtrl.fetchOrgScanDetails();
            Test.stopTest();
        }
        System.assertEquals(osw != null, true);
    }  
}