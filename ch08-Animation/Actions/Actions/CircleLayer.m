//
//  CircleLayer.m
//  Actions
//
//  Copyright (c) 2012 Rob Napier
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

#import "CircleLayer.h"

@implementation CircleLayer
//1：通过@synthesize 指令告诉编译器在编译期间产生getter/setter方法。
//2：通过@dynamic指令，自己实现方法。
@dynamic radius;

- (id)init {
  self = [super init];
  if (self) {
    [self setNeedsDisplay];
  }

  return self;
}

- (void)drawInContext:(CGContextRef)ctx {
  CGContextSetFillColorWithColor(ctx,
                                 [[UIColor redColor] CGColor]);
  CGFloat radius = self.radius;
  CGRect rect;
  rect.size = CGSizeMake(radius, radius);
  rect.origin.x = (self.bounds.size.width - radius) / 2;
  rect.origin.y = (self.bounds.size.height - radius) / 2;
  CGContextAddEllipseInRect(ctx, rect);
  CGContextFillPath(ctx);
}


// 在init方法里调用 setNeedsDisplay 这样的图层drawincontext会在第一次减价图层到图层时候，被调用
// 覆盖needsdisplayForKey 方法。这样五楼合适修改白净都会自动重绘
+ (BOOL)needsDisplayForKey:(NSString *)key {
  if ([key isEqualToString:@"radius"]) {
    return YES;
  }
  return [super needsDisplayForKey:key];
}


- (id < CAAction >)actionForKey:(NSString *)key {
  if ([self presentationLayer] != nil) {
    //更改半径会导致原型渐渐消失 并且出现新圆形
    if ([key isEqualToString:@"radius"]) {
      CABasicAnimation *anim = [CABasicAnimation
                                animationWithKeyPath:@"radius"];
     //返回一个当前图层的半径的起始值。。动画变化 动画效果会平滑过渡
      anim.fromValue = [[self presentationLayer]
                        valueForKey:@"radius"];
      return anim;
    }
  }

  return [super actionForKey:key];
}

@end
