//
//  Enemy.m
//  iOS App Dev
//
//  Created by Lion User on 30/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy
- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position sprite:(NSString*)sprite;
{
    self = [super initWithFile:sprite];
    if(self)
    {
        _space = space;
        // Load configuration file
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@"plist"]];
    }
    return self;
}
-(void) hitOcto;
{
    
}
@end
