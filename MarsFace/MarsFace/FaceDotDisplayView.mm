//
//  FaceDotDisplayView.m
//
//  Created by PixPark on 2024/11/18.
//

#import "FaceDotDisplayView.h"

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

@interface FaceDotDisplayView() {
    std::vector<marsface::FaceDetectionInfo> face_objects_;
}

@property (nonatomic, strong) UILabel *lbYpr;
@property (strong, nonatomic) UILabel *lbFaceAction;

@end

@implementation FaceDotDisplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.lbYpr = [[UILabel alloc] init];
        self.lbYpr.textColor = [UIColor greenColor];
        self.lbYpr.numberOfLines = 0;
        [self addSubview:self.lbYpr];
        
        self.lbFaceAction = [[UILabel alloc] init];
        self.lbFaceAction.textColor = [UIColor greenColor];
        self.lbFaceAction.numberOfLines = 1;
        self.lbFaceAction.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lbFaceAction];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [self.lbYpr sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
    self.lbYpr.frame = CGRectMake(self.frame.size.width-size.width-4, 4, size.width, size.height);
    
    size = [self.lbFaceAction sizeThatFits:CGSizeMake(CGFLOAT_MAX, 30)];
    self.lbFaceAction.frame = CGRectMake(self.frame.size.width-size.width-8, CGRectGetMaxY(self.lbYpr.frame)+10, size.width, size.height);
}
 

-(void)drawRect:(CGRect)rect {
    //获得处理的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //设置线条样式
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    
    CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, 1.0);
    
    //设置线条粗细宽度
    CGContextSetLineWidth(ctx, 1.5);
    
    float w = self.presetSize.width;
    float h = self.presetSize.height;
    if (ScreenWidth>ScreenHeight) {
        w = self.presetSize.height;
        h = self.presetSize.width;
    }
    float kw = self.frame.size.width/w;
    float kh = self.frame.size.height/h;
    
    for(int i = 0; i < face_objects_.size(); i++) {
        float x = face_objects_[i].rect.left *kw;
        float y = face_objects_[i].rect.top *kh;
        float w = (face_objects_[i].rect.right - face_objects_[i].rect.left) *kw;
        float h = (face_objects_[i].rect.bottom - face_objects_[i].rect.top) *kh;
        
        CGContextStrokeRect(ctx, CGRectMake(x, y, w, h));
         
        for (int j = 0; j < face_objects_[i].landmarks.size(); j++) {
            float p_x = face_objects_[i].landmarks[j].x *kw;
            float p_y = face_objects_[i].landmarks[j].y *kh;
            bool visibilities = true;
            if (visibilities) {
                CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
            } else {
                CGContextSetRGBFillColor(ctx, 0.2, 0.2, 1.0, 1.0);
            }
            CGContextAddArc(ctx, p_x, p_y, 1.7, 0, 2 * M_PI, 0);
            CGContextDrawPath(ctx, kCGPathFill);
            
            bool showPointOrder = false;
            if (showPointOrder) {
                NSString *str = [NSString stringWithFormat:@"%d", j];
                UIFont *font = [UIFont systemFontOfSize:9.0];
                NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                [paragraphStyle setAlignment:NSTextAlignmentCenter];
                CGRect iRect = CGRectMake(p_x-10, p_y-11, 22, 25);
                UIColor *color = [UIColor redColor];
                [str drawInRect:iRect withAttributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:color}];
            }
        }
        
        // score
        NSString *str = [NSString stringWithFormat:@"%f", face_objects_[i].score];
        UIFont *font = [UIFont systemFontOfSize:14.0];
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        CGRect iRect = CGRectMake(x, y-16, w, 20);
        UIColor *color = [UIColor whiteColor];
        [str drawInRect:iRect withAttributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:color}];
    }
}

-(void)setDetectResult:(std::vector<marsface::FaceDetectionInfo>) objects {
    face_objects_ = objects;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

 

@end
