package gae;

import javax.jdo.PersistenceManager;

public class GAEDateBase {
	
	public static void store(GAENode node) {
		PersistenceManager pm;
		pm = PMF.get().getPersistenceManager();
		pm.makePersistent(node);
		pm.close();
	}

	public static void store(GAENodeSimple node) {
		PersistenceManager pm;
		pm = PMF.get().getPersistenceManager();
		pm.makePersistent(node);
		pm.close();
	}

	public static void store(Object ob) {
		PersistenceManager pm;
		pm = PMF.get().getPersistenceManager();
		pm.makePersistent(ob);
		pm.close();
	}
}
