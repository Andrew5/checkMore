//
//  ViewController.m
//  Text
//
//  Created by jabraknight on 2021/1/6.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import "ViewController.h"
#import "UILabel+ReadMore.h"

@interface ViewController ()
@property (nonatomic,strong) UILabel  *label_label;
@property (nonatomic,  copy) NSString *context;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = @"alloc init 这个方法，在 LLVM 的 CGObjC.cpp 中有一个 tryGenerateSpecializedMessageSend，给 ObjCRuntime 提供了一些更快的代码执行入口点，相比于普通常规的 msgsend 的方法选择器来比较的，这个快速入口保证了一样的执行效果。如果这个入口点的内部只是一个消息发送的原生实现，使用它是一个这种方案，牺牲了几个循环的开销节省少量代码。通过这个机制， alloc init 之后调用根本没有调用 NSObject 的 alloc 方法";
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 100.0f, [UIScreen mainScreen].bounds.size.width - 20.0f, 50.0f)];
    label.font = [UIFont systemFontOfSize:14.0f];
    label.numberOfLines = 2;
    self.label_label = label;
    [self.view addSubview:self.label_label];
    label.layer.borderColor = [UIColor greenColor].CGColor;
    label.layer.borderWidth = 1.0;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside)];
    [label addGestureRecognizer:labelTapGestureRecognizer];
    label.text = self.context;
    self.label_label.dataStr = self.context;
    [label sizeToFit];
    [label setReadMoreLabelContentMode];
}

- (void)labelTouchUpInside{
    [self.label_label returnText:^(CGFloat contextHeight) {
        NSLog(@"--%f",contextHeight);
    }];
}
@end
