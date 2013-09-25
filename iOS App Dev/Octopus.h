//
//  Octopus.h
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Octopus : CCPhysicsSprite
{
    ChipmunkSpace *_space;
}

- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;

@end
