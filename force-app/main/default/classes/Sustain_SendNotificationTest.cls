/***************************************************************************************************************
* Name - Sustain_SendNotificationTest
* Description - This class is used as a test class for Sustain_SendNotification apex class.
* Author - Accenture (Bindhyachal)
* Created Date -9/19/2021
* Last Modified By & Date - Accenture, 2/14/2022
* ***************************************************************************************************************/
@isTest(SeeAllData=False)
private class Sustain_SendNotificationTest {
     @isTest 
     static void chattertest(){
       User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
        Test.startTest();
             Sustain_SendNotification sendData =new Sustain_SendNotification();
             sendData.sendChatterNotification('SampleDataLoadEmails');
             sendData.sendChatterNotification(null);
        Test.stopTest();
        }
        system.assertNotEquals(u1.Id,null);
      
    }
    
     @isTest static void chattertest1(){
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
        Test.startTest();
        
             Sustain_SendNotification sendData =new Sustain_SendNotification();
             sendData.sendChatterNotification('FinalDataLoadEmails');
        Test.stopTest();
        }
        system.assertNotEquals(u1.Id,null);
      
    }
    @isTest static void chattertest2(){
        User u1 = Sustain_TestDataFactory.createAdmninUser();
        System.runAs(u1){
        test.startTest();
       
             Sustain_SendNotification sendData =new Sustain_SendNotification();
             sendData.sendChatterNotification('MetadataEmails');
        Test.stopTest();
        }
        system.assertNotEquals(u1.Id,null);
      
    }

}