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
#import "JuliaCell.h"
#import "JuliaOperation.h"

@interface JuliaCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, readwrite, strong) NSMutableArray *operations;
@end

@implementation JuliaCell

//重用单元格,重用时，要取消当前的操作，当前的所有的操作
- (void)prepareForReuse {
  [self.operations makeObjectsPerformSelector:@selector(cancel)];
  [self.operations removeAllObjects];
  self.imageView.image = nil;
  self.label.text = @"";
}

- (void)awakeFromNib {
  self.operations = [NSMutableArray new];
}


- (JuliaOperation *)operationForScale:(CGFloat)scale
                                 seed:(NSUInteger)seed {
  JuliaOperation *op = [[JuliaOperation alloc] init];
  op.contentScaleFactor = scale;
  
  CGRect bounds = self.bounds;
  op.width = (unsigned)(CGRectGetWidth(bounds) * scale);
  op.height = (unsigned)(CGRectGetHeight(bounds) * scale);
  
  srandom(seed);
  
  op.c = (long double)random()/LONG_MAX + I*(long double)random()/LONG_MAX;  
  op.blowup = random();
  op.rScale = random() % 20;  // Biased, but simple is more important
  op.gScale = random() % 20;
  op.bScale = random() % 20;
    
  __weak JuliaOperation *weakOp = op;
  op.completionBlock = ^{
    if (! weakOp.isCancelled) {
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        JuliaOperation *strongOp = weakOp;
        if (strongOp && [self.operations containsObject:strongOp]) {
          self.imageView.image = strongOp.image;
          self.label.text = strongOp.description;
          [self.operations removeObject:strongOp];
        }
      }];
    }
  };
  
  //先生成小的图像
  if (scale < 0.5) {
    op.queuePriority = NSOperationQueuePriorityVeryHigh;
  }
  else if (scale <= 1) {
    op.queuePriority = NSOperationQueuePriorityHigh;
  }
  else {
    op.queuePriority = NSOperationQueuePriorityNormal;
  }
  
  return op;
}

- (void)configureWithSeed:(NSUInteger)seed
                    queue:(NSOperationQueue *)queue
                   scales:(NSArray *)scales {
    
  CGFloat maxScale = [[UIScreen mainScreen] scale];
  self.contentScaleFactor = maxScale;

  NSUInteger kIterations = 6;
  CGFloat minScale = maxScale/pow(2, kIterations);

    //In [3]: 2/(64.0)
   // Out[3]: 0.03125
    
  JuliaOperation *prevOp = nil;
  for (CGFloat scale = minScale; scale <= maxScale; scale *= 2) {
    JuliaOperation *op = [self operationForScale:scale seed:seed];
    if (prevOp) {
      [op addDependency:prevOp];  //依赖操作，确保高分辨图片不会再低分辨率图片之前调度。
    }
      
    [self.operations addObject:op];  //array
     
    // 加入队列
    [queue addOperation:op];
    prevOp = op;
  }
}

@end
