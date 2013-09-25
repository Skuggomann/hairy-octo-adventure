//
//  Octopus.m
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Octopus.h"

@implementation Octopus 
- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
{
    self = [super initWithFile:@"Octo.png"];
    if (self)
    {
        _space = space;
        
        // Load configuration file
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@"plist"]];
        
        
        if (_space != nil)
        {
            CGSize size = self.textureRect.size;
            cpFloat mass = size.width * size.height;
            cpFloat moment = cpMomentForBox(mass, size.width, size.height);
            
            ChipmunkBody *body = [ChipmunkBody bodyWithMass:mass andMoment:moment];
            body.pos = position;
            ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:size.width height:size.height];
            
            shape.elasticity = 1.0f;
            
            
            
            //[self addChild: tenticle];
            
            // Add to space
            [_space addBody:body];
            [_space addShape:shape];
            
            // Add self to body and body to self
            body.data = self;
            self.chipmunkBody = body;
        }
    }
    return self;
}

- (void)swimUp
{
    
    cpVect directionalVector = cpvsub(CGPointFromString(_configuration[@"swimDirection"]), CGPointZero);
    cpVect impulseVector = cpvmult(directionalVector, self.chipmunkBody.mass * [_configuration[@"forceUp"]floatValue]);
    [self.chipmunkBody applyImpulse:impulseVector offset:cpvzero];
}

@end
