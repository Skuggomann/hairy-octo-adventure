//
//  HowToScene.m
//  iOS App Dev
//
//  Created by Lion User on 26/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "HowToScene.h"
#import "cocos2d.h"

@implementation HowToScene

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // Creating a back button:
        CCLabelTTF *backLabel = [CCLabelTTF labelWithString:@"Back" fontName:@"Arial" fontSize:28];
        CCMenuItemLabel *backButton = [CCMenuItemLabel itemWithLabel:backLabel block:^(id sender)
                                        {
                                            [[CCDirector sharedDirector] popScene];
                                        }];
        backButton.position = ccp(50, [CCDirector sharedDirector].winSize.height - 50); // Position the button.
        
        
        
        
        
        // Add a background:
        CCSprite *background = [CCSprite spriteWithFile:@"HowToBackground.png"];
        background.anchorPoint = ccp(0, 0);
        background.position = ccp(0.0f, 0.0f);
        
        [self addChild:background];
        
        

        
        
        
        
        
        // Create the menu
        CCMenu *menu = [CCMenu menuWithItems :backButton, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
    }
    
    return self;
}

@end
