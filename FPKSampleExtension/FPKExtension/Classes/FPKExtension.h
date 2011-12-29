//
//  FPKExtension.h
//  Overlay
//
//  Created by Matteo Gavagnin on 11/3/11.
//  Copyright (c) 2011 MobFarm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FPKView
- (UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame;
+ (NSArray *)acceptedPrefixes;
+ (BOOL)respondsToPrefix:(NSString *)prefix;
- (CGRect)rect;
- (void)setRect:(CGRect)_rect;
@end

@interface FPKExtension : UIView <FPKView>{
    CGRect _rect;
}
@end
