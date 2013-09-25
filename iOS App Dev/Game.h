//
//  Game.h
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/17/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "InputLayer.h"
#import "Collision.h"


@class Sand;
@class Octopus;
@interface Game : CCScene <InputLayerDelegate>
{
    Octopus *_octo;
    Sand *_sand;
    CCLayerGradient *_seaLayer;
    CGSize _winSize;
    NSDictionary *_configuration;
    ChipmunkSpace *_space;
    CCParallaxNode *_parallaxNode;
    CCNode *_gameNode;
    ccTime _accumulator;
    Collision *_collisionHandler;
    Boolean _swimming;
    CGFloat _swimTime;
}

@end
