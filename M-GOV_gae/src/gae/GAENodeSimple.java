package gae;

import javax.jdo.annotations.IdentityType;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import org.json.JSONException;
import org.json.JSONObject;

@PersistenceCapable(identityType = IdentityType.APPLICATION)
public class GAENodeSimple implements Comparable<GAENodeSimple>{

	@PrimaryKey
	@Persistent
	private String key;
	@Persistent
	public String typeid;
	@Persistent
	public String date;
	@Persistent
	public String status;
	@Persistent
	public String address;
	@Persistent
	public String email;

	@Persistent
	public double coordx,coordy;


	public GAENodeSimple(){}
	
	public GAENodeSimple(String key, String typeid, String date,
			String coordinates, String status, String address, String email) {
		this.key = key;
		this.typeid = typeid;
		this.date = date;
		
		String str[]=coordinates.split(",");
		
		double d1=Double.parseDouble(str[0]);
		double d2=Double.parseDouble(str[1]);

		this.coordx=d1;
		this.coordy=d2;
		this.status = status;
		this.address = address;
		this.email = email;
	}

	public String getKey() {
		return key;
	}

	public JSONObject toJson() {
		try {

			JSONObject o = new JSONObject();
			o.accumulate("key", key);
			o.accumulate("coordinates", coordx);
			o.accumulate("coordinates", coordy);

			o.accumulate("date", date);
			o.accumulate("typeid", typeid);
			o.accumulate("status", status);
			o.accumulate("address",address);
				
			return o;
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}
	
	public GAENodeSimple clone(){
		GAENodeSimple e = new GAENodeSimple();
		e.key = key ;
		e.typeid = typeid;
		e.date = date;
		e.coordx = coordx;
		e.coordy = coordy;

		e.status = status;
		e.address = address;
		return e;
	}

	@Override
	public String toString() {
		return toJson().toString();
	}

	@Override
	public int compareTo(GAENodeSimple o) {
		// TODO Auto-generated method stub
		String[] c1 = o.date.split("年|月|日");
		String[] c2 = this.date.split("年|月|日");
		for(int i=0;i<c1.length && i<c2.length;i++)
			if(Integer.parseInt(c1[i])!=Integer.parseInt(c2[i]))
				return Integer.parseInt(c1[i])-Integer.parseInt(c2[i]);
		return 0;
	}
}
