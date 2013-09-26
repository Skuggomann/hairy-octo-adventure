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
        backButton.position = ccp(50, 100); // Position the button.
        
        
        // Creating a start button:
        CCLabelTTF *howToText= [CCLabelTTF labelWithString:@"Press the screen to make Octo swim up." fontName:@"Arial" fontSize:18];
        howToText.position = ccp([CCDirector sharedDirector].winSize.width/2, [CCDirector sharedDirector].winSize.height - 50); // Position the button in the middle.
        [self addChild:howToText];
        
        
        
        
        
        
        
        // Create the menu
        CCMenu *menu = [CCMenu menuWithItems :backButton, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
    }
    
    return self;
}

@end
