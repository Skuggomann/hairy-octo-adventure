//
//  Collision.m
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Collision.h"
#import "Game.h"
#import "OctopusFood.h"
#import "Portal.h"
#import "Octopus.h"
#import "Enemy.h"



@implementation Collision

- (id)initWithGame:(Game *)game;
{
    self = [super init];
    if (self) {
        _Game = game;
        // Load configuration file
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@"plist"]];
    }
    return self;
}


- (bool)collisionBegan:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
{
    
    
    //_Game->_octo;
    
    //NSLog(@"Collision happened");
    
    
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
    if([self collisionBetween:arbiter FirstBody:_Game->_portal.chipmunkBody SecondBody:_Game->_octo.chipmunkBody]){
        //[space smartRemove:_Game->_portal.chipmunkBody];
        //[_Game->_portal removeFromParentAndCleanup:YES];
        /*for (ChipmunkShape *shape in _Game->_portal.chipmunkBody.shapes){
            [space smartRemove:shape];
        }
        [_Game->_portal removeFromParentAndCleanup:YES];*/
        cpVect impulseVector = cpvmult(cpv(1, 0.1) , _Game->_octo.chipmunkBody.mass * [_configuration[@"speedBoost"]floatValue]);
        [_Game->_octo.chipmunkBody applyImpulse:impulseVector offset:cpvzero];
        [_Game->_octo goingFast];
    }
    
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
    
    if  (
         ([firstChipmunkBody.data isKindOfClass:[OctopusFood class]] && [secondChipmunkBody.data isKindOfClass:[Octopus class]])
         ||
         ([firstChipmunkBody.data isKindOfClass:[Octopus class]] && [secondChipmunkBody.data isKindOfClass:[OctopusFood class]])
        )
    {
        ChipmunkBody *deleteChipmunkBody;
        if([firstChipmunkBody.data isKindOfClass:[OctopusFood class]])
        {
            deleteChipmunkBody = firstChipmunkBody;
        }
        else
        {
            deleteChipmunkBody = secondChipmunkBody;
        }
        
        
        for (ChipmunkShape *shape in deleteChipmunkBody.shapes)
        {
            [space smartRemove:shape];
        }
        [deleteChipmunkBody.data removeFromParentAndCleanup:YES];

        //TODO: Give the player some points.
        ++_Game->_collectablesCollected;
        _Game->_extraScore += (int)(0.005 * _Game->_octo.position.x * _Game->_collectablesCollected);
        [_Game->_octo inkSpurt];
        
        
            
        //NSLog(@"Octo got ink! %d", (int)(0.005 * _Game->_octo.position.x * _Game->_collectablesCollected));
        return YES;
    }
    
    //Enemy hit
    if  (
         ([firstChipmunkBody.data isKindOfClass:[Enemy class]] && [secondChipmunkBody.data isKindOfClass:[Octopus class]])
         ||
         ([firstChipmunkBody.data isKindOfClass:[Octopus class]] && [secondChipmunkBody.data isKindOfClass:[Enemy class]])
         )
    {
        ChipmunkBody *enemyChipmunkBody;
        if([firstChipmunkBody.data isKindOfClass:[Enemy class]])
        {
            enemyChipmunkBody = firstChipmunkBody;
        }
        else
        {
            enemyChipmunkBody = secondChipmunkBody;
        }
        NSLog(@"%s",[enemyChipmunkBody.data isLethal]? "true" : "false");
        if([enemyChipmunkBody.data isLethal])
        {
            [enemyChipmunkBody.data hitOcto];
            
        }
        
        //[space addPostStepCallback:self selector:@selector(sleep:) key:enemyChipmunkBody];
        //cpSpaceAddPostStepCallback(space.space, (cpPostStepFunc)SleepEnemy, enemyChipmunkBody.body, NULL);
        //cpBodySleep(enemyChipmunkBody.body);
        //[_Game->_octo shrink:_Game];
        return YES;
    }
    
   
    
        
    return YES;
}
/*
- (bool)collisionEnded:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
{
    cpBody *firstBody;
    cpBody *secondBody;
    cpArbiterGetBodies(arbiter, &firstBody, &secondBody);
    
    ChipmunkBody *firstChipmunkBody = firstBody->data;
    ChipmunkBody *secondChipmunkBody = secondBody->data;
    //Enemy hit
    if  (
         ([firstChipmunkBody.data isKindOfClass:[Enemy class]] && [secondChipmunkBody.data isKindOfClass:[Octopus class]])
         ||
         ([firstChipmunkBody.data isKindOfClass:[Octopus class]] && [secondChipmunkBody.data isKindOfClass:[Enemy class]])
         )
    {
        ChipmunkBody *enemyChipmunkBody;
        if([firstChipmunkBody.data isKindOfClass:[Enemy class]])
        {
            enemyChipmunkBody = firstChipmunkBody;
        }
        else
        {
            enemyChipmunkBody = secondChipmunkBody;
        }
        [enemyChipmunkBody sleep];
    }
    return YES;
}
- (void) sleep:(ChipmunkBody*) body
{
    //[body sleep];
}*/

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
