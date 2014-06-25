//
//  MyScene.m
//  AnimatedBear
//
//  Created by FangYiXiong on 14-6-25.
//  Copyright (c) 2014年 Fang YiXiong. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "MyScene.h"

@implementation MyScene
{
    SKSpriteNode *_bear;
    NSArray *_bearWalkingFrames;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor blackColor];
        // 1. 建立一个数组来存放走路的各个帧
        NSMutableArray *walkFrames = [NSMutableArray array];
        // 2. 加载并设置纹理贴图集
        SKTextureAtlas *bearAnimatedAtlas = [SKTextureAtlas atlasNamed:@"BearImages"];
        // 3. 收集帧的列表
        int numImages = bearAnimatedAtlas.textureNames.count;
        for (int i=1; i <= numImages/2; i++) {
            NSString *textureName = [NSString stringWithFormat:@"bear%d",i];
            SKTexture *temp = [bearAnimatedAtlas textureNamed:textureName];
            [walkFrames addObject:temp];
        }
        _bearWalkingFrames = walkFrames;
        // 4. 创建精灵，位置为屏幕正中，然后加入到场景中
        SKTexture *temp = _bearWalkingFrames[0];
        _bear = [SKSpriteNode spriteNodeWithTexture:temp];
        _bear.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:_bear];
        [self walkingBear];
    }
    return self;
}

// 让熊行走的动画
- (void)walkingBear{
    // 增加这个 Key 是为了 forces the animation to be removed if your code should call this method again to restart the animation. This will be important later on when to make sure animations are not stepping on each other.
    [_bear runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:_bearWalkingFrames
                                       timePerFrame:0.1
                                             resize:NO
                                            restore:YES]]
             withKey:@"walkingInPlaceBear"];
}

// 根据用户点击屏幕左边还是右半来决定熊朝向哪边，朝向用xScale的正负值来决定
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint location = [[touches anyObject] locationInNode:self];
    CGFloat multiplierForDirection;
/*
    if (location.x <= CGRectGetMidX(self.frame)) {
        // 向左走
        multiplierForDirection = 1;
    }else{
        // 向右走
        multiplierForDirection = -1;
    }
    
    _bear.xScale = fabs(_bear.xScale) * multiplierForDirection;
    [self walkingBear];
 */
    
    // 设置熊的移动速度
    CGSize screenSize = self.frame.size;
    float bearVelocity = screenSize.width / 3.0;
    
    // 计算 x 和 y 方向上的位移量
    CGPoint moveDifference = CGPointMake(location.x - _bear.position.x, location.y - _bear.position.y);
    
    // 计算直接移动的直线距离，勾股定理
    float distanceToMove = sqrtf(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
    
    // 计算出熊的运动总时长
    float moveDuration = distanceToMove / bearVelocity;
    
    // 调转熊的朝向
    if (moveDifference.x < 0) {
        multiplierForDirection = 1;
    }else{
        multiplierForDirection = -1;
    }
    _bear.xScale = fabs(_bear.xScale) * multiplierForDirection;
    
    // 运行相应的动作
    
    // 先停止之前的行走动画
    if ([_bear actionForKey:@"bearMoving"]) {
        // 停止移动到新地点的动画，但是保留走路的动画
        [_bear removeActionForKey:@"bearMoving"];
    }
    
    // 让腿走路的动画开始
    if (![_bear actionForKey:@"walkingInPlaceBear"]) {
        // 如果走路动画没有运行，开始运行
        [self walkingBear];
    }
    
    // 创建行走的动画，并指定时间
    SKAction *moveAction = [SKAction moveTo:location duration:moveDuration];
    
    // 创建完成动画，完成后移除所有动画
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^{
        NSLog(@"Animation Completed");
        [self bearMoveEnded];
    }];
    
    // 把上面两个动画连成一个序列，
    SKAction *moveActionWithDone = [SKAction sequence:@[moveAction,doneAction]];
    
    [_bear runAction:moveActionWithDone withKey:@"bearMoving"];
}

- (void)bearMoveEnded{
    [_bear removeAllActions];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

}




-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end