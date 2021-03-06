//
//  DelegateView.m
//  Layers
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

#import "DelegateView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DelegateView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self.layer setNeedsDisplay];
    [self.layer setContentsScale:[[UIScreen mainScreen] scale]];
  }
  return self;
}

//Having UIView implement displayLayer: seldom makes sense in my opinion.
//可以尽可能 用UIKit


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
 // CGContextSaveGState 记录上下文的状态，下面是进行上下文切换
//  Because Core Animation does not set a UIKit graphics context, you need to call UIGraphicsPushContext before calling UIKit methods, and UIGraphicsPopContext before returning.
  UIGraphicsPushContext(ctx);  //并不是保存上下文当前状态，而是完全切换上下文，加入在当前上下文绘制了什么东西，想要在位图上下文绘制不同的东西
  [[UIColor whiteColor] set];
  UIRectFill(layer.bounds);

  UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
  UIColor *color = [UIColor blackColor];

  NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
  [style setAlignment:NSTextAlignmentCenter];
  
  NSDictionary *attribs = @{NSFontAttributeName: font,
                            NSForegroundColorAttributeName: color,
                            NSParagraphStyleAttributeName: style};

  NSAttributedString *
  text = [[NSAttributedString alloc] initWithString:@"Pushing The Limits"
                                         attributes:attribs];

  [text drawInRect:CGRectInset([layer bounds], 10, 100)];
  UIGraphicsPopContext();
}

@end
