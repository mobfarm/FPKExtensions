//
//  FPKYouTube.m
//  Overlay
//
//  Created by Matteo Gavagnin on 11/3/11.
//  Copyright (c) 2011 MobFarm. All rights reserved.
//

#import "FPKYouTube.h"

@implementation FPKYouTube

#pragma mark -
#pragma mark Initialization

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame{
    if (self = [super init]) 
    {        
        [self setFrame:frame];
        _rect = frame;
        self.autoresizesSubviews = YES;
        self.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);

        if([FPKYouTube respondsToPrefix:[params objectForKey:@"prefix"]]){
            NSString * url = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", [params objectForKey:@"path"]];
            NSString *youTubeVideoHTML = [NSString stringWithFormat:@"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head><body style=\"background:000000;margin-top:0px;margin-left:0px\"><div><object width=\"%0.0f\" height=\"%0.0f\"><param name=\"movie\" value=\"%@\"></param><param name=\"wmode\" value=\"transparent\"></param><embed src=\"%@\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"%0.0f\" height=\"%0.0f\"></embed></object></div></body></html>", frame.size.height, frame.size.width, frame.size.height, url, url, frame.size.width, frame.size.height];
            [self loadHTMLString:youTubeVideoHTML baseURL:[NSURL URLWithString:@"http://www.youtube.com"]];                
        }
    }
    return self;  
}

+ (NSArray *)acceptedPrefixes{
    return [NSArray arrayWithObjects:@"utube", nil];
}

+ (BOOL)respondsToPrefix:(NSString *)prefix{
    if([prefix isEqualToString:@"utube"])
        return YES;
    else 
        return NO;
}

- (CGRect)rect{
    return _rect;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc 
{
    [super dealloc];
}

@end