//
//  Collision.m
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Collision.h"

@implementation Collision

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (bool)collisionBegan:(cpArbiter *)arbiter space:(ChipmunkSpace*)space {
    cpBody *firstBody;
    cpBody *secondBody;
    cpArbiterGetBodies(arbiter, &firstBody, &secondBody);
    
    ChipmunkBody *firstChipmunkBody = firstBody->data;
    ChipmunkBody *secondChipmunkBody = secondBody->data;
    
    NSLog(@"Collision happened");
    
    
    /*
    if ((firstChipmunkBody == _tank.chipmunkBody && secondChipmunkBody == _goal.chipmunkBody) ||
        (firstChipmunkBody == _goal.chipmunkBody && secondChipmunkBody == _tank.chipmunkBody)){
        NSLog(@"TANK HIT GOAL :D:D:D xoxoxo");
        
        // Play sfx
        [[SimpleAudioEngine sharedEngine] playEffect:@"Impact.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
        
        // Remove physics body
        [_space smartRemove:_tank.chipmunkBody];
        for (ChipmunkShape *shape in _tank.chipmunkBody.shapes) {
            [_space smartRemove:shape];
        }
        
        // Remove tank from cocos2d
        [_tank removeFromParentAndCleanup:YES];
        
        // Play particle effect
        [_splashParticles resetSystem];
    }
    */
    
    return YES;
}


@end
