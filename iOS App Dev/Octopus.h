//
//  Octopus.h
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Game.h"

@interface Octopus : CCPhysicsSprite
{
    ChipmunkSpace *_space;
    CCParticleSystemQuad *_splashParticles;
    NSDictionary *_configuration;
}

- (id)initWithSpaceAndParentNode:(ChipmunkSpace *)space position:(CGPoint)position parent:(CCNode*)parent lives:(int)lives;
- (void)swimUp;
- (void)shrink:(Game*)game;
- (void)grow;
- (void)goingFast;
@property int lives;

@end
