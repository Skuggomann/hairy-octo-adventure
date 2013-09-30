//
//  Enemy.h
//  iOS App Dev
//
//  Created by Lion User on 30/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Enemy : CCPhysicsSprite
{
    ChipmunkSpace *_space;
    NSDictionary *_configuration;
}

-(id)initWithSpace:(ChipmunkSpace*)space position:(CGPoint)position sprite:(NSString*)sprite;
-(void)hitOcto;
@end
