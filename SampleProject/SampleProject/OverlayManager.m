//
//  OverlayManager.m
//  SampleProject
//
//  Created by Matteo Gavagnin on 12/29/11.
//  Copyright (c) 2011 MobFarm s.a.s. All rights reserved.
//

#import "OverlayManager.h"
#import <FPKYouTube/FPKYouTube.h>

@implementation OverlayManager

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self setExtensions:[[NSArray alloc] initWithObjects:@"FPKYouTube", nil]];
	}
	return self;
}

@end
