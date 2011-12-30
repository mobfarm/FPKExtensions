//
//  FPKOverlayManager.m
//  Overlay
//
//  Created by Matteo Gavagnin on 11/1/11.
//  Copyright (c) 2011 MobFarm S.r.l. All rights reserved.
//

#import "FPKOverlayManager.h"
#import <FastPdfKit/FPKURIAnnotation.h>
#import <FastPdfKit/MFDocumentManager.h>
#import "FPKView.h"

@implementation FPKOverlayManager
@synthesize documentViewController;

- (FPKOverlayManager *)initWithExtensions:(NSArray *)ext
{
	self = [super init];
	if (self != nil)
	{
		[self setExtensions:ext];
	}
	return self;
}

- (void)setExtensions:(NSArray *)ext{
    extensions = ext;
    if(!overlays)
        overlays = [[NSMutableArray alloc] init];
    else
        [overlays removeAllObjects];
}

- (void)setScrollLock:(BOOL)lock{
    [documentViewController setScrollEnabled:!lock];
    [documentViewController setGesturesDisabled:lock];
}

- (void)documentViewController:(MFDocumentViewController *)dvc didReceiveTapOnAnnotationRect:(CGRect)rect withUri:(NSString *)uri onPage:(NSUInteger)page{
    /** We are registered as delegate for the documentViewController, so we can receive tap on annotations */
    [self showAnnotationForOverlay:NO withRect:rect andUri:uri onPage:page];
}

- (UIView *)showAnnotationForOverlay:(BOOL)load withRect:(CGRect)rect andUri:(NSString *)uri onPage:(NSUInteger)page{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    /** 
        Set the supported extensions array when you instantiate your FPKOverlayManager subclass
        
        [self setExtensions:[[NSArray alloc] initWithObjects:@"FPKYouTube", nil]];
    */
    
    if(!extensions)
        [self setExtensions:[[NSArray alloc] init]];
    
    NSArray *arrayParameter = nil;
	NSString *uriType = nil;
    NSString *uriResource = nil;
    NSArray *arrayAfterResource = nil;
    NSArray *arrayArguments = nil;
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    UIView *retVal = nil;
    
    arrayParameter = [uri componentsSeparatedByString:@"://"];
	if([arrayParameter count] > 0){
        
        uriType = [NSString stringWithFormat:@"%@", [arrayParameter objectAtIndex:0]];
        [dic setObject:uriType forKey:@"prefix"];
        [dic setObject:[NSNumber numberWithBool:load] forKey:@"load"];
        
        // NSLog(@"URI Type %@", uriType);
        
        if([arrayParameter count] > 1){
            uriResource = [NSString stringWithFormat:@"%@", [arrayParameter objectAtIndex:1]];
            [dic setObject:uriResource forKey:@"path"];
            
            // NSLog(@"Uri Resource: %@", uriResource);

            // Set default parameters
            [parameters setObject:[NSNumber numberWithBool:YES] forKey:@"load"]; // By default the annotations are loaded at startup
            
            arrayAfterResource = [uriResource componentsSeparatedByString:@"?"];
            if([arrayAfterResource count] > 0)
                [parameters setObject:[arrayAfterResource objectAtIndex:0] forKey:@"resource"];
            if([arrayAfterResource count] == 2){
                arrayArguments = [[arrayAfterResource objectAtIndex:1] componentsSeparatedByString:@"&"];
                                
                for (NSString *param in arrayArguments) {
                    NSArray *keyAndObject = [param componentsSeparatedByString:@"="];
                    if ([keyAndObject count] == 2) {
                        [parameters setObject:[[keyAndObject objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[keyAndObject objectAtIndex:0]];
                        // NSLog(@"%@ = %@", [keyAndObject objectAtIndex:0], [parameters objectForKey:[keyAndObject objectAtIndex:0]]);
                    }
                }    
            }
            [dic setObject:parameters forKey:@"params"];
        } 
        
        // Setting inset padding if present in the annotation parameters
        if([parameters objectForKey:@"padding"]){
            int padding = [[parameters objectForKey:@"padding"] intValue];
            rect = CGRectInset(rect, padding, padding);
        }
                 
        NSString *class = nil;
        if(extensions && [extensions count] > 0){
            for(NSString *extension in extensions){
                if ((UIView <FPKView> *)[NSClassFromString(extension) respondsToPrefix:uriType]) {
                    class = extension;
                    NSLog(@"Found Extension %@ that supports %@", extension, uriType);
                }
            } 
        }
        
        if (class && ((load && [[parameters objectForKey:@"load"] boolValue]) || !load)){
            UIView *aView = [(UIView <FPKView> *)[NSClassFromString(class) alloc] initWithParams:dic andFrame:[documentViewController convertRect:rect toViewFromPage:page] from:self];
            retVal = aView;
            // [aView release];
        } else {
            NSLog(@"No Extension found that supports %@", uriType);
        }
    }
    
    return retVal;
}

#pragma -
#pragma FPKOverlayViewDataSource


- (NSArray *)documentViewController:(MFDocumentViewController *)dvc overlayViewsForPage:(NSUInteger)page{
    // NSLog(@"overlayViewsForPage: Method Framework %i", page);
    
    [overlays removeAllObjects];
    NSArray *annotations = [[documentViewController document] uriAnnotationsForPageNumber:page];
    
    for (FPKURIAnnotation *ann in annotations) {
        UIView *view = [self showAnnotationForOverlay:YES withRect:[ann rect] andUri:[ann uri] onPage:page];
        
        if(view != nil){
            [view setFrame:[documentViewController convertRect:view.frame fromOverlayToPage:page]];
            [(UIView <FPKView> *)view setRect:view.frame];
            [overlays addObject:view];
        }
        [view release];
    }
    
    return [NSArray arrayWithArray:overlays];
}

- (CGRect)documentViewController:(MFDocumentViewController *)dvc rectForOverlayView:(UIView *)view onPage:(NSUInteger)page{    
    return [(UIView <FPKView> *)view rect];
}


- (void)dealloc {
    [overlays release];
    [extensions release];
	[super dealloc];
}

@end
