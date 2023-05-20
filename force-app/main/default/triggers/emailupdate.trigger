trigger emailupdate on Student_Center__c (before insert, before update) {
    for(Student_Center__c c1 : Trigger.new)  
        if(Trigger.isInsert && c1.Student_Email__c == NULL)
        c1.addError('Please provide valid email');
        else if (Trigger.isUpdate && c1.Student_Email__c == NULL)
        c1.addError('Updated record must have a valid email to be saved');
    for(Student_Center__c c2 : Trigger.new)
    	if(Trigger.isInsert && c2.Course__c == NULL)
        c2.addError('Please Select the Department');
        else if (Trigger.isUpdate && c2.Course__c == NULL)
        c2.addError('Updated record must have a valid Department Selected to be saved');
}