//
//  MainViewController.m
//  SampleProject
//
//  Created by Matteo Gavagnin on 12/29/11.
//  Copyright (c) 2011 MobFarm s.a.s. All rights reserved.
//

#import "MainViewController.h"
#import "PDFViewController.h"
#import "OverlayManager.h"

@implementation MainViewController

-(IBAction)actionOpenPlainDocument:(id)sender{
    /** Set document name */
    NSString *documentName = @"sample";
    
    /** Get temporary directory to save thumbnails */
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    /** Set thumbnails path */
    NSString *thumbnailsPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",documentName]];
    
    /** Get document from the App Bundle */
    NSURL *documentUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:documentName ofType:@"pdf"]];
    
    /** Instancing the documentManager */
	MFDocumentManager *documentManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
    
	/** Instancing the readerViewController */
    PDFViewController *pdfViewController = [[PDFViewController alloc]initWithDocumentManager:documentManager];
    
    /** Set resources folder on the manager */
    documentManager.resourceFolder = thumbnailsPath;
    
    /** Set document id for thumbnail generation */
    pdfViewController.documentId = documentName;
    [pdfViewController setPadding:0.0];
    
    /**

    You can use initWithExtensions or set them manually in the init method.

     NSArray *extensions = [[NSArray alloc] initWithObjects:@"FPKYouTube", nil];
     OverlayManager *_overlayManager = [[[OverlayManager alloc] initWithExtensions:extensions] autorelease];

     */
    
    OverlayManager *_overlayManager = [[[OverlayManager alloc] init] autorelease];
    
    [_overlayManager setOverlays:[[NSMutableArray alloc] init]];
    
    [pdfViewController addOverlayViewDataSource:_overlayManager];    
    [pdfViewController setOverlayManager:_overlayManager];
    
    [_overlayManager setDocumentViewController:(MFDocumentViewController <OverlayDataSourceDelegate> *)pdfViewController];
    [_overlayManager setGlobalParametersFromAnnotation];
    
	/** Present the pdf on screen in a modal view */
    [self presentModalViewController:pdfViewController animated:YES]; 
    
    /** Release the pdf controller*/
    [pdfViewController release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
