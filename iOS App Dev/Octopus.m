//
//  Octopus.m
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Octopus.h"
#import "ChipmunkAutoGeometry.h"

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
            
            ChipmunkBody *octoBody = [ChipmunkBody bodyWithMass:mass andMoment:moment];
            
            
            //cpBodySetMoment(octoBody.body, INFINITY);
            //octoBody.angVelLimit = 0.0f;
            
            
            octoBody.pos = position;
            //ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:octoBody width:size.width height:size.height];// Make it the correct shape. 
            ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:octoBody radius:size.width/2 offset:cpvzero];
            
            shape.elasticity = 1.0f;
            //shape.friction = 100.0f;
            
            /*
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"Octo" withExtension:@"png"];
            ChipmunkImageSampler *sampler = [ChipmunkImageSampler samplerWithImageFile:url isMask:NO];
            
            ChipmunkPolylineSet *contour = [sampler marchAllWithBorder:NO hard:YES];
            ChipmunkPolyline *line = [contour lineAtIndex:0];
            ChipmunkPolyline *simpleLine = [line simplifyCurves:1];
            

            NSArray *terrainShapes = [simpleLine asChipmunkSegmentsWithBody:octoBody radius:0 offset:cpvzero];
            for (ChipmunkShape *shape in terrainShapes)
            {
                shape.elasticity = 1.0f;
                [_space addShape:shape];
            }
             */
            
            
            
            
            
            //[self addChild: tenticle];
            
            // Add to space
            [_space addBody:octoBody];
            [_space addShape:shape];
            
            
            
            
            
            // Add self to body and body to self
            octoBody.data = self;
            self.chipmunkBody = octoBody;
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
