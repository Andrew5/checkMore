//
//  UILabel+ReadMore.h
//  TestDemo
//
//  Created by jabraknight on 2021/1/6.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
NS_ASSUME_NONNULL_BEGIN
///声明展开回调事件
typedef void(^LabelAction )(CGFloat contextHeight);
@interface UILabel (ReadMore)
@property (nonatomic, strong) NSString *dataStr;

- (void)returnText:(LabelAction _Nonnull)tapAction;

-(void)setReadMoreLabelContentMode;

@end

NS_ASSUME_NONNULL_END
