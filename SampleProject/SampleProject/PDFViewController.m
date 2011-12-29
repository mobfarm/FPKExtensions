//
//  PDFViewController.m
//  SampleProject
//
//  Created by Matteo Gavagnin on 12/29/11.
//  Copyright (c) 2011 MobFarm s.a.s. All rights reserved.
//

#import "PDFViewController.h"

@interface PDFViewController ()

@end

@implementation PDFViewController
@synthesize overlayManager;

- (void)documentViewController:(MFDocumentViewController *)dvc didReceiveTapOnAnnotationRect:(CGRect)rect withUri:(NSString *)uri onPage:(NSUInteger)page{
    [overlayManager showAnnotationForOverlay:NO withRect:rect andUri:uri onPage:page];
}

@end
