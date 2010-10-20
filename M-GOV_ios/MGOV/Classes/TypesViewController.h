//
//  TypesViewController.h
//  MGOV
//
//  Created by sodas on 2010/8/11.
//  Copyright 2010 NTU Mobile HCI Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypeSelectorDelegateProtocol.h"

@interface TypesViewController : UITableViewController {
	// Record Question Type
	NSInteger finalSectionId;
	NSInteger finalTypeId;
	id<TypeSelectorDelegateProtocol> delegate;
}

@property (nonatomic, retain) id<TypeSelectorDelegateProtocol> delegate;

@end