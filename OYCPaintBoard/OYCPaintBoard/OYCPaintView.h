//
//  OYCPaintView.h
//  OYCPaintBoard
//
//  Created by cao on 16/11/28.
//  Copyright © 2016年 daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OYCPaintView : UIView

@property(nonatomic,assign)CGFloat lineWidth;

@property(nonatomic,strong)UIColor *lineColor;

- (void)clear;

- (void)undo;

- (void)erase;

- (void)photo:(UIImage *)image;

- (void)save;

@end
