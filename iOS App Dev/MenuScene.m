//
//  MenuScene.m
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/24/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "MenuScene.h"
#import "cocos2d.h"
#import "Game.h"
#import "HowToScene.h"
#import "SimpleAudioEngine.h"


@implementation MenuScene

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // Creating a start button:
        CCLabelTTF *startLabel = [CCLabelTTF labelWithString:@"START" fontName:@"Arial" fontSize:48];
        CCMenuItemLabel *startButton = [CCMenuItemLabel itemWithLabel:startLabel block:^(id sender)
                                   {
                                       Game *gameScene = [[Game alloc] init];
                                       [[CCDirector sharedDirector] pushScene:gameScene];
                                   }];
        startButton.position = ccp([CCDirector sharedDirector].winSize.width/2, [CCDirector sharedDirector].winSize.height - 100); // Position the button in the middle.
        
        
        // Creating a start button:
        CCLabelTTF *howToLabel = [CCLabelTTF labelWithString:@"How To Play" fontName:@"Arial" fontSize:30];
        CCMenuItemLabel *howToButton = [CCMenuItemLabel itemWithLabel:howToLabel block:^(id sender)
                                        {
                                            HowToScene *howToScene = [[HowToScene alloc] init];
                                            [[CCDirector sharedDirector] pushScene:howToScene];
                                        }];
        howToButton.position = ccp([CCDirector sharedDirector].winSize.width/2, [CCDirector sharedDirector].winSize.height - 200); // Position the button in the middle.
        
        
        
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"23 Dire, Dire Docks.mp3"];

        
        
        
        // Create the menu
        CCMenu *menu = [CCMenu menuWithItems :startButton, howToButton, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
    }
    
    return self;
}

@end
