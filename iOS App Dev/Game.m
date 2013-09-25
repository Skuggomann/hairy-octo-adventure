//
//  Game.m
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/17/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Game.h"
#import "Octopus.h"

@implementation Game

- (id)init
{
    self = [super init];
    if (self)
    {
        //Set random seed;
        srandom(time(NULL));
        _winSize = [CCDirector sharedDirector].winSize;
        
        // Load configuration file
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@"plist"]];
        
        // Create physics world
        _space = [[ChipmunkSpace alloc] init];
        CGFloat gravity = [_configuration[@"gravity"] floatValue];
        _space.gravity = ccp(0.f, -gravity);
        _space.damping = 0.5;
        // Register collision handler
        _collisionHandler = [[Collision alloc] init];
        
        [_space setDefaultCollisionHandler:_collisionHandler
                                     begin:@selector(collisionBegan:space:)
                                  preSolve:nil
                                 postSolve:nil
                                  separate:nil];

        
        // Setup world
        [self setupGraphicsLandscape];
        
        // Create body and shape
        ChipmunkBody *body = [ChipmunkBody staticBody];
        
        body.pos = ccp(0.0f, _winSize.height);
        ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:999999999 height:1];        
        
        // Add to world
        [_space addShape:shape];
        
        // Add Octo
        _octo = [[Octopus alloc] initWithSpace:_space position:CGPointFromString(_configuration[@"startPosition"])];
        [_gameNode addChild:_octo];
        
        // Create an input layer
        InputLayer *inputLayer = [[InputLayer alloc] init];
        inputLayer.delegate = self;
        [self addChild:inputLayer];
        _swimming = NO;
        _swimTime = 0;
        
    
        
        
        // Your initilization code goes here
        [self scheduleUpdate];
    }
    return self;
}

- (void)setupGraphicsLandscape
{

    
    _parallaxNode = [CCParallaxNode node];
    [self addChild:_parallaxNode];
    

    CCSprite *mountains = [CCSprite spriteWithFile:@"Cliffs v3.png"];
    mountains.anchorPoint = ccp(0, 0);
    [_parallaxNode addChild:mountains z:0 parallaxRatio:ccp(0.1f, 1.0f) positionOffset:CGPointZero];
    
    CCSprite *sand =[self spriteWithColor:[self randomBrightColor]];
    sand.anchorPoint = ccp(0, 0);
    [_parallaxNode addChild:sand z:1 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    
    // Sea
    _seaLayer = [CCLayerColor layerWithColor:ccc4(89, 67, 245, 255) width:_winSize.width  height:_winSize.height];
    _seaLayer.anchorPoint = CGPointZero;
    _seaLayer.opacity = 60;
    [_parallaxNode addChild:_seaLayer z:2 parallaxRatio:ccp(0.0f, 0.0f) positionOffset:CGPointZero];
    
    _gameNode = [CCNode node];
    [_parallaxNode addChild:_gameNode z:3 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    
    
    
}


-(CCSprite *)spriteWithColor:(ccColor4F)bgColor {
    
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:_winSize.width height:_winSize.height];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
    
    // 3: Draw into the texture
    // You'll add this later
    CCSprite *noise = [CCSprite spriteWithFile:@"Noise.png"];
    [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
    noise.position = ccp(_winSize.width/2, _winSize.height/2);
    [noise visit];
    
    
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
    
}

- (ccColor4F)randomBrightColor {
    
    while (true) {
        float requiredBrightness = 192;
        ccColor4B randomColor =
        ccc4(arc4random() % 255,
             arc4random() % 255,
             arc4random() % 255,
             255);
        if (randomColor.r > requiredBrightness ||
            randomColor.g > requiredBrightness ||
            randomColor.b > requiredBrightness) {
            return ccc4FFromccc4B(randomColor);
        }
    }
    
}
// Update logic goes here
- (void)update:(ccTime)delta
{
    // Run the physics engine.
    CGFloat fixedTimeStep = 1.0f / 240.0f;
    _accumulator += delta;
    while (_accumulator > fixedTimeStep)
    {
        [_space step:fixedTimeStep];
        _accumulator -= fixedTimeStep;
    }
    

    
    if (_octo.position.x >= (_winSize.width / 2)) //&& _octo.position.x < (_landscapeWidth - (_winSize.width / 2)))
    {
        _parallaxNode.position = ccp(-(_octo.position.x - (_winSize.width / 2)), 0);
    }

    

    cpVect Rightforce = cpvsub(CGPointFromString(_configuration[@"rightForce"]), CGPointZero);
    Rightforce = cpvmult(Rightforce, _octo.chipmunkBody.mass*delta);
    [_octo.chipmunkBody applyImpulse:(Rightforce) offset:(cpvzero)];
    
    

    _swimTime -= delta;
    if(_swimming && _swimTime <= 0){
        _swimTime = 0.5;
        [_octo swimUp];
    }
}


- (void)touchBegan
{
    NSLog(@"touch!");
    
    _swimming = YES;
}

- (void)touchEnded
{
    _swimming = NO;
}

@end
