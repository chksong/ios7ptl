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
#import "DragViewController.h"
#import "DragLayout.h"

@implementation DragViewController

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
}

- (IBAction)handleLongPress:(UIGestureRecognizer *)g {

  // 使用UIKit 动力学的一个尤其的用途是影响 UIcollectionVIew 布局，可以使用这些布局 创建各种令人兴奋的 引人入胜的交互。
  // as a quick reminder ,UICollectionView relies UICollectionViewLayout to generate a UICollectonViewLayoutAttributes
  // object for each item,    this layout attributes object defines the center and transform among other things.
  // the matches exactly with <UIDynamicItem> which also defines a center and transform
  // this means that a dynamic animator can modify layout attributes over time according to behaviors
  DragLayout *dragLayout = (DragLayout *)self.collectionViewLayout;
    
  CGPoint location = [g locationInView:self.collectionView];

  // Find the indexPath and cell being dragged
  // 找到被拖放的 indexPath 和 cell
  NSIndexPath *indexPath = [self.collectionView
                            indexPathForItemAtPoint:location];
  UICollectionViewCell *cell = [self.collectionView
                                cellForItemAtIndexPath:indexPath];
    

  UIGestureRecognizerState state = g.state;
  if (state == UIGestureRecognizerStateBegan) {
    // Change the color and start dragging
    [UIView animateWithDuration:0.25
                     animations:^{
                       cell.backgroundColor = [UIColor redColor];
                     }];
    [dragLayout startDraggingIndexPath:indexPath fromPoint:location];
  }

  else if (state == UIGestureRecognizerStateEnded ||
           state == UIGestureRecognizerStateCancelled) {
    // Change the color and stop dragging
    [UIView animateWithDuration:0.25
                     animations:^{
                       cell.backgroundColor = [UIColor lightGrayColor];
                     }];
    [dragLayout stopDragging];
  }

  else {
    // Drag
    [dragLayout updateDragLocation:location];
  }
}

@end
