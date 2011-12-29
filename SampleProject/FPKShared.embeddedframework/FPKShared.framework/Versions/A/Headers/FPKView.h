//
//  FPKView.h
//  FPKShared
//
//  Created by Matteo Gavagnin on 12/29/11.
//  Copyright (c) 2011 MobFarm s.a.s. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FPKView <NSObject>
- (UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame;
+ (NSArray *)acceptedPrefixes;
+ (BOOL)respondsToPrefix:(NSString *)prefix;
- (CGRect)rect;
- (void)setRect:(CGRect)_rect;
@end
