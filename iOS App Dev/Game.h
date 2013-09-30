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
@class Portal;
@class MuscleCrab;
@class JellyFish;
@interface Game : CCScene <InputLayerDelegate>
{
    @public
    Octopus *_octo;
    MuscleCrab *_crab;
    JellyFish *_jelly;
    Sand *_sand;
    Portal *_portal;
    CCLayerColor *_seaLayer;
    CGSize _winSize;
    NSDictionary *_configuration;
    ChipmunkSpace *_space;
    CCParallaxNode *_parallaxNode;
    CCNode *_gameNode;
    ccTime _accumulator;
    Collision *_collisionHandler;
    Boolean _swimming;
    CGFloat _swimTime;
    CCNode *_colletables;
    
    
    int _collectablesCollected;
    int _score;
    int _extraScore;
    CCLabelTTF *_lifeText;
    CCLabelTTF *_scoreText;
    
   
    
}

@end
