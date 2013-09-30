//
//  OctopusTentacle.m
//  iOS App Dev
//
//  Created by Lion User on 29/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "OctopusTentacle.h"
#import "ChipmunkAutoGeometry.h"

#define PhysicsIdentifier(key) ((__bridge id)(void *)(@selector(key)))


@implementation OctopusTentacle
- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position{
    self = [super initWithFile: @"Tentacle.png"];
    if(self){
        _space = space;
        
        // Load configuration file
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@"plist"]];
        
        if (_space != nil)
        {
            CGSize size = self.textureRect.size;
            cpFloat mass = 10;
            cpFloat moment = cpMomentForBox(mass, size.width, size.height);
            
            ChipmunkBody *tentacleBody = [ChipmunkBody bodyWithMass:mass andMoment:moment];
            
            tentacleBody.pos = position;
            
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"Tentacle" withExtension:@"png"];
            ChipmunkImageSampler *sampler = [ChipmunkImageSampler samplerWithImageFile:url isMask:NO];
            
            [sampler setBorderValue:0.0];
            
            ChipmunkPolylineSet *lines = [sampler marchAllWithBorder:TRUE hard:FALSE];
            ChipmunkPolyline *line = [lines lineAtIndex:0];
            //NSAssert(lines.count == 1 && line.area > 0.0, @"Degenerate image hull.");

            ChipmunkPolyline *hull = [[line simplifyCurves:1.0] toConvexHull:1.0];
            ChipmunkShape *shape = [hull asChipmunkPolyShapeWithBody:tentacleBody offset:cpvneg(self.anchorPointInPoints)];
            shape.group = PhysicsIdentifier(OCTO);
            
            //shape.sensor = YES;
            
            [_space addBody:tentacleBody];
            [_space addShape:shape];
            tentacleBody.data = self;
            self.chipmunkBody = tentacleBody;
        }
    }
    return self;
}


static void
postStepAddTentacle(cpSpace *space, cpConstraint *constraint, void *unused)
{
    cpSpaceRemoveConstraint(space,constraint);
}

@end
