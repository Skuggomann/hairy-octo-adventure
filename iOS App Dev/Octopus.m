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
#import "cocos2d.h"
#define PhysicsIdentifier(key) ((__bridge id)(void *)(@selector(key)))


@implementation Octopus 
- (id)initWithSpaceAndParentNode:(ChipmunkSpace *)space position:(CGPoint)position parent:(CCNode*)parent lives:(int)lives;
{
    self = [super initWithFile:@"Octo.png"];
    if (self)
    {
        _space = space;
        _GameNode = parent;
        
        // Load configuration file
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@"plist"]];
        
        
        if (_space != nil)
        {
            //self.scale = 0.7+lives*.1;
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
            _immunity = 2.0f;
            
            
            //[self addChild: tenticle];
            
            // Add to space
            [_space addBody:octoBody];
            [_space addShape:shape];
            
            CGPoint tPos = position;
            tPos.y-=size.height/1.2;

            // Setup particle system for speedboost
            _goFast = [CCParticleSystemQuad particleWithFile:@"GoFast.plist"];
            _goFast.position = position;
            [_goFast stopSystem];
            [parent addChild:_goFast];
            // Setup particle system for inkspurt
            //_inkSpurt = [CCParticleGalaxy node];
            _inkSpurt = [CCParticleSystemQuad particleWithFile:@"InkSpurt.plist"];
            _inkSpurt.position = position;
            [_inkSpurt stopSystem];
            [parent addChild:_inkSpurt];
            _blood = [CCParticleSystemQuad particleWithFile:@"blood.plist"];
            _blood.position = position;
            [_blood stopSystem];
            [parent addChild:_blood];
            
            
            // Add self to body and body to self
            octoBody.data = self;
            self.chipmunkBody = octoBody;
            
            cpVect anch1;
            anch1.x = 0;
            anch1.y = 0;
            cpVect anch2;
            anch2.x = 0;

            
            _tentacles = [NSMutableArray array];
            constraintDeleteIndex = 0;
            constraintIndex = 0;
            tentacleDeleteIndex = 0;

            for (int i = 0; i<lives; i++){
                OctopusTentacle *tent = [[OctopusTentacle alloc] initWithSpace:_space position:tPos post:NO];
                [_GameNode addChild:tent];
                anch2.y = tent.textureRect.size.height/2;
                cpConstraint *derp = cpPinJointNew(tent.CPBody, octoBody.body, anch2, anch1);
                cpSpaceAddConstraint(_space.space, derp);
                
                _constraints[i] = derp;
                constraintIndex++;
                
                [_tentacles addObject:tent];
            }
            
        
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
    if(_immunity>=0.0f){
        return;
    }
    if(--_lives<=0){
            CCLabelTTF *dead = [CCLabelTTF labelWithString:@"YOU ARE DEAD"	 fontName:@"Arial" fontSize:30];
            dead.position = ccp(CCRANDOM_0_1()*game->_winSize.width,CCRANDOM_0_1()*game->_winSize.height);
            dead.rotationX = CCRANDOM_0_1()*360;
            dead.rotationY = CCRANDOM_0_1()*360;
            dead.color = [self randomColor];
            [game addChild:dead];
        //lose game
    }
    else{
        _blood.position = self.position;
        NSLog(@"OCTO: %@", NSStringFromCGPoint(self.position));
        NSLog(@"blood: %@", NSStringFromCGPoint(_blood.position));
        [_blood resetSystem];
        /*self.scale = 0.7+_lives*.1;
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
         */
        
        //OctopusTentacle *tent = _tentacles.lastObject;
        //[tent removeAllChildren];

        
        //cpSpaceRemoveConstraint(cpConstraintGetSpace(_constraints[constraintDeleteIndex]),_constraints[constraintDeleteIndex++]);
        if(_constraints[constraintDeleteIndex]!=NULL){
            //OctopusTentacle *tent = [_tentacles firstObjectCommonWithArray:_tentacles];
            OctopusTentacle *tent = _tentacles[tentacleDeleteIndex++];
            tent.isDead = YES;
            cpSpaceAddPostStepCallback(_space.space, (cpPostStepFunc)postStepRemove, _constraints[constraintDeleteIndex], NULL);
        }
        _constraints[constraintDeleteIndex++] = NULL;
        if (constraintDeleteIndex >= 8)
            constraintDeleteIndex = 0;

        /*for (ChipmunkShape *shape in tent.chipmunkBody.shapes)
        {
            [_space smartRemove:shape];
        }
        [tent.chipmunkBody.data removeFromParentAndCleanup:YES];
        */
    }
}

-(void) grow
{
    if(_lives>7)
        ;//8 is the maximum number of extra lives
    else{
        _lives++;
        /*self.scale = 0.7+_lives*.1;
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
         */
        
        CGPoint tPos = self.position;
        tPos.y-=self.textureRect.size.height/1.2;
        
        cpVect anch1;
        anch1.x = 0;
        anch1.y = 0;
        cpVect anch2;
        anch2.x = 0;
        
        OctopusTentacle *tent = [[OctopusTentacle alloc] initWithSpace:_space position:tPos post:YES];
        [_GameNode addChild:tent];
        anch2.y = tent.textureRect.size.height/2;
        cpConstraint *derp = cpPinJointNew(tent.CPBody, self.chipmunkBody.body, anch2, anch1);
        //cpSpaceAddConstraint(_space.space,derp);

        
        cpSpaceAddPostStepCallback(_space.space, (cpPostStepFunc)postStepAdd, derp, NULL);
        
        _constraints[constraintIndex++] = derp;
        if (constraintIndex>=8)
            constraintIndex = 0;
        
        [_tentacles addObject:tent];

    }
}
-(void) goingFast
{
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"warp2.WAV" pitch:self.chipmunkBody.vel.x/10000 + 1 pan:0 gain:1.0f];
    // Play particle effect
    _goFast.position = self.position;
    NSLog(@"OCTO: %@", NSStringFromCGPoint(self.position));
    NSLog(@"goingFast: %@", NSStringFromCGPoint(_goFast.position));
    _immunity = 2.0f;
    [_goFast resetSystem];
}
-(void) inkSpurt
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"pokeoutofsand.WAV"pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1.0f];
    // Play particle effect
    _inkSpurt.position = self.position;
    NSLog(@"OCTO: %@", NSStringFromCGPoint(self.position));
    NSLog(@"ink: %@", NSStringFromCGPoint(_inkSpurt.position));
    [_inkSpurt resetSystem];
}

static void
postStepRemove(cpSpace *space, cpConstraint *constraint, void *unused)
{
    cpSpaceRemoveConstraint(space,constraint);
}
static void
postStepAdd(cpSpace *space, cpConstraint *constraint, void *unused)
{
    cpSpaceAddConstraint(space,constraint);
}
-(void) update:(ccTime)delta
{
    _immunity=_immunity-delta;
}


@end
