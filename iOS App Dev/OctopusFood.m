//
//  OctopusFood.m
//  iOS App Dev
//
//  Created by Lion User on 29/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "OctopusFood.h"
#import "ObjectiveChipmunk.h"


@implementation OctopusFood
- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position post:(bool)post;
{
    // The Octopus main diet is crabs. They also eat mollusks, crayfish, scallops, snails, turtles, shrimp and fish.
    
    self = [super initWithFile:@"ink.png"];
    if (self)
    {
        _space = space;
        
        if (_space != nil)
        {
            CGSize size = self.textureRect.size;            
            ChipmunkBody *foodBody = [ChipmunkBody staticBody];

            foodBody.pos = position;
            
            ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:foodBody width:size.width height:size.height];
            //ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:foodBody radius:size.width/2 offset:cpvzero];
            shape.sensor = YES;
            
                       
                       
            // Add to space
            //[_space addBody:foodBody];
            //[_space addShape:shape];
            

            
            
            // Add self to body and body to self
            foodBody.data = self;
            self.chipmunkBody = foodBody;
            
            
            if(post)
                cpSpaceAddPostStepCallback(_space.space, (cpPostStepFunc)postStepAddShape, foodBody.body, shape.shape);
            else{
                [_space addShape:shape];
            }
        }
    }
    return self;
}

static void
postStepAddShape(cpSpace *space, cpBody *body, cpShape *shape)
{
    
    //[[ChipmunkSpace spaceFromCPSpace:space] addBody:[ChipmunkBody bodyFromCPBody:body]];
    [[ChipmunkSpace spaceFromCPSpace:space] addShape:[ChipmunkShape shapeFromCPShape:shape]];
    //cpSpaceAddShape(space, shape);

}
@end
