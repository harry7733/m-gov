//
//  TypeSelectorDelegateProtocol.h
//  MGOV
//
//  Created by sodas on 2010/8/26.
//  Copyright 2010 NTU Mobile HCI Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TypeSelectorDelegateProtocol

@required
- (void)typeSelectorDidSelectWithTitle:(NSString *)t andQid:(NSInteger)q;
- (void)leaveSelectorWithoutTitleAndQid;

@end
