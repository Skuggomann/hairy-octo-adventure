//
//  MuscleCrab.m
//  iOS App Dev
//
//  Created by Lion User on 30/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "MuscleCrab.h"
#import "ChipmunkAutoGeometry.h"

@implementation MuscleCrab
- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
{
    self = [super initWithSpace:space position:position sprite:@"MuscleCrab.png"];
    if(self)
    {
        if (_space != nil)
        {
            CGSize size = self.textureRect.size;;
            cpFloat mass = size.width * size.height;
            cpFloat moment = cpMomentForBox(mass, size.width, size.height);
            
            ChipmunkBody *crabBody = [ChipmunkBody bodyWithMass:mass andMoment:moment];
            crabBody.angVelLimit = 0.1f;
            ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:crabBody width:size.width height:size.height];
            shape.elasticity = 1.0f;
            shape.friction = 0.0f;
            

            crabBody.pos = position;
            // Add to space
            [_space addBody:crabBody];
            [_space addShape:shape];
            
            // Add self to body and body to self
            crabBody.data = self;
            self.chipmunkBody = crabBody;
        }
    }
    return self;
}
@end
