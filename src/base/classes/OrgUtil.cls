/**
 * @description       : Generic class for utility methods 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 12-13-2022
 * @last modified by  : Lavanya Tangati
**/
public class OrgUtil {

    public static String yesterDayOfWeek() {
        return  DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(0, 0, 0, 0)).format('EEEE');
    }

    //map from recordtypeName to recordtypeId
    public static Map<String, Id> getRecordTypeIdByName(Schema.SObjectType token) {
        Map<String, Id> mapRecordTypes = new Map<String, Id>();
        Schema.DescribeSObjectResult obj = token.getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByDeveloperName();
        for (Schema.RecordTypeInfo info : recordTypeInfos.values()) {
            mapRecordTypes.put(info.getDeveloperName(), info.getRecordTypeId());
        }
        return mapRecordTypes;
    }

    public static Set<String> createSetFromPicklistField(String picklistField) { List<String> countriesOfIncorporationList = picklistField != null
        ? picklistField.split(';')
        : new List<String>();

        return new Set<String>(countriesOfIncorporationList);
    }
}