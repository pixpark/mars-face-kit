//
//  MarsFaceKit.h
//  MarsFaceKit
//
//  Created by PixPark on 2024/11/18.
//

#pragma once
#include "mars_type_defines.h"
namespace marsface {
class MarsFaceDetector {
public:
    static std::shared_ptr<MarsFaceDetector> CreateFaceDetector();
    
    virtual int Detect(const MarsImage &in, RotateType type, std::vector<FaceDetectionInfo> &objects) = 0;
};

}
