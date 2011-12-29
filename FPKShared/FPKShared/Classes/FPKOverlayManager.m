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


@implementation FPKOverlayManager
@synthesize overlays, documentViewController;

- (void)setExtensions:(NSArray *)ext{
    extensions = ext;
}

- (void)setScrollLock:(BOOL)lock{
    [documentViewController setScrollEnabled:!lock];
    [documentViewController setGesturesDisabled:lock];
}

- (void)setGlobalParametersFromAnnotation{
    NSLog(@"Set Global Parameters");
    NSString *uri;
    BOOL globalFound = NO;
    NSArray *ann = [[documentViewController document] uriAnnotationsForPageNumber:1];
    if([ann count] > 0){
        for (FPKURIAnnotation * annotation in ann) {
            if ([annotation.uri hasPrefix:@"global"]){
                uri = annotation.uri;
                NSLog(@"URI: %@", uri);
                globalFound = YES;
                // break;
            }
        }    
    }
    
    if(globalFound){
        NSArray *arrayParameter = nil;
        NSString *uriType = nil;
        NSString *uriResource = nil;
        NSArray *arrayAfterResource = nil;
        NSArray *arrayArguments = nil;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        // NSLog(@"%@", NSStringFromCGRect(rect));
        
        arrayParameter = [uri componentsSeparatedByString:@"://"];
        if([arrayParameter count] > 0){
            
            NSLog(@"%@", uriType);
            
            if([arrayParameter count] > 1){
                uriResource = [NSString stringWithFormat:@"%@", [arrayParameter objectAtIndex:1]];
                NSLog(@"%@", uriResource);
                
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
            }
            
            // PARAMETRI GLOBALI
            // Da usare nella prima pagina e basta.
            //    global://?mode=3&automode=3&zoom=1.0&padding=0&shadow=YES&sides=0.1&status=NO
            
            if([parameters objectForKey:@"mode"])
                [documentViewController setMode:[[parameters objectForKey:@"mode"] intValue]];
            if([parameters objectForKey:@"automode"])
                [documentViewController setAutoMode:[[parameters objectForKey:@"automode"] intValue]];        
            if([parameters objectForKey:@"zoom"]){
                [documentViewController setDefaultMaxZoomScale:[[parameters objectForKey:@"zoom"] floatValue]];
                NSLog(@"Zoom set to %f", [documentViewController defaultMaxZoomScale]);
            }
                
            if([parameters objectForKey:@"padding"])
                [documentViewController setPadding:[[parameters objectForKey:@"padding"] intValue]];
            if([parameters objectForKey:@"shadow"])
                [documentViewController setShowShadow:[[parameters objectForKey:@"padding"] boolValue]];
            if([parameters objectForKey:@"sides"])
                [documentViewController setDefaultEdgeFlipWidth:[[parameters objectForKey:@"sides"] floatValue]];
            if([parameters objectForKey:@"status"])
                [[UIApplication sharedApplication] setStatusBarHidden:![[parameters objectForKey:@"status"] boolValue] withAnimation:UIStatusBarAnimationSlide];
            if([parameters objectForKey:@"orientation"]){
                NSLog(@"Orientation: %@", [parameters objectForKey:@"orientation"]);
                // Tutti i valori di orientamento possibili: UIDeviceOrientationPortrait, UIDeviceOrientationPortraitUpsideDown, UIDeviceOrientationLandscapeRight, UIDeviceOrientationLandscapeLeft
                NSMutableDictionary *orientation = [NSMutableDictionary dictionary];
                
                NSArray *options = [[parameters objectForKey:@"orientation"] componentsSeparatedByString:@","];
                
                for(NSString *key in options){
                    if ([key isEqualToString:@"0"])
                        [orientation setObject:[NSNumber numberWithBool:YES] forKey:@"UIDeviceOrientationPortrait"];
                    else if ([key isEqualToString:@"1"])
                        [orientation setObject:[NSNumber numberWithBool:YES] forKey:@"UIDeviceOrientationPortraitUpsideDown"];
                    else if ([key isEqualToString:@"2"])
                        [orientation setObject:[NSNumber numberWithBool:YES] forKey:@"UIDeviceOrientationLandscapeRight"];
                    else if ([key isEqualToString:@"3"])
                        [orientation setObject:[NSNumber numberWithBool:YES] forKey:@"UIDeviceOrientationLandscapeLeft"];   
                }
                // FIXME: add this method to the FastPdfKit sample official project
                // [documentViewController setOrientationsSupported:orientation];
            }   
        }
    }
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
                if ([NSClassFromString(extension) respondsToPrefix:uriType]) {
                    class = extension;
                    NSLog(@"Found Extension %@ that supports %@", extension, uriType);
                }
            } 
        }
        
        if (class && ((load && [[parameters objectForKey:@"load"] boolValue]) || !load)){
            UIView *aView = (UIView *)[[NSClassFromString(class) alloc] initWithParams:dic andFrame:[documentViewController convertRect:rect toViewFromPage:page]];
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
