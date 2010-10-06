package tw.edu.ntu.mgov.gae;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class GAECase extends HashMap<String, String>{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	ArrayList<String> image;
	
	public GAECase(){
		super();
		image = new ArrayList<String>();
	}
	
	@SuppressWarnings("unchecked")
	public GAECase(JSONObject json) throws JSONException {
		super();
		
		Iterator<String> it = json.keys();
		while (it.hasNext()) {
			String key = it.next();
			if("image".equals(key)){
				JSONArray array = json.getJSONArray(key);
				for(int i=0;i<array.length();i++){
					image.add(array.getString(i));
				}
			}
			else if("coordinates".equals(key)){
				JSONArray array = json.getJSONArray(key);
				this.put("coordx", array.getString(0));
				this.put("coordy", array.getString(1));
			}
			this.put(key, json.getString(key));
		}
	}

	public void addform(String key,String value){
		this.put(key, value);
	}
	
	public String getform(String key){
		return this.get(key);
	}

	public void addImage(String photo){
		this.image.add(photo);
	}	

	public String[] getImage(){
		return (String[]) image.toArray();
	}


}
/*
image 下載URL
photo 上傳檔案路徑

 */