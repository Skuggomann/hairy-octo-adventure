//
//  InputLayer.h
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol InputLayerDelegate <NSObject>

- (void)touchBegan;
- (void)touchEnded;

@end

@interface InputLayer : CCLayer
{

}

@property (nonatomic, weak) id<InputLayerDelegate> delegate;

@end
