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
#import "CollectionViewController.h"
#import "JuliaCell.h"
#include <sys/sysctl.h>

@interface CollectionViewController ()
@property (nonatomic, readwrite, strong) NSOperationQueue *queue;
@property (nonatomic, readwrite, strong) NSArray *scales;
@end

@implementation CollectionViewController

unsigned int countOfCores() {
  unsigned int ncpu;
  size_t len = sizeof(ncpu);
  sysctlbyname("hw.ncpu", &ncpu, &len, NULL, 0);
  
  return ncpu;
}

- (void)useAllScales {
  CGFloat maxScale = [[UIScreen mainScreen] scale];
  NSUInteger kIterations = 6;
  CGFloat minScale = maxScale/pow(2, kIterations);
  
  NSMutableArray *scales = [NSMutableArray new];
  for (CGFloat scale = minScale; scale <= maxScale; scale *= 2) {
    [scales addObject:@(scale)];
  }
  self.scales = scales;
    
//    "0.03125",
//    "0.0625",
//    "0.125",
//    "0.25",
//    "0.5",
//    1,
//    2
    
  NSLog(@"[useAllScales] scales=%@" , self.scales) ;
}

//选择最小一个
- (void)useMinimumScales {
  self.scales = [self.scales subarrayWithRange:NSMakeRange(0, 1)];
     NSLog(@"[useMinimumScales] scales=%@" , self.scales) ;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.queue = [[NSOperationQueue alloc] init];
  [self useAllScales];

  // No longer needed in iOS 7
  self.queue.maxConcurrentOperationCount = countOfCores();
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 1000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  JuliaCell *
  cell = [self.collectionView
          dequeueReusableCellWithReuseIdentifier:@"Julia"
          forIndexPath:indexPath];
  [cell configureWithSeed:indexPath.row queue:self.queue scales:self.scales];
  return cell;
}

// 滚动加速
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDragging") ;
  [self.queue cancelAllOperations];
  [self useMinimumScales];
}

//开始减速了
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
     NSLog(@"scrollViewWillBeginDecelerating") ;
  [self useAllScales];
}

@end
