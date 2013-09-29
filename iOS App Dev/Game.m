//
//  Game.m
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/17/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//
// Used this tutorial for the texture generation, TODO: change it so it matches our project better.
// http://www.raywenderlich.com/33266/how-to-create-dynamic-textures-with-ccrendertexture-in-cocos2d-2-x

#import "Game.h"
#import "Octopus.h"
#import "OctopusFood.h"
#import "Sand.h"
#import "Portal.h"
#import "SimpleAudioEngine.h"

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
        _collisionHandler = [[Collision alloc] initWithGame:self];
        
        [_space setDefaultCollisionHandler:_collisionHandler
                                     begin:@selector(collisionBegan:space:)
                                  preSolve:nil
                                 postSolve:nil
                                  separate:nil];
        //_space.iterations = 15;
        
        // Setup world
        [self setupGraphicsLandscape];
        
        // Create upper boundry.
        ChipmunkBody *body = [ChipmunkBody staticBody]; 
        body.pos = ccp(0.0f, _winSize.height+51);
        ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:999999999 height:100];
        shape.elasticity = 0.5f;
        shape.friction = 0.0f;
        
        [_space addShape:shape];
        
        
        
        // Add Octo
        _octo = [[Octopus alloc] initWithSpace:_space position:CGPointFromString(_configuration[@"startPosition"]) lives:3	];
        [_gameNode addChild:_octo];
        

        _score = 0;
        _extraScore = 0;
        _collectablesCollected = 0;
        
        
        if (_lifeText == NULL){
            _lifeText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Lives:%d", _octo.lives]	 fontName:@"Arial" fontSize:18];
            _lifeText.position = ccp(50,20);
            [self addChild:_lifeText];
        }
        if (_scoreText == NULL){
            _scoreText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score:%d", _score+_extraScore]	 fontName:@"Arial" fontSize:18];
            _scoreText.position = ccp(200,20);
            [self addChild:_scoreText];
        }
        
        _portal = [[Portal alloc] initWithSpace:_space position:ccp(300,200)];//CGPointFromString(_configuration[@"goalPosition"])];
        [_gameNode addChild:_portal];

        
        
        
        
        
        
        
        
        
        
        
        // Create an input layer
        InputLayer *inputLayer = [[InputLayer alloc] init];
        inputLayer.delegate = self;
        [self addChild:inputLayer];
        _swimming = NO;
        _swimTime = 0;
        
        
        // Setup a Chipmunk debug thingy:
        CCPhysicsDebugNode *debug = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
        debug.visible = YES;
        [_gameNode addChild:debug z:20];
        
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"swim-below.WAV"];

        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"23 Dire, Dire Docks.mp3" loop:YES];
        
        

        
        
        
        // Your initilization code goes here
        [self scheduleUpdate];
    }
    return self;
}

- (void)setupGraphicsLandscape
{

    
    _parallaxNode = [CCParallaxNode node];
    [self addChild:_parallaxNode];
    
    // Sand
    _sand = [[Sand alloc] initWithSpace:_space];
    [self genBackground];
    [_parallaxNode addChild:_sand z:1 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    
    // Mountains
    CCSprite *mountains = [CCSprite spriteWithFile:@"Cliffs v3.png"];
    mountains.anchorPoint = ccp(0, 0.25f);
    mountains.position = ccp(0.0f, 0.0f);
    mountains.scale = 2.0f;
    
    [_parallaxNode addChild:mountains z:0 parallaxRatio:ccp(0.1f, 1.0f) positionOffset:CGPointZero];
    
    // Sea
    _seaLayer = [CCLayerColor layerWithColor:ccc4(89, 67, 245, 255) width:_winSize.width  height:_winSize.height];
    _seaLayer.anchorPoint = CGPointZero;
    _seaLayer.opacity = 60;
    [_parallaxNode addChild:_seaLayer z:2 parallaxRatio:ccp(0.0f, 0.0f) positionOffset:CGPointZero];
    
    _gameNode = [CCNode node];
    [_parallaxNode addChild:_gameNode z:3 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    
    
    
}
- (void)genBackground {
    
    
    //ccColor4F color3 = [self randomBrightColor];//ccc4f(240, 233, 180, 1.0f);
    ccColor4F color3 = ccc4FFromccc4B(ccc4(210, 200, 150, 255));
    //ccColor4F color4 = [self randomBrightColor];//ccc4f(50, 250, 50, 1.0f);
    ccColor4F color4 = ccc4FFromccc4B(ccc4(201, 188, 145, 255));
    CCSprite *stripes = [self stripedSpriteWithColor1:color3 color2:color4
                                         textureWidth:512
                                        textureHeight:512
                                              stripes:4];
    ccTexParams tp2 = {GL_LINEAR, GL_LINEAR, GL_REPEAT,GL_CLAMP_TO_EDGE};
    [stripes.texture setTexParameters:&tp2];
    _sand.stripes = stripes;
    
}

-(CCSprite *)stripedSpriteWithColor1:(ccColor4F)c1 color2:(ccColor4F)c2 textureWidth:(float)textureWidth
                       textureHeight:(float)textureHeight stripes:(int)nStripes {
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureWidth height:textureHeight];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:c1.r g:c1.g b:c1.b a:c1.a];
    
    // 3: Draw into the texture
    
    // Layer 1: Stripes
    CGPoint vertices[nStripes*6];
    ccColor4F colors[nStripes*6];
    
    int nVertices = 0;
    float x1 = -textureHeight;
    float x2;
    float y1 = textureHeight;
    float y2 = 0;
    float dx = textureWidth / nStripes * 2;
    float stripeWidth = dx/2;
    for (int i=0; i<nStripes; i++) {
        x2 = x1 + textureHeight;
        
        vertices[nVertices] = CGPointMake(x1, y1);
        colors[nVertices++] = (ccColor4F){c2.r, c2.g, c2.b, c2.a};
        
        vertices[nVertices] = CGPointMake(x1+stripeWidth, y1);
        colors[nVertices++] = (ccColor4F){c2.r, c2.g, c2.b, c2.a};
        
        vertices[nVertices] = CGPointMake(x2, y2);
        colors[nVertices++] = (ccColor4F){c2.r, c2.g, c2.b, c2.a};
        
        vertices[nVertices] = vertices[nVertices-2];
        colors[nVertices++] = (ccColor4F){c2.r, c2.g, c2.b, c2.a};
        
        vertices[nVertices] = vertices[nVertices-2];
        colors[nVertices++] = (ccColor4F){c2.r, c2.g, c2.b, c2.a};
        
        vertices[nVertices] = CGPointMake(x2+stripeWidth, y2);
        colors[nVertices++] = (ccColor4F){c2.r, c2.g, c2.b, c2.a};
        x1 += dx;
    }
    
    self.shaderProgram =
    [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
    
    // Layer 2: Noise
    CCSprite *noise = [CCSprite spriteWithFile:@"Noise.png"];
    [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
    noise.position = ccp(textureWidth/2, textureHeight/2);
    [noise visit];
    
    // Layer 3: Stripes
    CC_NODE_DRAW_SETUP();
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_TRUE, 0, colors);
    glDrawArrays(GL_TRIANGLES, 0, (GLsizei)nVertices);
    float gradientAlpha = 0.4;
    
    nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    
    vertices[nVertices] = CGPointMake(textureWidth, 0);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    
    vertices[nVertices] = CGPointMake(0, textureHeight);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    
    vertices[nVertices] = CGPointMake(textureWidth, textureHeight);
    colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
    
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_TRUE, 0, colors);
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
    
    // layer 3: top highlight
    float borderHeight = textureHeight/16;
    float borderAlpha = 0.3f;
    nVertices = 0;
    
    vertices[nVertices] = CGPointMake(0, 0);
    colors[nVertices++] = (ccColor4F){1, 1, 1, borderAlpha};
    
    vertices[nVertices] = CGPointMake(textureWidth, 0);
    colors[nVertices++] = (ccColor4F){1, 1, 1, borderAlpha};
    
    vertices[nVertices] = CGPointMake(0, borderHeight);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    
    vertices[nVertices] = CGPointMake(textureWidth, borderHeight);
    colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
    
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_TRUE, 0, colors);
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
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
    

    
    if (_octo.position.x >= (_winSize.width / 4)) //&& _octo.position.x < (_landscapeWidth - (_winSize.width / 2)))
    {
        _parallaxNode.position = ccp(-(_octo.position.x - (_winSize.width / 4)), 0);
        [_sand setOffsetX:(_octo.position.x)];
    }

    

    cpVect Rightforce = cpvsub(CGPointFromString(_configuration[@"rightForce"]), CGPointZero);
    Rightforce = cpvmult(Rightforce, _octo.chipmunkBody.mass*delta);
    [_octo.chipmunkBody applyImpulse:(Rightforce) offset:(cpvzero)];
    
    

    _swimTime -= delta;
    if(_swimming && _swimTime <= 0 && _octo.position.y < _winSize.height-40){
        _swimTime = 0.5;
        [_octo swimUp];
    }
    
    _score = _octo.position.x+_extraScore;
    
    _lifeText.string = [NSString stringWithFormat:@"Lives:%d", _octo.lives];
    _scoreText.string =[NSString stringWithFormat:@"Score:%d", _score];
    
    if(_portal.position.x < _octo.position.x-_winSize.width/4+30)
    {
        for (ChipmunkShape *shape in _portal.chipmunkBody.shapes){
            [_space smartRemove:shape];
        }
        [_portal removeFromParentAndCleanup:YES];
        NSLog(@"removed portal");
        _portal = [[Portal alloc] initWithSpace:_space position:ccp(_octo.position.x+1000,200)];//CGPointFromString(_configuration[@"goalPosition"])];
        [_gameNode addChild:_portal];
        NSLog(@"added portal");
        
    }
    
    //NSLog(@"OCTO: %@", NSStringFromCGPoint(_octo.position));
    
    
    
    
    
    
    
    // Add some ink bottles.
    
    
    
    
    
    
    
    
    
    
    
    
    
}


- (void)touchBegan
{
    //NSLog(@"touch!");
    
    _swimming = YES;
}

- (void)touchEnded
{
    _swimming = NO;
}

@end
