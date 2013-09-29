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
    NSDictionary *_configuration;
}

- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position lives:(int)lives;
- (void)swimUp;
- (void)shrink:(Game*)game;
- (void)grow;
@property int lives;

@end
