//
//  MFMapAnnotation.h
//  Overlay
//

#import <MapKit/MapKit.h>

@interface FPKMapAnnotation : NSObject <MKAnnotation> {
    UIImage *image;
    NSNumber *latitude;
    NSNumber *longitude;
    NSString *title;
    NSString *subtitle;
    BOOL callout;
    MKPinAnnotationColor color;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) BOOL callout;
@property (nonatomic) MKPinAnnotationColor color;
@end