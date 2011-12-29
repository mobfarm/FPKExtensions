//
//  PDFViewController.h
//  SampleProject
//
//  Created by Matteo Gavagnin on 12/29/11.
//  Copyright (c) 2011 MobFarm s.a.s. All rights reserved.
//

#import <FastPdfKit/FastPdfKit.h>
#import <FPKShared/FPKOverlayManager.h>

@interface PDFViewController : ReaderViewController{
    FPKOverlayManager *overlayManager;
}
@property(nonatomic, assign) FPKOverlayManager *overlayManager;
@end
