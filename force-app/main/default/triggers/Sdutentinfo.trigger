trigger Sdutentinfo on Student_Center__c (before insert,after insert,before update,before delete,after update,after delete,after undelete) 
{
     if(trigger.isbefore){
        if(trigger.isinsert){
            
             system.debug('Before insert');
        }
        if(trigger.isupdate){
            
            system.debug('Before update');
        }
        if(trigger.isdelete){
            system.debug('Before delete');
            
        }
    
   
    }
    if(trigger.isafter)
    {
        if(trigger.isinsert){
             system.debug('After insert');
        }
        if(trigger.isupdate){
             system.debug('After update');
        }
        if(trigger.isdelete){
             system.debug('After delete');
        }
        if(trigger.isundelete){
             system.debug('After undelete');
        }
        
    }
}