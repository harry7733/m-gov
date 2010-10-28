/**
 * 
 */
package tw.edu.ntu.mgov.query;

import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;
import tw.edu.ntu.mgov.CaseSelector;
import tw.edu.ntu.mgov.R;
import tw.edu.ntu.mgov.gae.GAEQuery.GAEQueryCondtionType;
import tw.edu.ntu.mgov.gae.GAEQuery.GAEQueryDatabase;
import tw.edu.ntu.mgov.typeselector.QidToDescription;
import tw.edu.ntu.mgov.typeselector.TypeSelector;

/**
 * @author sodas
 * 2010/10/4
 * @company NTU CSIE Mobile HCI Lab
 */
public class Query extends CaseSelector {
	// Constant
	protected static final int MENU_SetTypeCondition = Menu.FIRST+3;
	protected static final int MENU_AllTypeCondition = Menu.FIRST+4;
	private static final int REQUEST_CODE_typeSelector = 1630;
	private static final int CURRENT_CONDITION_LABEL = 2048;
	private static final int NEXT_BUTTON = 2049;
	
	// UI
	private TextView currentConditionLabel;
	private TextView currentRangeLabel;
	// Datasource
	private int typeId = 0;
	
	// Lifecycle
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// Did not show noCase Image
		noCaseImageWillShow = false;
		db = GAEQueryDatabase.GAEQueryDatabaseCzone;
		// Set Mode before super class execute its method
		this.defaultMode = CaseSelectorMode.CaseSelectorMapMode;
		// Render the list and map by super method
		super.onCreate(savedInstanceState);
		
		currentConditionLabel = new TextView(this);
		currentConditionLabel.setId(CURRENT_CONDITION_LABEL);
		currentConditionLabel.setText(getResources().getString(R.string.query_currentConditionLabel_alltype));
		currentConditionLabel.setPadding(2, 0, 2, 0);
		currentConditionLabel.setTextSize(16.0f);
		currentConditionLabel.setTypeface(Typeface.DEFAULT_BOLD);
		LayoutParams param1 = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		param1.addRule(RelativeLayout.CENTER_HORIZONTAL, RelativeLayout.ALIGN_PARENT_TOP);
		currentConditionLabel.setLayoutParams(param1);
		infoBar.addView(currentConditionLabel);
		param1=null;
		
		currentRangeLabel = new TextView(this);
		currentRangeLabel.setText(getResources().getString(R.string.query_currentRangeLabel_emptyCase));
		currentRangeLabel.setPadding(2, 0, 2, 0);
		currentRangeLabel.setTextSize(14.0f);
		currentRangeLabel.setGravity(Gravity.CENTER_HORIZONTAL);
		LayoutParams param2 = new RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
		param2.addRule(RelativeLayout.BELOW, CURRENT_CONDITION_LABEL);
		param2.addRule(RelativeLayout.CENTER_HORIZONTAL);
		currentRangeLabel.setLayoutParams(param2);
		infoBar.addView(currentRangeLabel);
		param2=null;
		
		ImageButton nextButton = new ImageButton(this);
		nextButton.setImageResource(R.drawable.next);
		nextButton.setBackgroundResource(R.color.transparentColor);
		nextButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) { 
            	if (rangeEnd+10 < sourceLength-1) {
            		rangeStart = rangeEnd+1;
            		rangeEnd+=10;
            		startFetchDataSource();
            	} else if (rangeEnd < sourceLength-1) {
            		rangeStart = rangeEnd+1;
            		rangeEnd = sourceLength-1;
            		startFetchDataSource();
            	}
            }
        });
		nextButton.setId(NEXT_BUTTON);
		LayoutParams param3 = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		param3.addRule(RelativeLayout.ALIGN_PARENT_RIGHT, RelativeLayout.CENTER_VERTICAL);
		param3.setMargins(5, 0, 10, 0);
		nextButton.setLayoutParams(param3);
		nextButton.setPadding(0, nextButton.getPaddingTop(), 2, nextButton.getPaddingBottom());
		infoBar.addView(nextButton);
		param3=null;
		
		ImageButton prevButton = new ImageButton(this);
		prevButton.setImageResource(R.drawable.prev);
		prevButton.setBackgroundResource(R.color.transparentColor);
		prevButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) { 
            	if (rangeStart!= 0) {
            		rangeStart -= 10;
            		rangeEnd = rangeStart+9;
            		startFetchDataSource();
            	}
            }
        });
		LayoutParams param4 = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		param4.addRule(RelativeLayout.ALIGN_PARENT_LEFT, RelativeLayout.CENTER_VERTICAL);
		param4.setMargins(10, 0, 5, 0);
		prevButton.setLayoutParams(param4);
		prevButton.setPadding(0, prevButton.getPaddingTop(), 2, prevButton.getPaddingBottom());
		infoBar.addView(prevButton);
		param4=null;
		
		nextButton=null;
		prevButton=null;
	}
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == REQUEST_CODE_typeSelector) {
			// Get the result from Type Selector
			if (resultCode == RESULT_OK) {
				typeId = data.getExtras().getInt("qid");
				String typeName = QidToDescription.getDetailByQID(this,typeId);
				// Should Reset Data range
				rangeEnd = 9;
				rangeStart = 0;
				startFetchDataSource();
				currentConditionLabel.setText(typeName);
			} else if (resultCode == RESULT_CANCELED) {
			}
		}
		super.onActivityResult(requestCode, resultCode, data);
	}
	/**
	 * @category Datasource Method
	 */
	protected boolean setQGAECondition() {
		qGAE.addQuery(GAEQueryCondtionType.GAEQueryByCoordinate, mapMode.getMapCenter(), mapMode.getLatitudeSpan(), mapMode.getLongitudeSpan());
		if (typeId!=0)
			qGAE.addQuery(GAEQueryCondtionType.GAEQueryByType, Integer.toString(typeId));
		return true;
	}
	protected void qGAEReturnNull() {
		currentRangeLabel.setText(getResources().getString(R.string.query_currentRangeLabel_emptyCase));
	}
	protected void qGAEReturnData() {
		// Set Label
		int rangeEndToShow;
		if (sourceLength < rangeEnd+1) rangeEndToShow = sourceLength;
		else rangeEndToShow = rangeEnd+1;
		if (sourceLength==0) currentRangeLabel.setText(getResources().getString(R.string.query_currentRangeLabel_emptyCase));
		else currentRangeLabel.setText(Integer.toString(rangeStart+1)+"-"+Integer.toString(rangeEndToShow)+" 筆，共 "+Integer.toString(sourceLength)+" 筆");
	}
	/**
	 * @category Menu
	 */
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		menu.add(0, MENU_SetTypeCondition, 0, getResources().getString(R.string.menu_query_setTypeCondition)).setIcon(R.drawable.menu_type);
		menu.add(0, MENU_AllTypeCondition, 0, getResources().getString(R.string.menu_query_setAllType)).setIcon(android.R.drawable.ic_menu_search);
		return super.onCreateOptionsMenu(menu);
	}
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == MENU_SetTypeCondition || item.getItemId() == MENU_AllTypeCondition)
			this.menuActionToTake(item);
		return super.onOptionsItemSelected(item);
	}
	@Override
	public void menuActionToTake(MenuItem item) {
		if (item.getItemId()==MENU_SetTypeCondition) {
			// Call Type Selector
			Intent intent = new Intent();
			intent.setClass(Query.this, TypeSelector.class);
			startActivityForResult(intent, REQUEST_CODE_typeSelector);
		} else if (item.getItemId()==MENU_AllTypeCondition) {
			typeId = 0;
			// Should Reset Data range
			rangeEnd = 9;
			rangeStart = 0;
			startFetchDataSource();
			currentConditionLabel.setText(getResources().getString(R.string.query_currentConditionLabel_alltype));
			
		}
	}
	/**
	 * @category Map setting
	 */
	@Override
	protected void mapChangeRegionOrZoom() {
		// Should Reset Data range
		rangeEnd = 9;
		rangeStart = 0;
		startFetchDataSource();
	}
}
