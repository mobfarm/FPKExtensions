//
//  FPKExtension.m
//  Overlay
//
//  Created by Matteo Gavagnin on 11/3/11.
//  Copyright (c) 2011 MobFarm. All rights reserved.
//

#import "FPKMap.h"
#import "FPKMapAnnotation.h"

@implementation FPKMap

#pragma mark -
#pragma mark Initialization

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    if (self = [super init]) 
    {        
        [self setFrame:frame];
        _rect = frame;
        [self setBackgroundColor:[UIColor redColor]];
                
        MKMapView *map = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        [map setDelegate:self];
        MKCoordinateRegion newRegion;
        newRegion.center.latitude = [[[params objectForKey:@"params"] objectForKey:@"lat"] doubleValue];
        newRegion.center.longitude = [[[params objectForKey:@"params"] objectForKey:@"lon"] doubleValue];
        newRegion.span.latitudeDelta = [[[params objectForKey:@"params"] objectForKey:@"latd"] floatValue];
        newRegion.span.longitudeDelta = [[[params objectForKey:@"params"] objectForKey:@"lond"] floatValue];
                
        [map setRegion:newRegion animated:YES];
        MKMapType type = MKMapTypeStandard;
        if ([[[params objectForKey:@"params"] objectForKey:@"resource"] isEqualToString:@"hybrid"])
            type = MKMapTypeHybrid;
        else if ([[[params objectForKey:@"params"] objectForKey:@"resource"] isEqualToString:@"satellite"])
            type = MKMapTypeSatellite;
        else if ([[[params objectForKey:@"params"] objectForKey:@"resource"] isEqualToString:@"standard"])
            type = MKMapTypeStandard;
        
        if([[[params objectForKey:@"params"] objectForKey:@"user"] boolValue])
            [map setShowsUserLocation:YES];
        
        
        if([[params objectForKey:@"params"] objectForKey:@"pinlat"]){
            FPKMapAnnotation *annotation = [[FPKMapAnnotation alloc] init];
            annotation.latitude = [NSNumber numberWithDouble:[[[params objectForKey:@"params"] objectForKey:@"pinlat"] doubleValue]];
            annotation.longitude = [NSNumber numberWithDouble: [[[params objectForKey:@"params"] objectForKey:@"pinlon"] doubleValue]];            
            
            annotation.callout = NO;
            
            if([[params objectForKey:@"params"] objectForKey:@"pintitle"]){
                annotation.title = [[params objectForKey:@"params"] objectForKey:@"pintitle"];
                annotation.subtitle = [[params objectForKey:@"params"] objectForKey:@"pinsub"];
                annotation.callout = YES;
            }
            
            MKPinAnnotationColor color = MKPinAnnotationColorRed;
            if ([[[params objectForKey:@"params"] objectForKey:@"pincolor"] isEqualToString:@"red"])
                color = MKPinAnnotationColorRed;
            else if ([[[params objectForKey:@"params"] objectForKey:@"pincolor"] isEqualToString:@"green"])
                color = MKPinAnnotationColorGreen;
            else if ([[[params objectForKey:@"params"] objectForKey:@"pincolor"] isEqualToString:@"purple"])
                color = MKPinAnnotationColorPurple;
            
            [annotation setColor:color];                
            [map addAnnotation:annotation];
            [annotation release];            
        }
        
        [map setMapType:type];
        [self addSubview:map];
        [map release];
    }
    return self;  
}

+ (NSArray *)acceptedPrefixes{
    return [NSArray arrayWithObjects:@"map", nil];
}

+ (BOOL)respondsToPrefix:(NSString *)prefix{
    if([prefix isEqualToString:@"map"])
        return YES;
    else 
        return NO;
}

- (CGRect)rect{
    return _rect;
}

- (void)setRect:(CGRect)aRect{
    [self setFrame:aRect];
    _rect = aRect;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc 
{
    [super dealloc];
}

@end