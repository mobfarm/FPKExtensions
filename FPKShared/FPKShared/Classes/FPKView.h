//
//  FPKView.h
//  FPKShared
//
//  Created by Matteo Gavagnin on 12/29/11.
//  Copyright (c) 2011 MobFarm s.a.s. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @bug Complete the description and remove the icon
 
 <img src="../docs/fpk-icon.png" />
 */

@protocol FPKView <NSObject>
/**
 @bug complete the description
 
 
 @param params
 
 @param frame
 */
- (UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame;

/**
 @bug complete the description
 
 
 @return
 */

+ (NSArray *)acceptedPrefixes;

/**
 @bug complete the description
 
 @param prefix
 @return 
 */

+ (BOOL)respondsToPrefix:(NSString *)prefix;

/**
 @bug complete the description
 
 
 @return rect 
 */

- (CGRect)rect;

/**
 @bug complete the description
 
 
 @param rect 
 */

- (void)setRect:(CGRect)rect;
@end
