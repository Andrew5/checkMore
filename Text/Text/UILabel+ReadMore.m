//
//  UILabel+ReadMore.m
//  TestDemo
//
//  Created by jabraknight on 2021/1/6.
//  Copyright © 2021 jabraknight. All rights reserved.
//

#import "UILabel+ReadMore.h"
#import <CoreText/CoreText.h>

static char *nameKey = "nameKey";

static char *buttonClickKey;

@implementation UILabel (ReadMore)
- (void)setDataStr:(NSString *)dataStr{
    objc_setAssociatedObject(self, nameKey, dataStr, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)dataStr{
    return objc_getAssociatedObject(self, nameKey);
}
- (void)setReadMoreLabelContentMode {
    NSArray *contents = [self getLinesArrayOfLabelRows];
    if (contents.count <= 1) {
        self.userInteractionEnabled = NO; // 如果一行就不显示查看更多，同时取消手势响应
        return;
    }
    self.userInteractionEnabled = YES;
    
    NSUInteger cutLength = 20; // 截取的长度
    
    NSMutableString *contentText = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < self.numberOfLines; i++) {
        if (i == self.numberOfLines - 1) { // 最后一行 进行处理加上.....
            
            NSString *lastLineText = [NSString stringWithFormat:@"%@",contents[i]];
            NSUInteger lineLength = lastLineText.length;
            if (lineLength > cutLength) {
                lastLineText = [lastLineText substringToIndex:(lastLineText.length - cutLength)];
            }
            [contentText appendString:[NSString stringWithFormat:@"%@  .....",lastLineText]];
            
        } else {
            [contentText appendString:contents[i]];
        }
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    NSDictionary *dictionary = @{
                                 NSForegroundColorAttributeName : self.textColor,
                                 NSFontAttributeName : self.font,
                                 NSParagraphStyleAttributeName : style
                                 };
    
    NSMutableAttributedString *mutableAttribText = [[NSMutableAttributedString alloc] initWithString:[contentText stringByAppendingString:@"更多"] attributes:dictionary];
    [mutableAttribText addAttributes:@{
                                       NSFontAttributeName : [UIFont boldSystemFontOfSize:14.0f],
                                       NSForegroundColorAttributeName : [UIColor orangeColor]
                                       } range:NSMakeRange(mutableAttribText.length-8, 8)];//默认收起，8代表收起状态最后9个字符"......更多"
    self.attributedText = mutableAttribText;
    
    
}

/// 获取 Label 每行内容 得到一个数组
- (NSArray *)getLinesArrayOfLabelRows {
    CGFloat labelWidth = self.frame.size.width;
    
    NSString *text = [self text];
    UIFont *font = [self font];
    if (text == nil) {
        return nil;
    }
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:(NSString *)kCTFontAttributeName
                   value:(__bridge  id)myFont
                   range:NSMakeRange(0, attStr.length)];
    CFRelease(myFont);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,labelWidth,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr,
                                       lineRange,
                                       kCTKernAttributeName,
                                       (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr,
                                       lineRange,
                                       kCTKernAttributeName,
                                       (CFTypeRef)([NSNumber numberWithInt:0.0]));
        [linesArray addObject:lineString];
    }
    CGPathRelease(path);
    CFRelease(frame);
    CFRelease(frameSetter);
    return (NSArray *)linesArray;
}
///TODO:点击回调事件
//- (void)setTapAction:(LabelAction)tapAction{
//    objc_setAssociatedObject(self, @selector(tapAction), tapAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//- (LabelAction)tapAction{
//    return objc_getAssociatedObject(self, _cmd);
//}
- (void)labelTouchUpInside{
    LabelAction tapAction = objc_getAssociatedObject(self, &buttonClickKey);
    int font = 14;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:font]};
    CGSize contenSize = [self.dataStr boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil].size;
    CGFloat height = contenSize.height + font / 2;
    self.numberOfLines = 0;
    self.text = self.dataStr;
    [self sizeToFit];
    if (tapAction) {
        tapAction(height);
    }
}
- (void)returnText:(LabelAction)tapAction{
    objc_setAssociatedObject(self, &buttonClickKey, tapAction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self labelTouchUpInside];
}
@end
