//
//  ViewController.m
//  OYCPaintBoard
//
//  Created by cao on 16/11/28.
//  Copyright © 2016年 daniel. All rights reserved.
//

#import "ViewController.h"
#import "OYCPaintView.h"

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet OYCPaintView *paintView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//清屏
- (IBAction)clear:(UIBarButtonItem *)sender {
    [_paintView clear];
}
//撤销
- (IBAction)undo:(UIBarButtonItem *)sender {
    [_paintView undo];
}
//擦除
- (IBAction)erase:(UIBarButtonItem *)sender {
    [_paintView erase];
}
//图片
- (IBAction)photo:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
//保存
- (IBAction)save:(UIBarButtonItem *)sender {
    [_paintView save];
}
//改变线的粗细
- (IBAction)lineWidthChange:(UISlider *)sender {
    _paintView.lineWidth = sender.value;
}

//改变线的颜色
- (IBAction)colorChange:(UIButton *)sender {
    _paintView.lineColor = sender.backgroundColor;
}

#pragma mark - <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [_paintView photo:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
