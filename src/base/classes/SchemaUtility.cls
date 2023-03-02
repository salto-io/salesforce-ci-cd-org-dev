public with sharing class SchemaUtility {
    @AuraEnabled
    public static String getSchemaInformation(Boolean isObjectListCall, String objectName) {
        if (isObjectListCall) {
            List<ObjectDefinition> objectDefinitionList = buildObjectDefinitions();
            return JSON.serialize(objectDefinitionList);
        } else {
            List<FieldDefinition> fieldDefinitionList = buildFieldDefinitions(objectName);
            return buildCsvString(fieldDefinitionList);
        }
    }

    public static List<FieldDefinition> buildFieldDefinitions(String objectName) {
        List<FieldDefinition> fieldDefinitionList = new List<FieldDefinition>();
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> fieldDescribeMap = objectType.getDescribe()
            .fields.getMap();

        Set<String> fieldNameList = fieldDescribeMap.keySet();
        for (String fieldName : fieldNameList) {
            DescribeFieldResult fieldDescribeObject = fieldDescribeMap.get(fieldName).getDescribe();
            FieldDefinition fieldDefinitionObject = new FieldDefinition(fieldDescribeObject);
            fieldDefinitionList.add(fieldDefinitionObject);
        }

        return fieldDefinitionList;
    }

    public static List<ObjectDefinition> buildObjectDefinitions() {
        List<ObjectDefinition> objectDefinitionList = new List<ObjectDefinition>();
        Map<String, Schema.SObjectType> objectDescribeMap = Schema.getGlobalDescribe();

        for (String objectName : objectDescribeMap.keySet()) {
            DescribeSObjectResult objectDescribe = objectDescribeMap.get(objectName).getDescribe();
            if (objectDescribe.isQueryable()) {
                objectDefinitionList.add(new ObjectDefinition(objectDescribe));
            }
        }
        return objectDefinitionList;
    }

    public static String buildCsvString(List<FieldDefinition> fieldDefinitionList) {
        String csvString = 'Field Name,Field Label,Field Type,Formula Field?,Sample Value,Controlling Field,Picklist Values,\n';

        for (FieldDefinition fd : fieldDefinitionList) {
            String formulaCheckbox = fd.isFormulaField ? 'X' : '';
            csvString +=
                '"' +
                fd.fieldName +
                '"' +
                ',' +
                fd.fieldLabel +
                ',' +
                fd.fieldType +
                ',' +
                formulaCheckbox +
                ',' +
                '"' +
                fd.sampleValue +
                '"' +
                ',' +
                fd.controllingField +
                ',' +
                '"' +
                String.join(fd.picklistValues, '; ') +
                '"' +
                '\n';
        }

        return csvString;
    }

    public class ObjectDefinition {
        String label;
        String value;

        public ObjectDefinition(DescribeSObjectResult objectDescribe) {
            this.label = objectDescribe.getLabel();
            this.value = objectDescribe.getName();
        }
    }

    public class FieldDefinition {
        public String fieldName;
        public String fieldLabel;
        public String fieldType;
        public String controllingField;
        public List<String> picklistValues;
        public String sampleValue;
        public Boolean isFormulaField;

        public FieldDefinition(DescribeFieldResult fieldDescribeObject) {
            this.fieldName = fieldDescribeObject.getName();
            this.fieldLabel = fieldDescribeObject.getLabel();
            this.fieldType = String.valueOf(fieldDescribeObject.getType());
            this.picklistValues = generatePicklistEntry(fieldDescribeObject, this.fieldType);
            this.sampleValue = getSampleValue(this.fieldType);
            this.isFormulaField = fieldDescribeObject.isCalculated();
            this.controllingField = fieldDescribeObject.getController()?.getDescribe().getName() !=
                null
                ? fieldDescribeObject.getController()?.getDescribe().getName()
                : '';
        }

        private List<String> generatePicklistEntry(
            DescribeFieldResult fieldDescribeObject,
            String fieldTypeVal
        ) {
            List<String> returnValue = new List<String>();
            if (fieldTypeVal == 'Picklist' || fieldTypeVal == 'MultiPicklist') {
                List<Schema.PicklistEntry> picklistSchemaList = fieldDescribeObject.getPicklistValues();
                for (Schema.PicklistEntry picklistSchemaRow : picklistSchemaList) {
                    if (picklistSchemaRow.isActive()) {
                        returnValue.add(picklistSchemaRow.getValue());
                    }
                }
            }
            return returnValue;
        }

        private String getSampleValue(String typeAnalyzed) {
            Map<String, String> typeToSampleValue = new Map<String, String>{
                'BOOLEAN' => 'true/false',
                'DATETIME' => '2022-10-10T12:34:56.000Z',
                'DATE' => '2022-10-10',
                'CURRENCY' => '12.34',
                'PERCENT' => '12.34',
                'INTEGER' => '1234',
                'DOUBLE' => '12.34',
                'PHONE' => '123-456-7890'
            };

            String sampleValue = typeToSampleValue.get(typeAnalyzed) != null
                ? typeToSampleValue.get(typeAnalyzed)
                : '';
            return sampleValue;
        }
    }
}