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
#import "OctopusTentacle.h"
#import "ChipmunkAutoGeometry.h"


@interface Octopus : CCPhysicsSprite
{
    ChipmunkSpace *_space;
    CCNode *_GameNode;
    CCParticleSystemQuad *_goFast;
    CCParticleSystemQuad *_inkSpurt;
    NSDictionary *_configuration;
    cpConstraint *_constraints[8];
    int constraintIndex;
    int constraintDeleteIndex;
    int tentacleDeleteIndex;
}

- (id)initWithSpaceAndParentNode:(ChipmunkSpace *)space position:(CGPoint)position parent:(CCNode*)parent lives:(int)lives;
- (void)swimUp;
- (void)shrink:(Game*)game;
- (void)grow;
- (void)goingFast;
- (void)inkSpurt;
@property int lives;
@property NSMutableArray *tentacles;

@end
