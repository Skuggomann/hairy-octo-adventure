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
    // Check if the octo is colliding with portal (speed boost).
    if([self collisionBetween:arbiter FirstBody:_Game->_portal.chipmunkBody SecondBody:_Game->_octo.chipmunkBody]){
        cpVect impulseVector = cpvmult(cpv(1, 0.1) , _Game->_octo.chipmunkBody.mass * [_configuration[@"speedBoost"]floatValue]);
        [_Game->_octo.chipmunkBody applyImpulse:impulseVector offset:cpvzero];
        [_Game->_octo goingFast];
        return YES;
    }
    
    
    //Get the cpBody and Chipmunk body from the arbiter.
    cpBody *firstBody;
    cpBody *secondBody;
    cpArbiterGetBodies(arbiter, &firstBody, &secondBody);
    ChipmunkBody *firstChipmunkBody = firstBody->data;
    ChipmunkBody *secondChipmunkBody = secondBody->data;
    
    // Chekk if you are coliding with a collectable object that gives points! :)
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
        
        
        //Give the player points for the collectable (ink).
        ++_Game->_collectablesCollected;
        _Game->_extraScore += (int)(0.005 * _Game->_octo.position.x * _Game->_collectablesCollected);
        
        //play particle effect.
        [_Game->_octo inkSpurt];
        
        //make the octo grow (add a tentacle).
        [_Game->_octo grow];
        
        NSLog(@"removed ink");
        //random y for the next ink object spawned.
        float inky= CCRANDOM_0_1()*(_Game->_winSize.height-_Game->_winSize.height/3-45)+_Game->_winSize.height/3;
        
        //Make a new ink object with post:YES since its happening insidea collision handler. So that it´s added after the collision.
        _Game->_ink = [[OctopusFood alloc] initWithSpace:space position:ccp(_Game->_octo.position.x+(_Game->_winSize.width*3.2f),inky) post:YES];
        [_Game->_gameNode addChild:_Game->_ink];
        
        //Delete the old object.
        ChipmunkShape *s = deleteChipmunkBody.shapes.lastObject;
        
        //Remove the old object in post step callback function.
        cpSpaceAddPostStepCallback(space.space, (cpPostStepFunc)postStepRemoveBody,deleteChipmunkBody.body, s.shape);
        NSLog(@"added ink");
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
        
        //Check if the enemy isLethal, it is nonlethal for 2 seconds after collision with octo.
        NSLog(@"%s",[enemyChipmunkBody.data isLethal]? "true" : "false");
        if([enemyChipmunkBody.data isLethal])
        {
            //Call the hitOcto function which makes the enemy nonlethal.
            [enemyChipmunkBody.data hitOcto];
            
            //Shrink the octo due to damage ( Lose a tentacle)
            [_Game->_octo shrink:_Game];
        }
        
        return YES;
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

static void
postStepRemoveBody(cpSpace *space, cpBody *body, cpShape *shape)
{
    //Retarded piece of code that makes a ChipmunkSpace out of cpSpace, then removes a ChipmunkShape which is createed from cpShape from that space. Same for body.
    [[ChipmunkSpace spaceFromCPSpace:space] remove:[ChipmunkShape shapeFromCPShape:shape]];
    [[ChipmunkBody bodyFromCPBody:body].data removeFromParentAndCleanup:YES];
}

@end
