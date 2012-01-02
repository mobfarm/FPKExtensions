//
//  OverlayManager.m
//  SampleProject
//
//  Created by Matteo Gavagnin on 12/29/11.
//  Copyright (c) 2011 MobFarm s.a.s. All rights reserved.
//

#import "OverlayManager.h"

/** 
 @bug Complete the documentation

 Just import every Extension you need, that's it!
 */

#import <FPKYouTube/FPKYouTube.h>
#import <FPKMap/FPKMap.h>
#import <FPKGalleryFade/FPKGalleryFade.h>
#import <FPKGalleryTap/FPKGalleryTap.h>
#import <FPKMessage/FPKMessage.h>
#import <FPKWebPopup/FPKWebPopup.h>
#import <FPKGallerySlide/FPKGallerySlide.h>

@implementation OverlayManager

- (FPKOverlayManager *)init
{
	self = [super init];
	if (self != nil)
	{
		/**
            Add Extensions to the array, or use the initWithExtension: method         
         */
                
		[self setExtensions:[[NSArray alloc] initWithObjects:@"FPKGallerySlide", @"FPKWebPopup", @"FPKMessage", @"FPKGalleryTap", @"FPKMap", @"FPKYouTube", @"FPKGalleryFade", nil]];
	}
	return self;
}

@end
