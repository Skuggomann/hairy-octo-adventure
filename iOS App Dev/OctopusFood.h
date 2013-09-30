//
//  OctopusFood.h
//  iOS App Dev
//
//  Created by Lion User on 29/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface OctopusFood : CCPhysicsSprite
{
    ChipmunkSpace *_space;
}
- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
@end
