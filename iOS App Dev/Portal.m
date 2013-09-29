//
//  Portal.m
//  iOS App Dev
//
//  Created by Lion User on 29/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Portal.h"
#import "ObjectiveChipmunk.h"

@implementation Portal

- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position
{
    self = [super initWithFile:@"Speedarrow.png"];
    if (self) {
        CGSize size = self.textureRect.size;
        
        // Create body and shape
        ChipmunkBody *body = [ChipmunkBody staticBody];
        body.pos = position;
        ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:size.width height:size.height];
        shape.sensor = YES;
        
        // Add to world
        [space addShape:shape];
        
        // Add self to body and body to self
        body.data = self;
        self.chipmunkBody = body;
    }
    return self;
}

@end