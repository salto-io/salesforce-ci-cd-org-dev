public class GDM_JSON {

	public List<String> destination_addresses;
	public List<String> origin_addresses;
	public List<Rows> rows;
	public String status;
    
    public class Elements {
		public Distance distance;
		public Distance duration;
		public String status;
	}

	public class Distance {
		public String text;
		public Integer value;
	}

	public class Rows {
		public List<Elements> elements;
	}

	
	public static GDM_JSON parse(String json) {
		return (GDM_JSON) System.JSON.deserialize(json, GDM_JSON.class);
	}
}