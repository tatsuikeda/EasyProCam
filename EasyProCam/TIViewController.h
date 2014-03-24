//
//  TIViewController.h
//  EasyProCam
//
//  Created by Tatsu Ikeda on 2/25/14.
//  Copyright (c) 2014 Tatsu Ikeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TIViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *redBox;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureDevice *inputDevice;
@property (weak, nonatomic) IBOutlet UIImageView *tempImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tempOutputImageView;

- (IBAction)shutterAction:(id)sender;

@end
