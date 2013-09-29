//
//  Sand.h
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "CCNode.h"
#import "cocos2d.h"
#import "ChipmunkAutoGeometry.h"
#define kMaxHillKeyPoints 1000
#define kHillSegmentWidth 2
#define kMaxHillVertices 4000
#define kMaxBorderVertices 800

@interface Sand : CCNode
{
    NSDictionary *_configuration;
    int _offsetX;
    CGSize _winSize;
    CGPoint _hillKeyPoints[kMaxHillKeyPoints];
    int _fromKeyPointI;
    int _toKeyPointI;
    int _nHillVertices;
    CGPoint _hillVertices[kMaxHillVertices];
    CGPoint _hillTexCoords[kMaxHillVertices];
    int _nBorderVertices;
    CGPoint _borderVertices[kMaxBorderVertices];
    ChipmunkSpace *_space;
}

- (void) setOffsetX:(float)newOffsetX;
- (id)initWithSpace:(ChipmunkSpace *) space;
@property (nonatomic, strong) ChipmunkBody *body;
@property (nonatomic, strong) CCSprite *stripes;
@end
