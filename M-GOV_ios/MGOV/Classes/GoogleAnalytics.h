/*
 * 
 * GoogleAnalytics.h
 * 2010/11/05
 * sodas
 *
 * Provide information for Google Analytics
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

#import <Foundation/Foundation.h>
#import "GANTracker.h"

#define kAppLifecycle @"AppLifecycle"
#define kCaseAdder @"CaseAdderEvent"

typedef enum {
	// App Lifecycle
	GANActionAppDidFinishLaunch,
	GANActionAppDidEnterBackground,
	GANActionAppDidEnterForeground,
	GANActionAppWillTerminate,
	// Case Adder event
	GANActionAddCaseSuccess,
	GANActionAddCaseFailed,
	GANActionAddCaseWithName,
	GANActionAddCaseWithPhoto,
	GANActionAddCaseWithoutPhoto,
} GANAction;

@interface GoogleAnalytics : NSObject {
}

+ (void)trackAction:(GANAction)action;
+ (void)trackAction:(GANAction)action withLabel:(NSString *)label;

@end