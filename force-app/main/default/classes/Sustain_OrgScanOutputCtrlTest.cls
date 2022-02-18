/***************************************************************************************************************
* Name - Sustain_OrgScanOutputCtrlTest
* Description - This class is used as a test class for Sustain_OrgScanOutputCtrl apex class.
* Author - Accenture (Bindhyachal)
* Created Date -9/19/2021
* Last Modified By & Date - Accenture, 2/14/2022
* ***************************************************************************************************************/
@isTest(SeeAllData=False)
private class Sustain_OrgScanOutputCtrlTest{
    static testMethod void validateFetchOrgScanDetails() {         
        OrgScanOutputWrapper osw;
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
            Test.startTest();
            osw = Sustain_OrgScanOutputCtrl.fetchOrgScanDetails();
            Sustain_OrgScanOutputCtrl.getListViews();
            Test.stopTest();
        }
        System.assertEquals(osw != null, true);
    }  
}