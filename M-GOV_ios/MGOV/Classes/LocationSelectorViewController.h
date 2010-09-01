//
//  LocationSelectorViewController.h
//  MGOV
//
//  Created by Shou on 2010/8/30.
//  Copyright 2010 NTU Mobile HCI Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JSON.h"

@protocol LocationSelectorViewControllerDelegate

@required
- (void)userDidSelectCancel;
- (void)userDidSelectDone:(CLLocationCoordinate2D)coordinate;

@end


@interface LocationSelectorViewController : UIViewController <MKMapViewDelegate> {
	id<LocationSelectorViewControllerDelegate> delegate;
	MKMapView *mapView;
	UINavigationBar *titleBar;
	UISearchBar *searchBar;
	UILabel *selectedAddress;
	CLLocationCoordinate2D selectedCoord;
}
@property (nonatomic, retain) id<LocationSelectorViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UINavigationBar *titleBar;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UILabel *selectedAddress;
@property (nonatomic) CLLocationCoordinate2D selectedCoord;

- (void) updatingAddress:(id <MKAnnotation>)annotation;
- (void) transformCoordinate;


@end
