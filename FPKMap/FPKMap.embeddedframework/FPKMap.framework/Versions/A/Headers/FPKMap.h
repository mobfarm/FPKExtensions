//
//  FPKExtension.h
//  Overlay
//
//  Created by Matteo Gavagnin on 11/3/11.
//  Copyright (c) 2011 MobFarm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>
#import <MapKit/MapKit.h>

@interface FPKMap : UIView <FPKView, MKMapViewDelegate>{
    CGRect _rect;
}
@end
