public with sharing class S1PageLayoutCompController {
    
    transient Id recordId;
    transient String objName;
    transient SObject obj;
    transient List<Schema.FieldSetMember> fields;

    public S1PageLayoutCompController() {
        
    }

    public void setRecordId(Id inId){
        recordId = inId;
    }

    public Id getRecordId(){
        return recordId;
    }

     public List<Schema.FieldSetMember> getFields(){
        Schema.SObjectType ot = recordId.getSobjectType();
        Schema.DescribeSObjectResult odr = ot.getDescribe();
        Map<String, Schema.FieldSet> fsMap = odr.fieldSets.getMap();
        objName = odr.getName();
        //List<Schema.RecordTypeInfo> rtInfos = odr.getRecordTypeInfos();
        Map<Id,Schema.RecordTypeInfo> rtInfos = odr.getRecordTypeInfosById();
        String recordTypeName='';
        
        if(rtInfos.size()>1){
            try{
                String q = 'SELECT RecordTypeId FROM ' + objName + ' WHERE Id=:recordId LIMIT 1';
                sObject sq = Database.query(q);
                //recordTypeName = (String) sq.getSObject('RecordTypeId').get('Name');
                recordTypeName = (String) rtInfos.get((Id)sq.get('RecordTypeId')).getName();
            }catch(Exception e){
                recordTypeName = '';
            }    
        }
        
        Id profileId = UserInfo.getProfileId();
        Profile prf = [Select Name from Profile where id=:profileId LIMIT 1];
        
        List<S1PageLayoutConfig__mdt> config = [SELECT Field_Set_Name__c
                                                    FROM S1PageLayoutConfig__mdt WHERE Object__c =:objName AND
                                                    Profile_Name__c=:prf.Name AND  Record_Type__c=:recordTypeName];
        
        
        if(config.size()<1){
            config = [SELECT Field_Set_Name__c FROM S1PageLayoutConfig__mdt WHERE Object__c =:objName AND
                                                    Profile_Name__c=:prf.Name AND Record_Type__c=''];
        }
        
        if(config.size()<1){
            config = [SELECT Field_Set_Name__c FROM S1PageLayoutConfig__mdt WHERE Object__c =:objName AND
                                                    Profile_Name__c=:'' AND Record_Type__c=''];
        }
        
        if(config.size()>0){
            Schema.FieldSet fSet = fsMap.get(config[0].Field_Set_Name__c);
            fields = fSet.getFields();
        }
        return fields;
    } 

    public SObject getObj(){
        Schema.SObjectType ot = recordId.getSobjectType();
        Schema.DescribeSObjectResult odr = ot.getDescribe();

        // Frame Dynamic SQL
        String fieldList = '';
        for(Schema.FieldSetMember fm:fields){
            fieldList +=  fm.getFieldPath() + ',';
        }
        if(fieldList.endsWith(',')){
                fieldList = fieldList.substring(0,fieldList.lastIndexOf(','));
        }

        String sQuery = 'SELECT ' + fieldList + ' FROM ' +  objName + ' WHERE Id=:recordId';

        List<SObject> objs = Database.query(sQuery);
        
        if(objs.size()>0){
            return objs[0];
        }else{
            return null;
        }
    }
   


}