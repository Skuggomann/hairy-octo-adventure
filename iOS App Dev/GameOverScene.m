//
//  GameOverScene.m
//  iOS App Dev
//
//  Created by Lion User on 30/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "GameOverScene.h"
#import "cocos2d.h"
#import "Game.h"

@implementation GameOverScene

- (id)initWithScore:(NSInteger) score
{
    self = [super init];
    if (self != nil)
    {
        
        // Creating a start button:
        CCLabelTTF *startLabel = [CCLabelTTF labelWithString:@"RETRY" fontName:@"Arial" fontSize:48];
        CCMenuItemLabel *startButton = [CCMenuItemLabel itemWithLabel:startLabel block:^(id sender)
                                        {
                                            Game *gameScene = [[Game alloc] init];
                                            [[CCDirector sharedDirector] replaceScene:gameScene];
                                        }];
        startButton.position = ccp([CCDirector sharedDirector].winSize.width/2, [CCDirector sharedDirector].winSize.height - 150); // Position the button in the middle.
        
        

        // Creating a start button:
        CCLabelTTF *ScoreText= [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d", score] fontName:@"Arial" fontSize:60];
        ScoreText.position = ccp([CCDirector sharedDirector].winSize.width/2, [CCDirector sharedDirector].winSize.height - 50); // Position the button in the middle.
        [self addChild:ScoreText];
        
        
        // Creating a back button:
        CCLabelTTF *backLabel = [CCLabelTTF labelWithString:@"Main\nMenu" fontName:@"Arial" fontSize:28];
        CCMenuItemLabel *backButton = [CCMenuItemLabel itemWithLabel:backLabel block:^(id sender)
                                       {
                                           [[CCDirector sharedDirector] popScene];
                                       }];
        backButton.position = ccp(50, [CCDirector sharedDirector].winSize.height - 50); // Position the button.
        
        
        
        // Add a background:
        CCSprite *background = [CCSprite spriteWithFile:@"GameOverBackground.png"];
        background.anchorPoint = ccp(0, 0);
        background.position = ccp(0.0f, 0.0f);

        [self addChild:background];

        
        
        
        
        
        
        
        // Create the menu
        CCMenu *menu = [CCMenu menuWithItems :startButton, backButton, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
    }
    
    return self;
}

@end
