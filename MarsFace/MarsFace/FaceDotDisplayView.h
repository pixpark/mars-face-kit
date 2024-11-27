//
//  FaceDotDisplayView.h
//
//  Created by PixPark on 2019/12/24.
//

#import <UIKit/UIKit.h>
#include "MarsFaceKit/mars_type_defines.h"

NS_ASSUME_NONNULL_BEGIN
 
@interface FaceDotDisplayView : UIView

@property (nonatomic, assign) CGSize presetSize;// 图像分辨率

-(void)setDetectResult:(std::vector<marsface::FaceDetectionInfo>) objects;
@end

NS_ASSUME_NONNULL_END
