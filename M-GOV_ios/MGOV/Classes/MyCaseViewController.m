//
//  MyCaseViewController.m
//  MGOV
//
//  Created by sodas on 2010/9/9.
//  Copyright 2010 NTU Mobile HCI Lab. All rights reserved.
//

#import "MyCaseViewController.h"

@implementation MyCaseViewController

@synthesize dictUserInformation;

#pragma mark -
#pragma mark Override

- (id)initWithMode:(HybridViewMenuMode)mode andTitle:(NSString *)title {
	UIBarButtonItem *addCaseButton = [[[UIBarButtonItem alloc] initWithTitle:@"新增案件" style:UIBarButtonItemStyleBordered target:self action:@selector(addCase)] autorelease];
	// Set Range length to 0 to fectch all data
	queryRange = NSRangeFromString(@"0,0");
	return [self initWithMode:mode andTitle:title withRightBarButtonItem:addCaseButton];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
	UIViewController *popResult = [super popViewControllerAnimated:animated];
	if ([[dictUserInformation valueForKey:@"User Email"] length]==0) informationBar.hidden = YES;
	return popResult;
}

- (void)didSelectRowAtIndexPathInList:(NSIndexPath *)indexPath {
	if ([[dictUserInformation valueForKey:@"User Email"] length]!=0)
		[super didSelectRowAtIndexPathInList:indexPath];
}

- (NSInteger)numberOfSectionsInList {
	if ([[dictUserInformation valueForKey:@"User Email"] length]==0) return 1;
	else return [super numberOfSectionsInList];
}

- (NSInteger)numberOfRowsInListSection:(NSInteger)section {
	if ([[dictUserInformation valueForKey:@"User Email"] length]==0) return 1;
	else return [super numberOfRowsInListSection:section];
}

- (CGFloat)heightForRowAtIndexPathInList:(NSIndexPath *)indexPath {
	if ([[dictUserInformation valueForKey:@"User Email"] length]==0) return 372;
	else return [super heightForRowAtIndexPathInList:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[dictUserInformation valueForKey:@"User Email"] length]==0) {
		static NSString *CellIdentifier = @"NoMyCaseCell";
		CaseSelectorCell *cell = (CaseSelectorCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell==nil) {
			cell = [[[CaseSelectorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NoMyCase.png"]];
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		return cell;
	} else return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	// Fetch User Information
	NSString *plistPathInAppDocuments = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"UserInformation.plist"];
	self.dictUserInformation = [[NSDictionary dictionaryWithContentsOfFile:plistPathInAppDocuments] retain];
	if ([[dictUserInformation valueForKey:@"User Email"] length]) [self queryGAEwithConditonType:DataSourceGAEQueryByEmail andCondition:[dictUserInformation objectForKey:@"User Email"]];
	
	
	if ([[dictUserInformation valueForKey:@"User Email"] length]) {
		// Add Filter
		UISegmentedControl *filter=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"所有案件", @"完工", @"處理中", @"退回", nil]];
		filter.segmentedControlStyle = UISegmentedControlStyleBar;
		float filterX = (320 - filter.frame.size.width)/2;
		float filterY = (44 - filter.frame.size.height)/2;
		filter.frame = CGRectMake(filterX, filterY, filter.frame.size.width, filter.frame.size.height);
		
		[informationBar addSubview:filter];
		[filter release];
	} else {
		// Hide Filter/InformationBar
		informationBar.hidden = YES;
	}
}

#pragma mark -
#pragma mark Method

- (void)addCase {
	// Call the add case view
	CaseAddViewController *caseAdder = [[CaseAddViewController alloc] initWithStyle:UITableViewStyleGrouped];
	caseAdder.delegate = self;
	informationBar.hidden = YES;
	[self.topViewController.navigationController pushViewController:caseAdder animated:YES];
	[caseAdder release];
}

#pragma mark -
#pragma mark QueryGAEReciever

- (void)recieveQueryResultType:(DataSourceGAEReturnTypes)type withResult:(id)result {
	// Accept Array only
	if (type == DataSourceGAEReturnByNSDictionary) {
		self.caseSource = [result objectForKey:@"result"];
	} else {
		caseSource = nil;
	}
	[self refreshViews];
	self.topViewController.navigationItem.leftBarButtonItem.enabled = YES;
	self.topViewController.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark -
#pragma mark CaseAddViewControllerDelegate

- (void)refreshData {
	// If the original email is empty, after user submit case, reload the plist
	if (![[dictUserInformation valueForKey:@"User Email"] length]) {
		NSString *plistPathInAppDocuments = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"UserInformation.plist"];
		self.dictUserInformation = [NSDictionary dictionaryWithContentsOfFile:plistPathInAppDocuments];
	}
	[self queryGAEwithConditonType:DataSourceGAEQueryByEmail andCondition:[dictUserInformation objectForKey:@"User Email"]];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[super dealloc];
}

@end
