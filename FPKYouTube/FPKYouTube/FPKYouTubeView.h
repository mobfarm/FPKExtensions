//
//  FPKYouTubeView.h
//  Overlay
//
//  Created by Matteo Gavagnin on 11/3/11.
//  Copyright (c) 2011 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FPKView
- (UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame;
+ (NSArray *)acceptedPrefixes;
+ (BOOL)respondsToPrefix:(NSString *)prefix;
- (CGRect)rect;
@end

@interface FPKYouTubeView : UIWebView <FPKView>{
    CGRect _rect;
}
@end
