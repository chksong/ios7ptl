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
#import "JuliaOperation.h"

@interface JuliaOperation ()
@property (nonatomic, readwrite, strong) UIImage *image;
@end

@implementation JuliaOperation

complex long double f(const complex long double z,
                      const complex long double c) {
  return z*z + c;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"(%.3f, %.3f)@%.2f",
          creal(self.c), cimag(self.c), self.contentScaleFactor];
}

- (void)main {
  NSUInteger height = self.height;
  NSUInteger width = self.width;
  
 // 配置bits[] 保存位图数据
  NSUInteger components = 4;
  NSMutableData *
  data = [NSMutableData dataWithLength:
          width * height * components * sizeof(uint8_t)];
  uint8_t *bits = [data mutableBytes];
  
  complex long double c = self.c;
  long double blowup = self.blowup;
  const double kScale = 1.5;
  
  for (NSUInteger y = 0; y < height; ++y) {
    for (NSUInteger x = 0; x < width; ++x) {
      if (self.isCancelled) {
        return;
      }
        
      // 计算茱莉亚的值，并且更新bits
      // 每个像素做多可能
      NSUInteger iteration = 0;
      complex long double z = (2.0 * kScale * x)/width - kScale
        + I*((2.0 * kScale * y)/width - kScale);
      while (cabsl(z) < blowup && iteration < 256) {
        z = f(z, c);
        ++iteration;
      }
      
      NSUInteger offset = (y*width*components) + (x*components);
      bits[offset+0] = (iteration * self.rScale);
      bits[offset+1] = (iteration * self.bScale);
      bits[offset+2] = (iteration * self.gScale);
    }
  }
  
  //创建位图并保存在 self,imgage
  CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(bits,
                                               width,
                                               height,
                                               8,
                                               width * components,
                                               colorspace,
                                               kCGImageAlphaNoneSkipLast);
  CGColorSpaceRelease(colorspace);
  
  CGImageRef cgImage = CGBitmapContextCreateImage(context);
  self.image = [UIImage imageWithCGImage:cgImage
                                   scale:self.contentScaleFactor
                             orientation:UIImageOrientationUp];
  CGImageRelease(cgImage);
  CGContextRelease(context);
}

//下面的这个操作的关键特性，
//1， 所有的必需的数据都会在 开始之前传递给操作，操作运行过程中，不需要和别的对象交互，获益就不用枷锁。
//2， 操作完成之后，结果报错在本地的ivar中，，， 还是为了避免枷锁，所以用委托方法来更新操作外边的某些数据，但是你看到 用完成块更简单
//3  操作定期检查iscancelled属性， 以便到收到退出请求时候，能够推退出。


@end
