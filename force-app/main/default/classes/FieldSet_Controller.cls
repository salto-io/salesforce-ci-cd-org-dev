public class FieldSet_Controller {
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        System.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    } 

    public static void useExample(){
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('Account_FieldSet','Account');
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            System.debug('+++ API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
            System.debug('+++ Label ====>' + fieldSetMemberObj.getLabel());
            System.debug('+++ Required ====>' + fieldSetMemberObj.getRequired());
            System.debug('+++ DbRequired ====>' + fieldSetMemberObj.getDbRequired());
            System.debug('+++ Type ====>' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST
        }
    }
    
}