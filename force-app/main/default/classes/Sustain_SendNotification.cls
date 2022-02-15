/**
 * @description       : 
 * @author            : Accenture
 * @group             : 
 * @last modified on  : 09-23-2021
 * @last modified by  : Accenture
**/
public without sharing class Sustain_SendNotification {
    private static final string sampleLoadEmailsLabel='SampleDataLoadEmails';
    private static final string finalLoadEmailsLabel='FinalDataLoadEmails';
    private static final string CurrentClassName = 'Sustain_SendNotification';
    
    /*Method Name : sendChatterNotification 
*Description : This method is used to send the notification to the user
*/
    public  void sendChatterNotification(String type){
        string CurrentMethodName = 'sendChatterNotification';
        try{
            Id typeId = [SELECT Id FROM CUstomNotificationType WHERE DeveloperName = 'Notification'].Id;
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            if(sampleLoadEmailsLabel.equalsIgnoreCase(type)){
                notification.setBody(System.Label.Sustain_SampleDataLoadEmails);
                notification.setTitle('SampleDataLoadEmails');
            }else if(finalLoadEmailsLabel.equalsIgnoreCase(type)){
                notification.setBody(System.Label.Sustain_FinalDataLoadEmails);
                notification.setTitle('FinalDataLoadEmails');
            }else{
                notification.setBody(System.Label.Sustain_MetadataEmails);
                notification.setTitle('MetadataEmails');
            }
            notification.setSenderId(Userinfo.getUserId());
            notification.setNotificationTypeId(typeId );
            notification.setTargetId(Userinfo.getUserId()); 
            notification.send(new Set<String> { Userinfo.getUserId() }); 
        }catch(Exception ex){
            system.debug('Error : '+ex.getMessage());
            Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName);
        }
    }
    
    /*Method Name : sendEmailNotification 
*Description : This method is used to send the email to the user
*/   
    public void sendEmailNotification(String templateName,List<String> toAddress) {
        string CurrentMethodName = 'sendEmailNotification';
        try{            
            List<OrgWideEmailAddress> owea = [select Id, Address, DisplayName, Purpose from OrgWideEmailAddress where Purpose =:'DefaultNoreply' AND 
                    DisplayName = 'Salesforce Support' limit 1];

            EmailTemplate template =[Select id,name,body, Subject from EmailTemplate where developername = :templateName limit 1];
            
            Messaging.SingleEmailMessage  email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(userInfo.getUserId());
            email.setTemplateId(template.id);
            email.setToAddresses(toAddress);
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(owea[0].id);
            email.setSubject(template.Subject);
            String emailBody = template.Body;
            emailBody = emailBody.Replace('UserName',userInfo.getName());
            emailBody = emailBody.Replace('Name of USER','Salesforce Support');
            email.setPlainTextBody(emailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }catch(Exception ex){
            system.debug('Error : '+ex.getMessage());
            Sustain_UtilityError.createErrorLog(ex, CurrentClassName, CurrentMethodName);
        }
    }
    
}