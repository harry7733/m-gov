package ecoliving;

import java.util.Iterator;
import java.util.List;

import gae.GAENodeSimple;
import gae.PMF;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.json.JSONArray;

@Path("/list")
public class ListAll {

	@SuppressWarnings("unchecked")
	@GET
	@Produces(MediaType.TEXT_PLAIN)
	public static String go() {
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Query query = pm.newQuery(GAENodeSimple.class);

		List<GAENodeSimple> list = (List<GAENodeSimple>) query.execute();
		
		JSONArray array = new JSONArray();
		
		for(GAENodeSimple ob:list){
			array.put(ob.toJson());
			System.out.print(ob.toJson());
		}
		return array.toString() + "\nsize: " +list.size();
	}

}
