//
//  TIViewController.m
//  EasyProCam
//
//  Created by Tatsu Ikeda on 2/25/14.
//  Copyright (c) 2014 Tatsu Ikeda. All rights reserved.
//

#import "TIViewController.h"

@interface TIViewController ()

@end

@implementation TIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    self.inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    [self.inputDevice lockForConfiguration:&error];
    [self.inputDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    [self.inputDevice unlockForConfiguration];

    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.inputDevice error:&error];
    if (error)
    {
        NSLog(@"%@",error);
    } else {
        if ([session canAddInput:deviceInput])
        {
            [session addInput:deviceInput];
            
            self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            if ([session canAddOutput:self.stillImageOutput]){
                [session addOutput:self.stillImageOutput];
                
                AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
                [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                
                CALayer *rootLayer = [[self view] layer];
                [rootLayer setMasksToBounds:YES];
                [previewLayer setFrame:CGRectMake(-70, 0, rootLayer.bounds.size.height, rootLayer.bounds.size.height)];
                [rootLayer insertSublayer:previewLayer atIndex:0];
                
                [session startRunning];
            }
        }
    }
}


- (IBAction)shutterAction:(id)sender {
    
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in connection.inputPorts)
        {
            if ([port.mediaType isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
            }
        }
        if (videoConnection) break;
    }
    
    CGPoint exposurePoint = [self.inputDevice exposurePointOfInterest];
    NSLog(@"%@", NSStringFromCGPoint(exposurePoint));
    
    [self.redBox setCenter:exposurePoint];
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (error)
        {
            NSLog(@"%@",error);
        } else {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            CIContext *context = [CIContext contextWithOptions:nil];
            
            CIImage *ciImage = [[CIImage alloc] initWithImage:image];
            NSNumber *highlightAdjust = [NSNumber numberWithFloat:1.0];
            NSNumber *shadowAdjust = [NSNumber numberWithFloat:2.0];
            CIFilter *filter = [CIFilter filterWithName:@"CIHighlightShadowAdjust"
                                          keysAndValues:
                                kCIInputImageKey, ciImage,
                                @"inputHighlightAmount",highlightAdjust,
                                @"inputShadowAmount",shadowAdjust,
                                nil];
            
            CIImage *output = [filter outputImage];
            
            CGImageRef cgimg = [context createCGImage:output fromRect:[output extent]];
            
            UIImage *filteredImage = [UIImage imageWithCGImage:cgimg];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageWriteToSavedPhotosAlbum(filteredImage, nil, nil, NULL);
            });
            
        }
    }];
    
}

@end
