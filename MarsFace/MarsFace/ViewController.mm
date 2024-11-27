//
//  ViewController.m
//  MarsFace
//
//  Created by PixPark on 2024/11/18.
//

#import "ViewController.h"
#import "VideoCapturer.h"
#import <MarsFaceKit/mars_face_detector.h>
#import "FaceDotDisplayView.h"

@interface ViewController () <VCVideoCapturerDelegate> {
    std::shared_ptr<marsface::MarsFaceDetector> mars_face_;
}
@property (strong, nonatomic) VideoCapturer* videoCapturer;
@property (strong, nonatomic) FaceDotDisplayView* faceDotDisplayView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    [self initFace];
    
    [self startCapture];
}

-(void)initUI {
    [self.view setBackgroundColor:UIColor.whiteColor];
    // screen always light
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.videoCapturer.videoPreviewLayer.frame = self.view.layer.frame;
    self.videoCapturer.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:self.videoCapturer.videoPreviewLayer];
    
    
    _faceDotDisplayView = [[FaceDotDisplayView alloc] initWithFrame:CGRectMake(0,
                                                                       (self.view.frame.size.height -
                                                                        self.view.frame.size.width/(720.0/1280))/2,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.width/(720.0/1280))];
    self.faceDotDisplayView.presetSize = CGSizeMake(720, 1280);;
    [self.view addSubview:self.faceDotDisplayView];
}

-(void)initFace {
    // Create face detector
    mars_face_ = marsface::MarsFaceDetector::CreateFaceDetector();
}

-(void)startCapture {
    
    // Start video capture
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.videoCapturer startCapture];
    });
}

// camera frame callback
- (void)videoCaptureOutputDataCallback:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    auto width = CVPixelBufferGetWidth(imageBuffer);
    auto height = CVPixelBufferGetHeight(imageBuffer);
    auto stride = CVPixelBufferGetBytesPerRow(imageBuffer);
    auto pixels = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    NSTimeInterval ts = [self TimestampMs];
    marsface::MarsImage image;
    image.data = pixels;
    image.width = width;
    image.height = height;
    image.pixel_format = marsface::PixelFormat::RGBA;
    image.width_step = stride;
    
    std::vector<marsface::FaceDetectionInfo> face_info;
    mars_face_->Detect(image, marsface::RotateType::CLOCKWISE_ROTATE_0, face_info);
    [self printDetectorOutput:face_info Time:ts];
    [self.faceDotDisplayView setDetectResult:face_info];
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}
 
-(void)printDetectorOutput:(std::vector<marsface::FaceDetectionInfo>) objects Time:(NSTimeInterval)ts {
    if(objects.size() > 0) {
        printf("marsface size:%d score:%f, angle:%f landmarks size:%d dt:%f\n", objects.size(),
               objects[0].score,
               objects[0].angle,
               objects[0].landmarks.size(), [self TimestampMs] - ts);
    } else {
        printf("marsface dt:%f\n",[self TimestampMs] - ts);
    }
}

-(VideoCapturer*)videoCapturer {
    if(_videoCapturer == nil) {
        VCVideoCapturerParam *param = [[VCVideoCapturerParam alloc] init];
        param.frameRate = 30;
        
        param.sessionPreset = AVCaptureSessionPreset1280x720;
//        param.sessionPreset = AVCaptureSessionPreset1920x1080;
        
        param.pixelsFormatType = kCVPixelFormatType_32BGRA;
        
        param.devicePosition = AVCaptureDevicePositionFront;
//        param.devicePosition = AVCaptureDevicePositionBack;
        
        param.videoOrientation = AVCaptureVideoOrientationPortrait;
        _videoCapturer = [[VideoCapturer alloc] initWithCaptureParam:param error:nil];
        _videoCapturer.delegate = self;
    }
    
    return _videoCapturer;
}

-(NSTimeInterval)TimestampMs {
    // 如果需要毫秒级的时间戳
    NSTimeInterval ts = [[NSDate date] timeIntervalSince1970] * 1000;
    return ts;
}

@end


