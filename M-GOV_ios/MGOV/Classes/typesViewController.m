//
//  typesViewController.m
//  MGOV
//
//  Created by sodas on 2010/8/11.
//  Copyright 2010 NTU Mobile HCI Lab. All rights reserved.
//

#import "typesViewController.h"
#import "detailViewController.h"

@implementation typesViewController

@synthesize delegate;

#pragma mark -
#pragma mark View Switch

- (void)backToPreviousView {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	// Open and set sectionDict
	NSString *path=[[NSBundle mainBundle] pathForResource:@"reportSections" ofType:@"plist"];
	
    return [[NSDictionary dictionaryWithContentsOfFile:path] count];
}

// Section names
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *path=[[NSBundle mainBundle] pathForResource:@"reportSections" ofType:@"plist"];
	NSString *sectionId = [NSString stringWithFormat:@"Section%d", section];
	
	return [[NSDictionary dictionaryWithContentsOfFile:path] valueForKey:sectionId];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	// Set typeDict
    // Open the plist
	NSString *path=[[NSBundle mainBundle] pathForResource:@"reportTypes" ofType:@"plist"];
	NSString *sectionId = [NSString stringWithFormat:@"Section%d", section];

	return [[[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:sectionId] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	
	// Open the plist
	NSString *path=[[NSBundle mainBundle] pathForResource:@"reportTypes" ofType:@"plist"];
	NSString *sectionId = [NSString stringWithFormat:@"Section%d", indexPath.section];
	NSString *typeString = [NSString stringWithFormat:@"Type%d", indexPath.row];
	
	cell.textLabel.text = [[[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:sectionId] valueForKey:typeString];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Record for qid
	finalSectionId = indexPath.section;
	finalTypeId = indexPath.row;
	
	// Check if 1-level only
	// Open plist
	NSString *path = [[NSBundle mainBundle] pathForResource:@"reportDetails" ofType:@"plist"];
	NSString *detailSectionId = [NSString stringWithFormat:@"Section%d", finalSectionId];
	NSString *detailTypeId = [NSString stringWithFormat:@"Type%d", finalTypeId];

	// Title
	// Open the plist
	NSString *titlePath=[[NSBundle mainBundle] pathForResource:@"reportTypes" ofType:@"plist"];
	NSDictionary *titleTypeDict = [[NSDictionary dictionaryWithContentsOfFile:titlePath] objectForKey:detailSectionId];
	NSString *selectedTitle = [titleTypeDict valueForKey:detailTypeId];
	
	// Check detail
    if([[[[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:detailSectionId] objectForKey:detailTypeId] count]){
		// 2-level or more
		detailViewController *details = [[detailViewController alloc] initWithNibName:@"detailViewController" bundle:nil];
		// Record
		details.finalSectionId = finalSectionId;
		details.finalTypeId = finalTypeId; 
		details.title = selectedTitle;
		details.delegate = self.delegate;
				
		// Pass the selected object to the new view controller.
		[self.navigationController pushViewController:details animated:YES];
		[details release];
		
	} else {
		// 1-level only
		// Generate qid
		// Merge names
		NSString *path = [[NSBundle mainBundle] pathForResource:@"reportQid" ofType:@"plist"];
		NSString *sectionId = [NSString stringWithFormat:@"Section%d", finalSectionId];
		NSString *typeId = [NSString stringWithFormat:@"Type%d", finalTypeId];
		// Open the qid plist
		NSString *qid = [[[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:sectionId] valueForKey:typeId];
		
		// Write to plist
		NSString *typeSelectorStatusPlistPathInAppDocuments = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"TypeSelectorStatus.plist"];
		NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:typeSelectorStatusPlistPathInAppDocuments];
		[plistDict setValue:selectedTitle forKey:@"submitContent"];
		[plistDict setValue:qid forKey:@"submitQid"];
		[plistDict setValue:@"1" forKey:@"submitReadable"];
		[plistDict writeToFile:typeSelectorStatusPlistPathInAppDocuments atomically:YES];
		
		// Switch back
		[delegate backToPreviousView];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
    [super dealloc];
}

@end
