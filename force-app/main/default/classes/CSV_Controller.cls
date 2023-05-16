public class CSV_Controller{

    private static Map<Integer,String> mapColumnNo_ObjField = new Map<Integer,String>();

    @AuraEnabled
	public static String processData(String fileId){
        System.debug('+++ Method ProcessData');
        System.debug('+++ fileId: ' + fileId);

        CSV_Settings__mdt custom_csvMetadata = [SELECT Send_Report_To__c, SObjectType__c FROM CSV_Settings__mdt LIMIT 1];
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(custom_csvMetadata.SObjectType__c);
        String str_fields = 'Applifly Client-ID,na,c/o Abteilung,Ansprechperson Vorname,Ansprechperson Nachname,Strasse,PLZ,Ort,Kauf-Datum,Faktura-Datum,Leistungsperiode,Rabatt-Betrag exkl. MWST,RG-Nr. zu Gutschrift,Produkt-Bezeichnung,Positionsbeschreibung 1,Produktetyp,Menge bestellt,Einzelpreis exkl MWST,Keine Verrechnung,Einzelpreis inkl. MWST	Hauptempf. E-Mail Adr.	Anrede Hauptempf. E-Mail Adr.	CC1 Empf. E-Mail Adr.	CC2 Empf. E-Mail Adr.	CC3 Empf. E-Mail Adr.	Link Sharepoint	Opportunity-ID Salesforce Lightning';
        List<String> fields = new List<String>();


        //ContentDocument file = [SELECT Id,Title FROM ContentDocument WHERE Id = '0691t00000cq7oJAAQ'];
        ContentVersion file_content = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :fileId AND IsLatest = true];
        String csv_str = EncodingUtil.base64Encode(file_content.VersionData);
        CSVObject csvObj = getCSVObject(csv_str);

        createRecords(csv_str, targetType, fields);

        System.debug('+++ CSV Obj: ' + csvObj);
        return 'file.Title';
    }


    @AuraEnabled
    public static CSVObject getCSVObject(String csv_str) {
        List<String> lines_raw = csv_str.split('\n');
        List<String> headers_raw = separateCommas(lines_raw[0]);
        List<List<String>> lines = new List<List<String>>();
        List<CSVHeader> headers = new List<CSVHeader>();

        lines_raw.remove(0);

		//Handling fields with commas

        for(String line : lines_raw) {
            List<String> line_sep = separateCommas(line);
            List<String> fields = new List<String>();
            Boolean makeCompositeField = false;
            String compositeField;
            for(String field : line_sep) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    fields.add(field.trim());
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    fields.add(compositeField.trim());
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    fields.add(field.trim());
                }
            }
            lines.add(fields);
        }

        for(String header : headers_raw) {
            headers.add(new CSVHeader(header));
        }

        return new CSVObject(headers, lines);
    }


    private static List<String> separateCommas(String input){
        List<String> results = input.split(',');

        for(String result : results) {
            result = result.trim();
        }

        return results;
    }


    public class CSVHeader  {

        @AuraEnabled
        public String column_name {get; set;}
    
        @AuraEnabled
        public String column_type {get; set;}
    
        public CSVHeader(String column_name, String column_type) {
            this.column_name = column_name;
            this.column_type = column_type;
        } 
    
        public CSVHeader(String column_name) {
            this.column_name = column_name;
            this.column_type = '';
        }
    }


    public class CSVObject  {
        @AuraEnabled
        public List<CSVHeader> headers {get; set;}
    
        @AuraEnabled
        public List<List<String>> lines {get; set;}
    
        @AuraEnabled
        public Integer line_count {get; set;}
    
        public CSVObject() {}
    
        public CSVObject(List<CSVHeader> headers, List<List<String>> lines) {
            this.headers = headers;
            this.lines = lines;
            this.line_count = lines.size();
        }
    }



	public static void createRecords(String fileData, Schema.SObjectType targetType, List<String> fields){

		try{
			if (fileData != null){
				String[] fileLines = new String[]{};
				fileLines = fileData.split('\n');
				//for content
				List<sObject> myList = new List<sObject>();
				for (Integer i = 1; i < fileLines.size(); i++){
					String[] inputvalues = new String[]{};
					inputvalues = fileLines[i].split(',');
					sObject obj = targetType.newSObject();
					Integer rowsize = inputvalues.size();
					for (Integer l = 0; l < rowsize - 1; l++){
						system.debug('fields.get(l)' + fields.get(l));
						if (String.isNotBlank(inputvalues[l])){
							String value = inputvalues[l].length() > 255 ? inputvalues[l].substring(0, 254) : inputvalues[l];
							obj.put(fields.get(l), value);
						} else{
							obj.put(fields.get(l), '');
						}
					}
					myList.add(obj);
				}
				insert myList;
			}
		} catch (Exception e){
			System.debug('exception' + e);
		}
	}
}