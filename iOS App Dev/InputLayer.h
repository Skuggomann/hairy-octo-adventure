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

- (void)touchEndedAtPositon:(CGPoint)point afterDelay:(NSTimeInterval)delay;

@end

@interface InputLayer : CCLayer
{
    NSDate *_touchBeganDate;
}

@property (nonatomic, weak) id<InputLayerDelegate> delegate;

@end
