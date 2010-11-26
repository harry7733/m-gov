/*
 * 
 * mgov.java
 * 2010/10/04
 * sodas
 * 
 * Base class of application. Main Activity.
 *
 * Copyright 2010 NTU CSIE Mobile & HCI Lab
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
package tw.edu.ntu.mgov;

import com.google.android.apps.analytics.GoogleAnalyticsTracker;

import android.app.AlertDialog;
import android.app.TabActivity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.widget.TabHost;

import tw.edu.ntu.mgov.GoogleAnalytics.GANAction;
import tw.edu.ntu.mgov.mycase.MyCase;
import tw.edu.ntu.mgov.query.Query;

public class mgov extends TabActivity {
    // Global Constant
	public static final boolean DEBUG_MODE = true;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        // Setup Google Analytics
        GoogleAnalyticsTracker.getInstance().start("UA-19512059-3", 10, this);
        GoogleAnalytics.startTrack(GANAction.GANActionAppOnCreate, null, false, null);
        
        Resources res = getResources(); // Resource object to get Drawables
        TabHost tabHost = getTabHost();  // The activity TabHost
        TabHost.TabSpec spec;  // Reusable TabSpec for each tab
        Intent intent;  // Reusable Intent for each tab

        // Add MyCase Tab
        intent = new Intent().setClass(this, MyCase.class);
        spec = tabHost.newTabSpec("myCaseTab").setIndicator(res.getString(R.string.tabName_myCase), res.getDrawable(R.drawable.ic_tab_mycase)).setContent(intent);
        tabHost.addTab(spec);

        // Add QueryCase Tab
        intent = new Intent().setClass(this, Query.class);
        spec = tabHost.newTabSpec("queryCaseTab").setIndicator(res.getString(R.string.tabName_query), res.getDrawable(R.drawable.ic_tab_query)).setContent(intent);
        tabHost.addTab(spec);
        intent = null;
        
        tabHost.setCurrentTab(0);
    }

	@Override
	protected void onResume() {
		super.onResume();
		if(!mgov.DEBUG_MODE)
			checkNetworkStatus(this, true);
	}

	@Override
	protected void onStop() {
		super.onStop();
		GoogleAnalytics.startTrack(GANAction.GANActionAppOnStop, null, false, null);
	}

	@Override
	protected void onStart() {
		GoogleAnalytics.startTrack(GANAction.GANActionAppOnStart, null, false, null);
		super.onStart();
	}

	@Override
	protected void onDestroy() {
		GoogleAnalytics.startTrack(GANAction.GANActionAppOnDestroy, null, false, null);
		GoogleAnalyticsTracker.getInstance().stop();
		super.onDestroy();
	}
	
	static public boolean checkNetworkStatus(final Context context, boolean alertDialog) {
		ConnectivityManager manager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo networkInfo = manager.getActiveNetworkInfo();
		if (networkInfo == null || !networkInfo.isAvailable()) {
			if (alertDialog) {
				AlertDialog.Builder builder = new AlertDialog.Builder(context);
				builder.setTitle("沒有網路連線")
						.setMessage("此功能需要雲端服務，請開啟網路服務以使用此功能。")
						.setCancelable(false)
						.setPositiveButton("設定網路",
								new DialogInterface.OnClickListener() {
									public void onClick(DialogInterface dialog, int id) {
										Intent intent = new Intent(android.provider.Settings.ACTION_WIRELESS_SETTINGS);
										context.startActivity(intent);
									}
								})
						.setNegativeButton("取消", new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int which) {
								dialog.cancel();
							}
						}).create().show();
			}
			return false;
		}
		
		return true;
	}
}