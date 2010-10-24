//
//  CaseSelectorViewController.m
//  MGOV
//
//  Created by sodas on 2010/10/1.
//  Copyright 2010 NTU Mobile HCI Lab. All rights reserved.
//

#import "CaseSelectorViewController.h"

/*
 *
 *  Use this Class to merge the common section between MyCase and Query views.
 *  HybridViewController sets most part of common UI section, but contains no Data Source section.
 *  The common Data Source section is set here.
 *
 */

@implementation CaseSelectorViewController

@synthesize childViewController, caseSource;
@synthesize currentCondition, currentConditionType;

#pragma mark -
#pragma mark Override

- (void)pushToChildViewControllerInMap {
	informationBar.hidden = YES;
	[super pushToChildViewControllerInMap];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
	informationBar.hidden = NO;
	return [super popViewControllerAnimated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)MapView viewForAnnotation:(id <MKAnnotation>)annotation {
	//Let the system use the "blue dot" for the user location
	if ([annotation isKindOfClass:[MKUserLocation class]]) return nil; 
	
	// Act like table view cells
	static NSString * const pinAnnotationIdentifier = @"PinIdentifier";
	MKPinAnnotationView *dataAnnotationView = (MKPinAnnotationView *)[MapView dequeueReusableAnnotationViewWithIdentifier:pinAnnotationIdentifier];
	// Remove Pin view
	if ([dataAnnotationView.subviews count]) [[dataAnnotationView.subviews lastObject] removeFromSuperview];
	// Reuse
	if (dataAnnotationView!=nil) {
		// Already exists
		dataAnnotationView.annotation = annotation;
	} else {		
		// Renew
		dataAnnotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinAnnotationIdentifier] autorelease];
		dataAnnotationView.draggable = NO;
		dataAnnotationView.canShowCallout = YES;
		dataAnnotationView.animatesDrop = YES;
		UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		dataAnnotationView.rightCalloutAccessoryView = detailButton;
		[detailButton addTarget:self action:@selector(pushToChildViewControllerInMap) forControlEvents:UIControlEventTouchUpInside];
	}
	// Case Status
	if ([self convertStatusStringToStatusCode:[(AppMKAnnotation *)annotation annotationStatus]]==1)
		dataAnnotationView.pinColor = MKPinAnnotationColorGreen;
	else if ([self convertStatusStringToStatusCode:[(AppMKAnnotation *)annotation annotationStatus]]==2)
		dataAnnotationView.pinColor = MKPinAnnotationColorRed;
	else {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orange_pin.png"]];
		imageView.frame = CGRectMake(-0.5, -0.5, imageView.frame.size.width, imageView.frame.size.height);
		[dataAnnotationView addSubview:imageView];
		[imageView release];
	}
	return dataAnnotationView;
}

#pragma mark -
#pragma mark Method

- (NSUInteger)convertStatusStringToStatusCode:(NSString *)status {
	if ([status isEqualToString:@"完工"]||
		[status isEqualToString:@"結案"]||
		[status isEqualToString:@"轉府外單位"])
		return 1;
	else if ([status isEqualToString:@"無法辦理"]||
			 [status isEqualToString:@"退回區公所"]||
			 [status isEqualToString:@"查驗未通過"])
		return 2;
	else {
		return 0;
	}
}

#pragma mark -
#pragma mark Data Source Method

- (void)queryGAEwithConditonType:(DataSourceGAEQueryTypes)conditionType andCondition:(id)condition {
	QueryGoogleAppEngine *qGAE = [QueryGoogleAppEngine requestQuery];
	qGAE.resultTarget = self;
	qGAE.indicatorTargetView = self.view;
	qGAE.resultRange = queryRange;
	if (conditionType == DataSourceGAEQueryByMultiConditons) {
		qGAE.conditionType = conditionType;
		qGAE.queryMultiConditions = condition;
	} else {
		qGAE.conditionType = conditionType;
		qGAE.queryCondition = condition;
	}
	self.topViewController.navigationItem.leftBarButtonItem.enabled =  NO;
	self.topViewController.navigationItem.rightBarButtonItem.enabled = NO;
	// Save state
	self.currentCondition = condition;
	self.currentConditionType = conditionType;
	[qGAE startQuery];
}

- (void)refreshDataSource {
	[self queryGAEwithConditonType:currentConditionType andCondition:currentCondition];
}

#pragma mark -
#pragma mark QueryGAEReciever

- (void)recieveQueryResultType:(DataSourceGAEReturnTypes)type withResult:(id)result {
	// Implement this method in child class
}

#pragma mark -
#pragma mark HybridViewDelegate

- (void)didSelectRowAtIndexPathInList:(NSIndexPath *)indexPath {
	if (indexPath.section != 0) {
		informationBar.hidden = YES;
		caseID = [[caseSource objectAtIndex:indexPath.row] valueForKey:@"key"];
		childViewController.query_caseID = caseID;
		[self pushViewController:childViewController animated:YES];
		[childViewController startToQueryCase];
	}
}

- (void)didSelectAnnotationViewInMap:(MKAnnotationView *)annotationView {
	if (![annotationView.annotation isKindOfClass:[MKUserLocation class]]) {
		caseID = [(AppMKAnnotation *)annotationView.annotation annotationID];
		childViewController.query_caseID = caseID;
	}
}

#pragma mark -
#pragma mark HybridViewDataSource

- (NSInteger)numberOfSectionsInList {
	return 2;
}

- (NSInteger)numberOfRowsInListSection:(NSInteger)section {
	if (section == 0) return 1;
	return [caseSource count];
}

- (CGFloat)heightForRowAtIndexPathInList:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) return 44;
	return [CaseSelectorCell cellHeight];
}

- (NSString *)titleForHeaderInSectionInList:(NSInteger)section {
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"caseCell";
	static NSString *CellIdentifier2 = @"informationBarCell";
	// First Cell which is covered by InformationBar
	if (indexPath.section == 0) {
		// Waste some memory since this cell could not be shared to other Case.
		CaseSelectorCell *cell = (CaseSelectorCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
		if (cell == nil) 
			cell = [[[CaseSelectorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		return cell;
	}
	
	// Normal Section Cell
	CaseSelectorCell *cell = (CaseSelectorCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[[CaseSelectorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	// Case ID
	cell.caseKey.text = [[caseSource objectAtIndex:indexPath.row] objectForKey:@"key"];
	// Case Type
	NSString *caseTypeText = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"QidToType" ofType:@"plist"]] valueForKey:[[caseSource objectAtIndex:indexPath.row] valueForKey:@"typeid"]];
	cell.caseType.text = caseTypeText;
	// Case Date
	if ([[caseSource objectAtIndex:indexPath.row] objectForKey:@"date"]!=nil) {
		// Original ROC Format
		NSString *originalDate = [[[[[caseSource objectAtIndex:indexPath.row] objectForKey:@"date"] stringByReplacingOccurrencesOfString:@"年" withString:@"/"]
								   stringByReplacingOccurrencesOfString:@"月" withString:@"/"] 
								  stringByReplacingOccurrencesOfString:@"日" withString:@""];
		NSString *originalLongDate = [originalDate stringByAppendingString:@" 23:59:59"];
		// Convert to Common Era
		NSDate *formattedDate = [NSDate dateFromROCFormatString:originalLongDate];
		
		// Make today's end
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		NSString *todayDate = [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@" 23:59:59"];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		NSDate *todayEnd = [dateFormatter dateFromString:todayDate];
		[dateFormatter release];
		
		// Check Interval
		if ([todayEnd timeIntervalSinceDate:formattedDate] < 86400) {
			cell.caseDate.text = @"今天";
		} else if ([todayEnd timeIntervalSinceDate:formattedDate]  < 86400*2) {
			cell.caseDate.text = @"昨天";
		} else if ([todayEnd timeIntervalSinceDate:formattedDate]  < 86400*3) {
			cell.caseDate.text = @"兩天前";
		} else {
			cell.caseDate.text = originalDate;
		}
		
		originalDate = nil;
		originalLongDate = nil;
		formattedDate = nil;
		todayDate = nil;
		todayEnd = nil;
	} else {
		// No Date
		cell.caseDate.text = @"";
	}
	// Case Address
	cell.caseAddress.text = [[caseSource objectAtIndex:indexPath.row] objectForKey:@"address"];
	// Case Status
	if ([self convertStatusStringToStatusCode:[[caseSource objectAtIndex:indexPath.row] objectForKey:@"status"]]==1)
		cell.caseStatus.image = [UIImage imageNamed:@"ok.png"];
	else if ([self convertStatusStringToStatusCode:[[caseSource objectAtIndex:indexPath.row] objectForKey:@"status"]]==2)
		cell.caseStatus.image = [UIImage imageNamed:@"fail.png"];
	else
		cell.caseStatus.image = [UIImage imageNamed:@"unknown.png"];
	
	caseTypeText= nil;
	
	return cell;
}

- (NSArray *) setupAnnotationArrayForMapView {
	CLLocationCoordinate2D coordinate;
	NSMutableArray *annotationArray = [[[NSMutableArray alloc] init] autorelease];
	NSString *typeStr;
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	for (int i = 0; i < [caseSource count]; i++) {
		coordinate.longitude = [[[[caseSource objectAtIndex:i] objectForKey:@"coordinates"] objectAtIndex:0] doubleValue];
		coordinate.latitude = [[[[caseSource objectAtIndex:i] objectForKey:@"coordinates"] objectAtIndex:1] doubleValue];
		typeStr = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"QidToType" ofType:@"plist"]] valueForKey:[[caseSource objectAtIndex:i] valueForKey:@"typeid"]];
		AppMKAnnotation *casePlace = [[AppMKAnnotation alloc] initWithCoordinate:coordinate andTitle:typeStr andSubtitle:@"" andCaseID:[[caseSource objectAtIndex:i] objectForKey:@"key"] andStatus:[[caseSource objectAtIndex:i] objectForKey:@"status"]];
		[annotationArray addObject:casePlace];
		[casePlace release];
		
		typeStr = nil;
	}
	[tmpPool drain];
	return annotationArray;
}

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	// Show Information Bar
	informationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 320, 44)];
	informationBar.backgroundColor = [UIColor colorWithRed:0.44 green:0.53 blue:0.64 alpha:0.9];
	[self.view addSubview:informationBar];
	currentCondition = nil;
	[informationBar release];
	
	// New Case Viewer for reuse
	if (childViewController==nil)
		childViewController = [[CaseViewerViewController alloc] initWithStyle:UITableViewStyleGrouped];
	[childViewController startToQueryCase];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	listViewController.tableView.delegate = self;
	listViewController.tableView.dataSource = self;
}

- (void)dealloc {
	[super dealloc];
	[childViewController release];
}

@end