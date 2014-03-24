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
    
#warning CAMERA IS DISABLED
    /*
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (error)
        {
            NSLog(@"%@",error);
        } else {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            */
    
            UIImage *image = self.tempImageView.image;
    
    
            //[self getNewExposurePointFromPrescan:image];
    
    
            CIContext *context = [CIContext contextWithOptions:nil];
            
            CIImage *inputImage = [[CIImage alloc] initWithImage:image];
    
            CIImage *outputImage = nil;
    
//            @autoreleasepool {
//                
//                
                // Highlight and Shadow Adjust
                NSNumber *radiusAdjust = [NSNumber numberWithFloat:1.45];
                NSNumber *highlightAdjust = [NSNumber numberWithFloat:0.25];
                NSNumber *shadowAdjust = [NSNumber numberWithFloat:0.95];
                
                CIFilter *filterHighlightShadowAdjust = [CIFilter filterWithName:@"CIHighlightShadowAdjust"
                                                                   keysAndValues:
                                                         kCIInputImageKey, inputImage,
                                                         @"inputRadius", radiusAdjust,
                                                         @"inputHighlightAmount",highlightAdjust,
                                                         @"inputShadowAmount",shadowAdjust,
                                                         nil];
                
                outputImage = [filterHighlightShadowAdjust valueForKey:kCIOutputImageKey];
//            }
//
//            @autoreleasepool {
    
                // Vibrance
                NSNumber *vibranceAdjust = [NSNumber numberWithFloat:0.015];
                
                CIFilter *filterVibranceAdjust = [CIFilter filterWithName:@"CIVibrance"
                                                            keysAndValues:
                                                  kCIInputImageKey,outputImage,
                                                  @"inputAmount",vibranceAdjust,
                                                  nil];
                
                outputImage = [filterVibranceAdjust valueForKey:kCIOutputImageKey];
//            }
    
            // Color Controls
//            @autoreleasepool {

                NSNumber *saturationAdjust = [NSNumber numberWithFloat:0.85];
                NSNumber *brightnessAdjust = [NSNumber numberWithFloat:0.00];
                NSNumber *contrastAdjust = [NSNumber numberWithFloat:1.00];
                
                CIFilter *filterColorControlsAdjust = [CIFilter filterWithName:@"CIColorControls"
                                                                 keysAndValues:
                                                       kCIInputImageKey,outputImage,
                                                       @"inputSaturation",saturationAdjust,
                                                       @"inputBrightness",brightnessAdjust,
                                                       @"inputContrast",contrastAdjust,
                                                       nil];
                
                outputImage = [filterColorControlsAdjust valueForKey:kCIOutputImageKey];
//            }
//            // Exposure Adjust
//            @autoreleasepool {

                NSNumber *eVAdjust = [NSNumber numberWithFloat:-0.45];
                
                CIFilter *filterExposureAdjustAdjust = [CIFilter filterWithName:@"CIExposureAdjust"
                                                                  keysAndValues:
                                                        kCIInputImageKey, outputImage,
                                                        @"inputEV", eVAdjust,
                                                        nil];
                
                outputImage = [filterExposureAdjustAdjust valueForKey:kCIOutputImageKey];
//            }
            // Tone Curve
//            @autoreleasepool {

                CIVector *toneCurveAdjust0 = [CIVector vectorWithX:0.000  Y:0.050];
                CIVector *toneCurveAdjust1 = [CIVector vectorWithX:0.200  Y:0.200];
                CIVector *toneCurveAdjust2 = [CIVector vectorWithX:0.400  Y:0.450];
                CIVector *toneCurveAdjust3 = [CIVector vectorWithX:0.825  Y:0.925];
                CIVector *toneCurveAdjust4 = [CIVector vectorWithX:1.000  Y:0.990];
                
                CIFilter *toneCurveFilter = [CIFilter filterWithName:@"CIToneCurve"];
                [toneCurveFilter setDefaults];
                [toneCurveFilter setValue:outputImage forKey:kCIInputImageKey];
                [toneCurveFilter setValue:toneCurveAdjust0 forKey:@"inputPoint0"];
                [toneCurveFilter setValue:toneCurveAdjust1 forKey:@"inputPoint1"];
                [toneCurveFilter setValue:toneCurveAdjust2 forKey:@"inputPoint2"];
                [toneCurveFilter setValue:toneCurveAdjust3 forKey:@"inputPoint3"];
                [toneCurveFilter setValue:toneCurveAdjust4 forKey:@"inputPoint4"];
                
                outputImage = [toneCurveFilter valueForKey:kCIOutputImageKey];
//            }

            // Noise Reduction
//            NSNumber *noiseLevelAdjust = [NSNumber numberWithFloat:0.07];
//            NSNumber *sharpnessAdjust = [NSNumber numberWithFloat:0.10];
//            
//            CIFilter *filterNoiseReductionAdjust = [CIFilter filterWithName:@"CINoiseReduction"
//                                                           keysAndValues:
//                                                 kCIInputImageKey, toneCurveResult,
//                                                 @"inputNoiseLevel",noiseLevelAdjust,
//                                                 kCIInputSharpnessKey,sharpnessAdjust,
//                                                 nil];
//    
//            CIImage *noiseReductionResult = [filterNoiseReductionAdjust valueForKey:kCIOutputImageKey];

            // Unsharp Mask
//            @autoreleasepool {

                NSNumber *radiusUnsharpMaskAdjust = [NSNumber numberWithFloat:1.5];
                NSNumber *intensityAdjust = [NSNumber numberWithFloat:0.75];
                
                CIFilter *filterUnsharpMaskAdjust = [CIFilter filterWithName:@"CIUnsharpMask"
                                                               keysAndValues:
                                                     kCIInputImageKey, outputImage,
                                                     @"inputRadius",radiusUnsharpMaskAdjust,
                                                     @"inputIntensity",intensityAdjust,
                                                     nil];
                
                outputImage = [filterUnsharpMaskAdjust valueForKey:kCIOutputImageKey];
//            }
            // Sharpen Luminance
//            @autoreleasepool {

                NSNumber *sharpenLuminanceAdjust = [NSNumber numberWithFloat:0.9];
                
                CIFilter *filterSharpenLuminance = [CIFilter filterWithName:@"CISharpenLuminance"
                                                              keysAndValues:
                                                    kCIInputImageKey, outputImage,
                                                    kCIInputSharpnessKey, sharpenLuminanceAdjust,
                                                    nil];
                
                // Render the output image
                outputImage = [filterSharpenLuminance outputImage];
//            }

            CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
            
            UIImage *filteredImage = [UIImage imageWithCGImage:cgimg];
    
            CFRelease(cgimg);
    
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageWriteToSavedPhotosAlbum(filteredImage, nil, nil, NULL);
                self.tempOutputImageView.image = filteredImage;
            });
            /*
        }
    }];
    */
}

- (CGPoint)getNewExposurePointFromPrescan:(UIImage *)image
{
    
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    width = (NSUInteger)(width * 0.01);
    height = (NSUInteger)(height * 0.01);
    NSLog(@"resized width: %lu", (unsigned long)width);
    NSLog(@"resized height: %lu", (unsigned long)height);
    
    UIGraphicsBeginImageContext(CGSizeMake((CGFloat)width, (CGFloat)height));
    [image drawInRect:CGRectMake(0, 0, (CGFloat)width, (CGFloat)height)];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    int count = width * height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), resized.CGImage);
    CGContextRelease(context);
    
    
    //CGFloat red = 0.0f;
    CGFloat green = 0.0f;
    //CGFloat blue = 0.0f;
    
    
    int byteIndex = 0;
    for (int ii = 0 ; ii < count ; ++ii)
    {
        
        //red += rawData[byteIndex] / 255.0f;
        green += rawData[byteIndex + 1] / 255.0f;
        //blue += rawData[byteIndex + 2] / 255.0f;
        //CGFloat alpha = rawData[byteIndex + 3] / 255.0f;
        byteIndex += 4;
        
    }
    
    
    CGFloat avgGreen = green / count;
    NSMutableArray *greens = [NSMutableArray array];
    
    byteIndex = 0;
    green = 0;
    for (int ii = 0 ; ii < count ; ++ii)
    {
        green = rawData[byteIndex + 1] / 255.0f;
        [greens addObject:[NSNumber numberWithFloat:green]];
        byteIndex += 4;
    }
    
    free(rawData);
    
    greens = (NSMutableArray *)[greens sortedArrayUsingSelector:@selector(compare:)];
    
    NSLog(@"Avg Green: %f",avgGreen);
    NSLog(@"Greens: %@",greens);
    
    NSNumber *chosenGreen = nil;
    
    for (NSNumber *g in greens)
    {
        if ([g floatValue] > avgGreen)
        {
            chosenGreen = g;
            break;
        }
    }
    
    NSLog(@"Chosen Green: %@",chosenGreen);
    
    byteIndex = 0;
    for (int ii = 0 ; ii < count ; ++ii)
    {
        green = rawData[byteIndex + 1] / 255.0f;
        if (green == chosenGreen.floatValue)
        {
            break;
        }
        byteIndex += 4;
    }
    
    NSLog(@"At Pixel: %d",byteIndex);
    
    NSLog(@"Resized Image Size: %@",NSStringFromCGSize(resized.size));
    
    CGFloat x = byteIndex % width;
    CGFloat y = ceilf(byteIndex / width);
    
    CGPoint point = CGPointMake(x, y);
    
    NSLog(@"At Point: %@",NSStringFromCGPoint(point));

    return CGPointZero;
}

@end
