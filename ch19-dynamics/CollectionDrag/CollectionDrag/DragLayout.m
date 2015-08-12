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
#import "DragLayout.h"

@interface DragLayout ()
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) UIAttachmentBehavior *behavior;
@end

@implementation DragLayout

- (void)startDraggingIndexPath:(NSIndexPath *)indexPath
                     fromPoint:(CGPoint)p {
  self.indexPath = indexPath;
  self.animator = [[UIDynamicAnimator alloc]
                   initWithCollectionViewLayout:self];

  UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:self.indexPath];
    
  // Raise the item above its peers
  attributes.zIndex += 13;

  self.behavior = [[UIAttachmentBehavior alloc] initWithItem:attributes
                                            attachedToAnchor:p];
  self.behavior.length = 0;
  self.behavior.frequency = 5;
  [self.animator addBehavior:self.behavior];

  // Add a little resistance to keep things stable
 // 他对 动力项 赋值 物理属性， 例如可以使用动力项行为给一个动力箱 设置密度和弹性
    
  UIDynamicItemBehavior *dynamicItem = [[UIDynamicItemBehavior alloc]
                                        initWithItems:@[attributes]];
  dynamicItem.resistance = 3;
  [self.animator addBehavior:dynamicItem];

  [self updateDragLocation:p];
}

- (void)updateDragLocation:(CGPoint)p {
  self.behavior.anchorPoint = p;
}

- (void)stopDragging {
  // Move back to the original location (super)
  UICollectionViewLayoutAttributes *
  attributes = [super layoutAttributesForItemAtIndexPath:self.indexPath];
  [self updateDragLocation:attributes.center];
  self.indexPath = nil;
  self.behavior = nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  // Find all the attributes, and replace the one for our indexPath
  NSArray *existingAttributes = [super
                                 layoutAttributesForElementsInRect:rect];
  NSMutableArray *allAttributes = [NSMutableArray new];
  for (UICollectionViewLayoutAttributes *a in existingAttributes) {
    if (![a.indexPath isEqual:self.indexPath]) {
      [allAttributes addObject:a];
    }
  }

  [allAttributes addObjectsFromArray:[self.animator itemsInRect:rect]];
  return allAttributes;
}

@end
