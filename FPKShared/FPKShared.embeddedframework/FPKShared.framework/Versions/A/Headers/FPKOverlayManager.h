//
//  FPKOverlayManager.h
//  Overlay
//
//  Created by Matteo Gavagnin on 11/1/11.
//  Copyright (c) 2011 MobFarm S.r.l. All rights reserved.
//

#import <FastPdfKit/MFDocumentViewController.h>

@protocol FPKView
- (UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame;
+ (NSArray *)acceptedPrefixes;
+ (BOOL)respondsToPrefix:(NSString *)prefix;
- (CGRect)rect;
- (void)setRect:(CGRect)_rect;
@end

@protocol OverlayDataSourceDelegate <NSObject>
@optional
- (void)setGesturesDisabled:(BOOL)disabled;
@end

@interface FPKOverlayManager : NSObject <FPKOverlayViewDataSource>{
    NSMutableArray *overlays;
    NSArray *extensions;
    MFDocumentViewController <OverlayDataSourceDelegate> * documentViewController;
}
@property(nonatomic, retain) NSMutableArray *overlays;
@property(nonatomic, assign) MFDocumentViewController <OverlayDataSourceDelegate> * documentViewController;

- (UIView *)showAnnotationForOverlay:(BOOL)load withRect:(CGRect)rect andUri:(NSString *)uri onPage:(NSUInteger)page;
- (void)setGlobalParametersFromAnnotation;
- (void)setExtensions:(NSArray *)ext;
@end

