//
//  Collision.h
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChipmunkAutoGeometry.h"


@class Game;
@interface Collision : NSObject
{
    Game *_Game;
    NSDictionary *_configuration;
}

- (id)initWithGame:(Game *)game;

@end
