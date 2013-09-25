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
#import "Sand.h"

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
        CGFloat rightForce = [_configuration[@"gravity"] floatValue];
        _space.gravity = ccp(rightForce, -gravity);
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
    // Sea
    //_seaLayer =[CCLayerGradient layerWithColor:ccc4(89, 67, 245, 255) fadingTo:ccc4(67, 219, 245, 255)];//TODO: make purple/blueish and opacity.
    //[self addChild:_seaLayer];	
    
    _parallaxNode = [CCParallaxNode node];
    [self addChild:_parallaxNode];
    
    //sand
    _sand = [[Sand alloc] initWithSpace:_space];
    [self genBackground];
    
    [_parallaxNode addChild:_sand z:1 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    
    _gameNode = [CCNode node];
    [_parallaxNode addChild:_gameNode z:2 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
}
- (void)genBackground {
    
    
    ccColor4F color3 = [self randomBrightColor];
    ccColor4F color4 = [self randomBrightColor];
    CCSprite *stripes = [self stripedSpriteWithColor1:color3 color2:color4
                                         textureWidth:512 textureHeight:512
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
    float gradientAlpha = 0.7;
    
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
    
    
    
    if (_octo.position.x >= (_winSize.width / 2)) //&& _octo.position.x < (_landscapeWidth - (_winSize.width / 2)))
    {
        _parallaxNode.position = ccp(-(_octo.position.x - (_winSize.width / 2)), 0);
        [_sand setOffsetX:(_octo.position.x)];
    }
    
    
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
