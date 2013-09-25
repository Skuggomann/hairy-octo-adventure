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
        _space.gravity = ccp(0.0f, -gravity);
        
        // Register collision handler
        _collisionHandler = [[Collision alloc] init];
        
        [_space setDefaultCollisionHandler:_collisionHandler
                                     begin:@selector(collisionBegan:space:)
                                  preSolve:nil
                                 postSolve:nil
                                  separate:nil];

        
        // Setup world
        [self setupGraphicsLandscape];
        
        // Add Octo
        _octo = [[Octopus alloc] initWithSpace:_space position:CGPointFromString(_configuration[@"startPosition"])];
        [_gameNode addChild:_octo];
        
        // Create an input layer
        InputLayer *inputLayer = [[InputLayer alloc] init];
        inputLayer.delegate = self;
        [self addChild:inputLayer];
        
        
        
        
        
        // Your initilization code goes here
        [self scheduleUpdate];
    }
    return self;
}

- (void)setupGraphicsLandscape
{
    // Sea
    //_seaLayer =[CCLayerGradient layerWithColor:ccc4(89, 67, 245, 255) fadingTo:ccc4(67, 219, 245, 255)];//TODO: make purple/blueish and opacity.
    //[self addChild:_seaLayer];	
    
    _parallaxNode = [CCParallaxNode node];
    [self addChild:_parallaxNode];
    
    CCSprite *sand =[self spriteWithColor:[self randomBrightColor]] ;
    sand.anchorPoint = ccp(0, 0);
    [_parallaxNode addChild:sand z:1 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    
    
    _gameNode = [CCNode node];
    [_parallaxNode addChild:_gameNode z:2 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
}

-(CCSprite *)spriteWithColor:(ccColor4F)bgColor {
    
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:_winSize.width height:_winSize.height];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
    
    // 3: Draw into the texture
    // You'll add this later
    
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
    
}


- (void)touchBegan
{
    
}

- (void)touchEnded
{

    NSLog(@"touch!");
    

    [_octo swimUp];
}

@end
