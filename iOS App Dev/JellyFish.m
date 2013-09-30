//
//  JellyFish.m
//  iOS App Dev
//
//  Created by Lion User on 30/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "JellyFish.h"

@implementation JellyFish
- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
{
    self = [super initWithSpace:space position:position sprite:@"JellyFish.png"];
    if(self)
    {
        if (_space != nil)
        {
            
            CGSize size = self.textureRect.size;
            ChipmunkBody *jellyBody = [ChipmunkBody staticBody];
            jellyBody.pos = position;
            //jellyBody.pos = ccp(position.x,position.y+size.height/2);
            ChipmunkShape *shape = [ChipmunkPolyShape  boxWithBody:jellyBody width:size.width height:size.height];
        
            shape.sensor = YES;
            
            [_space addShape:shape];
            jellyBody.data = self;
            self.chipmunkBody = jellyBody;
        }
    }
    return self;
}
- (void) hitOcto;
{
    NSLog(@"Jell-o");
    [super hitOcto];
}
-(void) update:(ccTime)delta;
{
    [super update:delta];
}
@end
