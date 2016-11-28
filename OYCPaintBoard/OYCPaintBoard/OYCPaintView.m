//
//  OYCPaintView.m
//  OYCPaintBoard
//
//  Created by cao on 16/11/28.
//  Copyright © 2016年 daniel. All rights reserved.
//

#import "OYCPaintView.h"

@interface OYCPaintView ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong)UIBezierPath *paintPath;

@property (nonatomic,strong)NSMutableArray *pathArray;

@property (nonatomic,assign)CGPoint curP;

@property (nonatomic,strong)NSMutableArray *lineColors;

@property (nonatomic,weak) UIImageView *imageView;

@property (nonatomic,strong)UIImage *clipImage;
@end

@implementation OYCPaintView

static int flag = 0; //0没有弹出图片之前，1弹出图片没有长按的时候

- (UIImageView *)imageView{
    if (_imageView == nil) {
        UIImageView *imageV = [[UIImageView alloc]initWithFrame:self.bounds];
        imageV.userInteractionEnabled = YES;
        _imageView = imageV;
        //给imageView添加手势
        [self setupImageGestureRecognizer];
        [self addSubview:imageV];
    }
    return _imageView;
}

//给imageView添加手势
- (void)setupImageGestureRecognizer{
    
    //滑动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(imagePan:)];
    pan.delegate = self;
    [_imageView addGestureRecognizer:pan];
    //旋转手势
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(imageRotation:)];
    rotation.delegate = self;
    [_imageView addGestureRecognizer:rotation];
    //缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(imagePinch:)];
    pinch.delegate = self;
    [_imageView addGestureRecognizer:pinch];
    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(imageLongPress:)];
    [_imageView addGestureRecognizer:longPress];
    
}


- (NSMutableArray *)pathArray{
    if (_pathArray == nil) {
        _pathArray = [NSMutableArray array];
    }
    return _pathArray;
}

- (NSMutableArray *)lineColors{
    if (_lineColors == nil) {
        _lineColors = [NSMutableArray array];
    }
    return _lineColors;
}

- (void)awakeFromNib{
    
    //默认线宽度，线的颜色
    self.lineWidth = 1;
    self.lineColor = [UIColor blackColor];
    
    //添加滑动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    //超出界面的裁剪掉
    self.clipsToBounds = YES;
}

- (void)pan:(UIPanGestureRecognizer *)pan{
    
    if (flag == 0) {
        
        if (pan.state == UIGestureRecognizerStateBegan) {
            
            CGPoint startP = [pan locationInView:self];
            self.paintPath = [UIBezierPath bezierPath];
            self.paintPath.lineWidth = self.lineWidth;
            self.paintPath.lineCapStyle = kCGLineCapRound;
            self.paintPath.lineJoinStyle = kCGLineJoinRound;
            [self.paintPath moveToPoint:startP];
            
        }else if(pan.state == UIGestureRecognizerStateChanged){
            
            _curP = [pan locationInView:self];
            [self.paintPath addLineToPoint:_curP];
            [self setNeedsDisplay];
            
        }else if (pan.state == UIGestureRecognizerStateEnded){
            
            [self.pathArray addObject:self.paintPath];
            [self.lineColors addObject:self.lineColor];
        }
    }
}

- (void)drawRect:(CGRect)rect{
        
    for (NSInteger i = 0 ; i < self.pathArray.count; i++) {
        if ([self.pathArray[i] isKindOfClass:[UIImage class]]) {
            UIImage *image = self.pathArray[i];
            [image drawInRect:rect];
            [self.imageView removeFromSuperview];
            self.imageView = nil;
            flag = 0;
        }else{
            UIBezierPath *path = self.pathArray[i];
            UIColor *color = self.lineColors[i];
            [color set];
            [path stroke];
        }
        
    }
    [self.lineColor set];
    [self.paintPath stroke];
    
}

- (void)clear{
    [self.pathArray removeAllObjects];
    [self.lineColors removeAllObjects];
    self.pathArray = nil;
    self.paintPath = nil;
    [self setNeedsDisplay];
}

-(void)undo{
    [self.pathArray removeLastObject];
    [self.lineColors removeLastObject];
    self.paintPath = nil;
    [self setNeedsDisplay];
}

-(void)erase{
    self.lineColor = [UIColor whiteColor];
}

-(void)save{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:ctx];
    UIImage *savedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
//    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    
}

- (void)photo:(UIImage *)image{
    flag = 1;
    self.imageView.image = image;
}

#pragma mark 照片的各种手势操作
- (void)imagePan:(UIPanGestureRecognizer *)pan{
    CGPoint offestP = [pan translationInView:self.imageView];
    self.imageView.transform = CGAffineTransformTranslate(self.imageView.transform, offestP.x, offestP.y);
    [pan setTranslation:CGPointZero inView:self.imageView];
}

- (void)imageRotation:(UIRotationGestureRecognizer *)rotation{
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, rotation.rotation);
    rotation.rotation = 0;
}

- (void)imagePinch:(UIPinchGestureRecognizer *)pinch{
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, pinch.scale, pinch.scale);
    pinch.scale = 1;
}

- (void)imageLongPress:(UILongPressGestureRecognizer *)longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        //实现长按时一闪的动画效果
        [UIView animateWithDuration:0.25 animations:^{
            
            self.imageView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.25 animations:^{
               
                self.imageView.alpha = 1;
                
            } completion:^(BOOL finished) {
                
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
                
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                
                [self.layer renderInContext:ctx];
                
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
                
                [self.pathArray addObject:image];
                [self.lineColors addObject:[UIColor whiteColor]];
                
                [self setNeedsDisplay];
                
            }];
        }];
    }
}

#pragma  mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


@end
