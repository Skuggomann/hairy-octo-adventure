//
//  MuscleCrab.m
//  iOS App Dev
//
//  Created by Lion User on 30/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "MuscleCrab.h"
#import "ChipmunkAutoGeometry.h"
#import "SimpleAudioEngine.h"

@implementation MuscleCrab
- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
{
    self = [super initWithSpace:space position:position sprite:@"MuscleCrab.png"];
    if(self)
    {
        if (_space != nil)
        {
            /*
            CGSize size = self.textureRect.size;;
            cpFloat mass = [_configuration[@"crabMass"]floatValue];
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
             */
            
            CGSize size = self.textureRect.size;
            cpFloat mass = size.width*size.height;
            cpFloat moment = cpMomentForBox(mass, size.width, size.height);
            
            ChipmunkBody *tentacleBody = [ChipmunkBody bodyWithMass:mass andMoment:moment];
            
            tentacleBody.pos = position;
            
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"MuscleCrab" withExtension:@"png"];
            ChipmunkImageSampler *sampler = [ChipmunkImageSampler samplerWithImageFile:url isMask:NO];
            
            [sampler setBorderValue:0.8];
            
            ChipmunkPolylineSet *lines = [sampler marchAllWithBorder:TRUE hard:FALSE];
            ChipmunkPolyline *line = [lines lineAtIndex:0];
            //NSAssert(lines.count == 1 && line.area > 0.0, @"Degenerate image hull.");
            
            ChipmunkPolyline *hull = [[line simplifyCurves:1.0] toConvexHull:1.0];
            ChipmunkShape *shape = [hull asChipmunkPolyShapeWithBody:tentacleBody offset:cpvneg(self.anchorPointInPoints)];
            
            //shape.sensor = YES;
            
            [_space addBody:tentacleBody];
            [_space addShape:shape];
            tentacleBody.data = self;
            self.chipmunkBody = tentacleBody;
        }
    }
    return self;
}
- (void) hitOcto;
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"step-metalcap.WAV" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1.0f];
    NSLog(@"SnipSnip");
    [super hitOcto];
}
-(void) update:(ccTime)delta;
{
    [super update:delta];
}
@end
