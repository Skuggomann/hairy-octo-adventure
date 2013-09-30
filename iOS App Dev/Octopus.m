//
//  Octopus.m
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Octopus.h"
#import "ChipmunkAutoGeometry.h"
#import "SimpleAudioEngine.h"
#import "ccTypes.h"
#import "OctopusTentacle.h"
#define PhysicsIdentifier(key) ((__bridge id)(void *)(@selector(key)))


@implementation Octopus 
- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position lives:(int)lives;
{
    self = [super initWithFile:@"Octo.png"];
    if (self)
    {
        _space = space;
        
        // Load configuration file
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@"plist"]];
        
        
        if (_space != nil)
        {
            self.scale = 0.7+lives*.1;
            CGSize size = self.textureRect.size;
            size.height = size.height*(0.7+lives*.1);
            size.width = size.width*(0.7+lives*.1);
            cpFloat mass = size.width * size.height;
            cpFloat moment = cpMomentForBox(mass, size.width, size.height);
            
            ChipmunkBody *octoBody = [ChipmunkBody bodyWithMass:mass andMoment:moment];
            
            
            //cpBodySetMoment(octoBody.body, INFINITY);
            //octoBody.angVelLimit = 0.0f;
            
            
            octoBody.pos = position;
            //ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:octoBody width:size.width height:size.height];// Make it the correct shape. 
            ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:octoBody radius:size.width/2 offset:cpvzero];
            
            shape.elasticity = 1.0f;	
            shape.friction = 1000.0f;
            shape.group = PhysicsIdentifier(OCTO);
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
            
            
            _lives = lives;
            
            
            //[self addChild: tenticle];
            
            // Add to space
            [_space addBody:octoBody];
            [_space addShape:shape];
            
            CGPoint tPos = position;
            tPos.y-=32;
            

            
            // Add self to body and body to self
            octoBody.data = self;
            self.chipmunkBody = octoBody;
            
            /*cpVect anch1;
            anch1.x = 0;
            anch1.y = 0;
            cpVect anch2;
            anch2.x = 0;
            anch2.y = 32;
            
            
            OctopusTentacle *tent = [[OctopusTentacle alloc] initWithSpace:_space position:tPos];
            //[self addChild:tent];
            cpSpaceAddConstraint(_space.space, cpPinJointNew(tent.CPBody, octoBody.body, anch2, anch1));
                                 //(tent.CPBody,octoBody.body, 0, 360));
                  */               
            
        }
    }
    return self;
}

- (void)swimUp
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"swim-below.WAV" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:5.0f];
    cpVect directionalVector = cpvsub(CGPointFromString(_configuration[@"swimDirection"]), CGPointZero);
    cpVect impulseVector = cpvmult(directionalVector, self.chipmunkBody.mass * [_configuration[@"forceUp"]floatValue]);
    [self.chipmunkBody applyImpulse:impulseVector offset:cpvzero];
}

-(ccColor3B)randomColor
{
    float r = arc4random() % 255;
    float g = arc4random() % 255;
    float b = arc4random() % 255;
    return ccc3(r,g,b);
}

- (void)shrink:(Game*)game
{
    _lives--;
    if(_lives<=0){
            CCLabelTTF *dead = [CCLabelTTF labelWithString:@"YOU ARE DEAD"	 fontName:@"Arial" fontSize:30];
            dead.position = ccp(CCRANDOM_0_1()*game->_winSize.width,CCRANDOM_0_1()*game->_winSize.height);
            dead.rotationX = CCRANDOM_0_1()*360;
            dead.rotationY = CCRANDOM_0_1()*360;
            dead.color = [self randomColor];
            [game addChild:dead];
        //lose game
    }
    else{
        self.scale = 0.7+_lives*.1;
        CGSize size = self.textureRect.size;
        size.height = size.height*(0.7+_lives	*.1);
        size.width = size.width*(0.7+_lives*.1);
        cpFloat mass = size.width * size.height;
        cpFloat moment = cpMomentForBox(mass, size.width, size.height);
    
        ChipmunkBody *octoBody = [ChipmunkBody bodyWithMass:mass andMoment:moment];
    
    
        octoBody.pos = self.position;
        ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:octoBody radius:size.width/2 offset:cpvzero];
    
        shape.elasticity = 1.0f;
        shape.friction = 1000.0f;
    
    
        [_space removeBody:self.chipmunkBody];
        for (ChipmunkShape * s in self.chipmunkBody.shapes){
            [_space removeShape:s];
        }
        [_space addBody:octoBody];
        [_space addShape:shape];
    
    
    
    
        // Add self to body and body to self
        octoBody.data = self;
        self.chipmunkBody = octoBody;
    }
}

-(void) grow
{
    if(_lives>7)
        ;//8 is the maximum number of extra lives
    else{
        _lives++;
        self.scale = 0.7+_lives*.1;
        CGSize size = self.textureRect.size;
        size.height = size.height*(0.7+_lives*.1);
        size.width = size.width*(0.7+_lives*.1);
        cpFloat mass = size.width * size.height;
        cpFloat moment = cpMomentForBox(mass, size.width, size.height);
        
        ChipmunkBody *octoBody = [ChipmunkBody bodyWithMass:mass andMoment:moment];
        
        
        octoBody.pos = self.position;
        ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:octoBody radius:size.width/2 offset:cpvzero];
        
        shape.elasticity = 1.0f;
        shape.friction = 1000.0f;
        
        
        [_space removeBody:self.chipmunkBody];
        for (ChipmunkShape * s in self.chipmunkBody.shapes){
            [_space removeShape:s];
        }
        [_space addBody:octoBody];
        [_space addShape:shape];
        
        
        
        
        // Add self to body and body to self
        octoBody.data = self;
        self.chipmunkBody = octoBody;
    }
}

@end
