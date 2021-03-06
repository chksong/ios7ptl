//  Copyright (c) 2013 Rob Napier
//
//  This code is licensed under the MIT License:
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
#import "ViewController.h"
@import QuartzCore;

const CGPoint kInitialPoint1 = { .x = 200, .y = 300 };
const CGPoint kInitialPoint2 = { .x = 500, .y = 300 };

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *box1;
@property (weak, nonatomic) IBOutlet UIView *box2;
@property (nonatomic) UIDynamicAnimator *dynamicAnimator;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

  [self reset];
}

- (IBAction)reset {
  [self.dynamicAnimator removeAllBehaviors];
  self.box1.center = kInitialPoint1;
  self.box1.transform = CGAffineTransformIdentity;
  self.box2.center = kInitialPoint2;
  self.box2.transform = CGAffineTransformIdentity;
}

- (IBAction)snap {
  CGPoint point = [self randomPoint];
  UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.box1
                                                  snapToPoint:point];
  snap.damping = 0.95;   //是唯一科 该值越大，移动的越慢
  [self addTemporaryBehavior:snap];
}

//附照行为
- (IBAction)attach {
  UIAttachmentBehavior *attach1 = [[UIAttachmentBehavior alloc] initWithItem:self.box1
                                                           offsetFromCenter:UIOffsetMake(25, 25)
                                                           attachedToAnchor:self.box1.center];
  [self.dynamicAnimator addBehavior:attach1];

  UIAttachmentBehavior *attach2 = [[UIAttachmentBehavior alloc] initWithItem:self.box2
                                                             attachedToItem:self.box1];
  [self.dynamicAnimator addBehavior:attach2];

  UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self.box2]
                                                          mode:UIPushBehaviorModeInstantaneous];
  push.pushDirection = CGVectorMake(0, 2);
  [self.dynamicAnimator addBehavior:push];
}

- (IBAction)push {
  UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self.box1]
                                                          mode:UIPushBehaviorModeContinuous];
   
  //推力向量
  //i UIKit 牛顿是1 UIKIT 千克加速到 100p/s^2时 所需要的力。
  push.pushDirection = CGVectorMake(0, 1);
  
  //还可以通过 角度 和 弧度来
  [self.dynamicAnimator addBehavior:push];
}

- (IBAction)gravity {
  UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.box1,
                                                                          self.box2]];

   // 加速到 1000p/s^2时 所需要的力。
   // 重力学，UIKIT 没有地面，如果没有被挡住，一直会下路。
  gravity.action = ^{
    NSLog(@"%@", NSStringFromCGPoint(self.box1.center));
  };
  [self.dynamicAnimator addBehavior:gravity];
}

- (IBAction)collision {
  UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.box1,
                                                                                self.box2]];
  [self.dynamicAnimator addBehavior:collision];

  UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self.box1]
                                                          mode:UIPushBehaviorModeInstantaneous];
  push.pushDirection = CGVectorMake(3, 0);
  [self addTemporaryBehavior:push];
    
    //当动力项 互相碰撞时候，集体行为取决于相对的动量和弹性
    
    //边界是一条质量无穷大的轨道，因此边界被碰撞时候，不会移动
}

- (void)addTemporaryBehavior:(UIDynamicBehavior *)behavior {
  [self.dynamicAnimator addBehavior:behavior];
  [self.dynamicAnimator performSelector:@selector(removeBehavior:)
                             withObject:behavior
                             afterDelay:1];
}

//生成随机的点
- (CGPoint)randomPoint {
  CGSize size = self.view.bounds.size;
  return CGPointMake(arc4random_uniform(size.width),
                     arc4random_uniform(size.height));
}

@end
