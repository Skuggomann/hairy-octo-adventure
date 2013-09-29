//
//  Collision.m
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Collision.h"
#import "Game.h"
#import "Octopus.h"
#import "OctopusFood.h"


@implementation Collision

- (id)initWithGame:(Game *)game;
{
    self = [super init];
    if (self) {
        _Game = game;
    }
    return self;
}


- (bool)collisionBegan:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
{
    
    
    //_Game->_octo;
    
    NSLog(@"Collision happened");
    
    
    /*
    if ([self collisionBetween:arbiter FirstBody:_tank.chipmunkBody SecondBody:_goal.chipmunkBody]	)
    {
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
    
    /*
    if ([self collisionBetween:arbiter FirstBody:_Game->_octo.chipmunkBody SecondBody:_Game->]	)
    {
        
    }
    */
    
    
    // Chekk if you are coliding with a collectable object that gives points! :)
    cpBody *firstBody;
    cpBody *secondBody;
    cpArbiterGetBodies(arbiter, &firstBody, &secondBody);
    
    ChipmunkBody *firstChipmunkBody = firstBody->data;
    ChipmunkBody *secondChipmunkBody = secondBody->data;
    
    if ([firstChipmunkBody.data isKindOfClass:[OctopusFood class]] && [secondChipmunkBody.data isKindOfClass:[Octopus class]] )
    {
        if ([firstChipmunkBody.data isKindOfClass:[Octopus class]] && [secondChipmunkBody.data isKindOfClass:[OctopusFood class]] ) {
            
            for (ChipmunkShape *shape in firstChipmunkBody.shapes)
            {
                [space smartRemove:shape];
            }
            [firstChipmunkBody.data removeFromParentAndCleanup:YES];

            //TODO: Give the player some points.
            ++_Game->collectablesCollected;
            _Game->score += 0.1 * _Game->_octo.position.x * _Game->collectablesCollected;
            
            
            NSLog(@"Octo got ink!");
        }
    }
    
   
    
        
    return YES;
}


- (bool)collisionBetween:(cpArbiter *)arbiter FirstBody:(ChipmunkBody*)bodyOne SecondBody: (ChipmunkBody*)bodyTwo
{
    cpBody *firstBody;
    cpBody *secondBody;
    cpArbiterGetBodies(arbiter, &firstBody, &secondBody);
    
    ChipmunkBody *firstChipmunkBody = firstBody->data;
    ChipmunkBody *secondChipmunkBody = secondBody->data;

    if ((firstChipmunkBody == bodyOne && secondChipmunkBody == bodyTwo) ||
        (firstChipmunkBody == bodyTwo && secondChipmunkBody == bodyOne))
    {
        return YES;
    }
    else
    {
        return NO;
    }

}


@end
