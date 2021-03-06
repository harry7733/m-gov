/*
 * 
 * MyCase.java
 * 2010/10/04
 * sodas
 * 
 * Show user's case and call case adder
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
package tw.edu.ntu.mgov1999.mycase;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.RelativeLayout.LayoutParams;
import tw.edu.ntu.mgov1999.R;
import tw.edu.ntu.mgov1999.CaseSelector;
import tw.edu.ntu.mgov1999.GoogleAnalytics;
import tw.edu.ntu.mgov1999.mgov;
import tw.edu.ntu.mgov1999.GoogleAnalytics.GANAction;
import tw.edu.ntu.mgov1999.addcase.AddCase;
import tw.edu.ntu.mgov1999.gae.GAEQuery;
import tw.edu.ntu.mgov1999.gae.GAEQuery.GAEQueryCondtionType;
import tw.edu.ntu.mgov1999.gae.GAEQuery.GAEQueryDatabase;
import tw.edu.ntu.mgov1999.option.Option;

public class MyCase extends CaseSelector {
	protected static final int FILTER_TITLE = 10240;
	protected static final int REQUEST_CODE_ADDCASE = 10246;
	// Menu
	protected static final int MENU_AddCase = Menu.FIRST+3;
	protected static final int MENU_SetFilter = Menu.FIRST+4;
	// Preference
	private SharedPreferences userPreferences;
	// Data source
	private int statusId = -1;
	String[] filterType;
	// UI
	TextView filterState;
	TextView filterTitle;
	// Time Difference
	long onPauseTime;
	/**
	 * @category Life cycle
	 */
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// Empty Query for GAE speed
		Thread dummyQuery = new Thread(new Runnable() {
			@Override
			public void run() {
				GAEQuery qGAEtmp = new GAEQuery();
				qGAEtmp.addQuery(GAEQueryCondtionType.GAEQueryByEmail, "a@b.c");
				qGAEtmp.doQuery(GAEQueryDatabase.GAEQueryDatabaseCase, 0, 1);
				qGAEtmp = null;
			}
		});
		dummyQuery.start();
		
		super.onCreate(savedInstanceState);
		db=GAEQueryDatabase.GAEQueryDatabaseCase;
		// Fetch Preference
		userPreferences = getSharedPreferences(Option.PREFERENCE_NAME, MODE_WORLD_READABLE);
		
		filterTitle = new TextView(this);
		filterTitle.setId(FILTER_TITLE);
		filterTitle.setText(userPreferences.getString(Option.KEY_USER_EMAIL, ""));
		filterTitle.setPadding(2, 0, 2, 0);
		filterTitle.setTextSize(16.0f);
		filterTitle.setTypeface(Typeface.DEFAULT_BOLD);
		LayoutParams param1 = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		param1.addRule(RelativeLayout.ALIGN_PARENT_LEFT, RelativeLayout.ALIGN_PARENT_TOP);
		filterTitle.setLayoutParams(param1);
		infoBar.addView(filterTitle);
		param1=null;
		
		filterState = new TextView(this);
		if (userPreferences.getString(Option.KEY_USER_EMAIL, "")=="")
			filterState.setText("");
		else
			filterState.setText(getResources().getString(R.string.mycase_filter_allcase));
		filterState.setPadding(2, 0, 2, 0);
		filterState.setTextSize(14.0f);
		LayoutParams param2 = new RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
		param2.addRule(RelativeLayout.BELOW, FILTER_TITLE);
		param2.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
		filterState.setLayoutParams(param2);
		infoBar.addView(filterState);
		param2=null;
		
		rangeEnd = 1000;
	}
	@Override
	protected void onResume() {
		statusId=-1;
		filterTitle.setText(userPreferences.getString(Option.KEY_USER_EMAIL, ""));
		if (mgov.firstTimeMyCase) {
			// First Startup
			startFetchDataSource();
			mgov.firstTimeMyCase = false;
		} else {
			// Reload between 10 mins.
			if ((System.currentTimeMillis()-onPauseTime) > 10*60*1000)
				startFetchDataSource();
		}
		super.onResume();
	}
	
	@Override
	protected void onPause() {
		onPauseTime = System.currentTimeMillis();
		super.onPause();
	}
	/**
	 * @category Menu
	 */
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		menu.add(0, MENU_AddCase, 0, getResources().getString(R.string.menu_myCase_addCase)).setIcon(android.R.drawable.ic_menu_add);
		menu.add(0, MENU_SetFilter, 0, getResources().getString(R.string.mycase_filter_selectFilter)).setIcon(R.drawable.menu_type);
		return super.onCreateOptionsMenu(menu);
	}
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == MENU_AddCase || item.getItemId() == MENU_SetFilter)
			this.menuActionToTake(item);
		return super.onOptionsItemSelected(item);
	}
	@Override
	public void menuActionToTake(MenuItem item) {
		if	(item.getItemId()==MENU_AddCase) {
			Intent caseAdderIntent = new Intent().setClass(this, AddCase.class);
			startActivityForResult(caseAdderIntent, REQUEST_CODE_ADDCASE);
		} else if (item.getItemId()==MENU_SetFilter) {
			AlertDialog.Builder builder = new AlertDialog.Builder(selfContext);
			
			builder.setCancelable(true);
			builder.setTitle(getResources().getString(R.string.mycase_filter_selectFilter));
			filterType = new String[] {getResources().getString(R.string.mycase_filter_allcase), getResources().getString(R.string.mycase_filter_finished),
					getResources().getString(R.string.mycase_filter_unknown), getResources().getString(R.string.mycase_filter_rejected)};
			builder.setItems( filterType, new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					switch(which) {
						case 0:
							statusId = -1;
							filterState.setText(filterType[0]);
							GoogleAnalytics.startTrack(GANAction.GANActionMyCaseFilterAll, null, false, null);
							startFetchDataSource();
							break;
						case 1:
							statusId = 1;
							filterState.setText(filterType[1]);
							GoogleAnalytics.startTrack(GANAction.GANActionMyCaseFilterOK, null, false, null);
							startFetchDataSource();
							break;
						case 2:
							statusId = 0;
							filterState.setText(filterType[2]);
							GoogleAnalytics.startTrack(GANAction.GANActionMyCaseFilterUnknown, null, false, null);
							startFetchDataSource();
							break;
						case 3:
							statusId = 2;
							filterState.setText(filterType[3]);
							GoogleAnalytics.startTrack(GANAction.GANActionMyCaseFilterFailed, null, false, null);
							startFetchDataSource();
							break;
					}
				}
			});
			builder.create().show();
		}
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode==REQUEST_CODE_OPTION) {
			GoogleAnalytics.startTrack(GANAction.GANActionAppTabIsMyCase, null, false, null);
			startFetchDataSource();
		}
		if (requestCode==REQUEST_CODE_ADDCASE && resultCode==AddCase.RESULT_CODE_SUMBITTED) {
			startFetchDataSource();
		}
		super.onActivityResult(requestCode, resultCode, data);
	}
	
	@Override
	protected void changCaseSelectorMode(CaseSelectorMode targetMode) {
		super.changCaseSelectorMode(targetMode);
		if (currentMode == CaseSelectorMode.CaseSelectorMapMode)
			GoogleAnalytics.startTrack(GANAction.GANActionMyCaseMapMode, null, false, null);
		else
			GoogleAnalytics.startTrack(GANAction.GANActionMyCaseListMode, null, false, null);
	}
	
	/**
	 * @category Datasource Method
	 */
	protected boolean setQGAECondition() {
		// Update Pref
		userPreferences = getSharedPreferences(Option.PREFERENCE_NAME, MODE_WORLD_READABLE);
		String userEmail = userPreferences.getString(Option.KEY_USER_EMAIL, "");
		if (userEmail!="" || userEmail!=null) {
			qGAE.addQuery(GAEQueryCondtionType.GAEQueryByEmail, userEmail);
			if (statusId!=-1)
				qGAE.addQuery(GAEQueryCondtionType.GAEQueryByStatus, Integer.toString(statusId));
			return true;
		} else {
			return false;
		}
	}
	protected void qGAEReturnNull() {
		
	}
	protected void qGAEReturnData() {
		switch(statusId) {
		case -1:
			filterState.setText(getResources().getString(R.string.mycase_filter_allcase));
			break;
		case 1:
			filterState.setText(getResources().getString(R.string.mycase_filter_finished));
			break;
		case 0:
			filterState.setText(getResources().getString(R.string.mycase_filter_unknown));
			break;
		case 2:
			filterState.setText(getResources().getString(R.string.mycase_filter_rejected));
		}
	}
}

