trigger AccountTrigger on Account (before update) {
    AccountController.updateCustomerClassification(trigger.new, trigger.oldMap);
}