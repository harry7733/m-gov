/*
 * 
 * DetailViewController.m
 * 2010/8/11
 * sodas
 * 
 * A table which will provide detail info of each case type
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

#import "DetailViewController.h"
#import "SecondDetailViewController.h"

@implementation DetailViewController

@synthesize finalSectionId;
@synthesize finalTypeId;
@synthesize finalDetailId;
@synthesize delegate;

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
	NSString *path;
	
	// Detail
	path = [[NSBundle mainBundle] pathForResource:@"reportDetails" ofType:@"plist"];
	detailDict = [[NSDictionary alloc] initWithContentsOfFile:path];
	
	// Second Detail Dict
	path = [[NSBundle mainBundle] pathForResource:@"reportSecondDetails" ofType:@"plist"];
	secondDetailDict = [[NSDictionary alloc] initWithContentsOfFile:path];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Open plist
	NSString *sectionId = [NSString stringWithFormat:@"Section%d", finalSectionId];
	NSString *typeId = [NSString stringWithFormat:@"Type%d", finalTypeId];

    return [[[detailDict objectForKey:sectionId] objectForKey:typeId] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Open plist
	NSString *sectionId = [NSString stringWithFormat:@"Section%d", finalSectionId];
	NSString *typeId = [NSString stringWithFormat:@"Type%d", finalTypeId];
	NSString *detailId = [NSString stringWithFormat:@"Detail%d", indexPath.row];
		
	cell.textLabel.text = [[[detailDict objectForKey:sectionId] objectForKey:typeId] valueForKey:detailId];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.minimumFontSize = 14.0;
	cell.textLabel.numberOfLines = 1;

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Record
	finalDetailId = indexPath.row;
	
	// Check second detail
	// Open plist
	NSString *sectionId = [NSString stringWithFormat:@"Section%d", finalSectionId];
	NSString *typeId = [NSString stringWithFormat:@"Type%d", finalTypeId];
	NSString *detailId = [NSString stringWithFormat:@"Detail%d", indexPath.row];

	// Title
	// Open the plist
	NSString *selectedTitle = [[[detailDict objectForKey:sectionId] objectForKey:typeId] valueForKey:detailId];
	
	if ([[[[secondDetailDict objectForKey:sectionId] objectForKey:typeId] objectForKey:detailId] count]) {
		// Navigation logic may go here. Create and push another view controller.
		SecondDetailViewController *secondDetail = [[SecondDetailViewController alloc] initWithNibName:@"SecondDetailViewController" bundle:nil];
		
		secondDetail.finalSectionId = finalSectionId;
		secondDetail.finalTypeId = finalTypeId;
		secondDetail.finalDetailId = finalDetailId;
		secondDetail.title = selectedTitle;
		secondDetail.delegate = self.delegate;
		
		// Pass the selected object to the new view controller.
		[self.navigationController pushViewController:secondDetail animated:YES];
		[secondDetail release];
	} else {
		// Generate qid
		// Merge names
		NSString *qidPath = [[NSBundle mainBundle] pathForResource:@"reportQid" ofType:@"plist"];
		NSString *sectionId = [NSString stringWithFormat:@"Section%d", finalSectionId];
		NSString *typeId = [NSString stringWithFormat:@"Type%d", finalTypeId];
		NSString *detailId = [NSString stringWithFormat:@"Detail%d", finalDetailId];
		// Open the qid plist
		NSInteger qid = [[[[[NSDictionary dictionaryWithContentsOfFile:qidPath] objectForKey:sectionId] objectForKey:typeId] valueForKey:detailId] intValue];
		
		// Switch back
		[delegate typeSelectorDidSelectWithTitle:selectedTitle andQid:qid];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[detailDict release];
	[secondDetailDict release];
    [super dealloc];
}

@end
