//
//  MainViewController.m
//  SampleProject
//
//  Created by Matteo Gavagnin on 12/29/11.
//  Copyright (c) 2011 MobFarm s.a.s. All rights reserved.
//

#import "MainViewController.h"
#import <FastPdfKit/ReaderViewController.h>
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
    ReaderViewController *pdfViewController = [[ReaderViewController alloc]initWithDocumentManager:documentManager];
    
    /** Set resources folder on the manager */
    documentManager.resourceFolder = thumbnailsPath;
    
    /** Set document id for thumbnail generation */
    pdfViewController.documentId = documentName;
    [pdfViewController setPadding:0.0];
    
    /**
     Instantiating the FPKOverlayManager (you can find in the the FPKShared framework) to manage extensions.
     
     You can use initWithExtensions or set them manually in the init method.

     NSArray *extensions = [[NSArray alloc] initWithObjects:@"FPKYouTube", nil];
     OverlayManager *_overlayManager = [[[OverlayManager alloc] initWithExtensions:extensions] autorelease];
     */
    
    OverlayManager *_overlayManager = [[[OverlayManager alloc] init] autorelease];

    /** Add the FPKOverlayManager as OverlayViewDataSource to the ReaderViewController */
    [pdfViewController addOverlayViewDataSource:_overlayManager];
    
    /** Rester as DocumentDelegate to receive tap */
    [pdfViewController addDocumentDelegate:_overlayManager];
    
    /** Set the DocumentViewController to obtain access the the conversion methods */
    [_overlayManager setDocumentViewController:(MFDocumentViewController <OverlayDataSourceDelegate> *)pdfViewController];
    
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
