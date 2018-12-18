//
//  UITextView+JS.m
//  Judou
//
//  Created by 4work on 2018/12/14.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

#import "UITextView+JS.h"
#import <objc/runtime.h>

// 占位文字
static const void *JSPlaceholderViewKey = &JSPlaceholderViewKey;
// 占位文字颜色
static const void *JSPlaceholderColorKey = &JSPlaceholderColorKey;
// 最大高度
static const void *JSTextViewMaxHeightKey = &JSTextViewMaxHeightKey;
// 最小高度
static const void *JSTextViewMinHeightKey = &JSTextViewMinHeightKey;
// 高度变化的block
static const void *JSTextViewHeightDidChangedBlockKey = &JSTextViewHeightDidChangedBlockKey;
// 存储添加的图片
static const void *JSTextViewImageArrayKey = &JSTextViewImageArrayKey;
// 存储最后一次改变高度后的值
static const void *JSTextViewLastHeightKey = &JSTextViewLastHeightKey;

@interface UITextView ()

// 存储添加的图片
@property (nonatomic, strong) NSMutableArray *js_imageArray;
// 存储最后一次改变高度后的值
@property (nonatomic, assign) CGFloat lastHeight;

@end

@implementation UITextView (JS)

#pragma mark - Swizzle Dealloc
+ (void)load {
    // 交换dealoc
    Method dealoc = class_getInstanceMethod(self.class, NSSelectorFromString(@"dealloc"));
    Method myDealloc = class_getInstanceMethod(self.class, @selector(myDealloc));
    method_exchangeImplementations(dealoc, myDealloc);
}

- (void)myDealloc {
    // 移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    UITextView *placeholderView = objc_getAssociatedObject(self, JSPlaceholderViewKey);
    
    // 如果有值才去调用，这步很重要
    if (placeholderView) {
        NSArray *propertys = @[@"frame", @"bounds", @"font", @"text", @"textAlignment", @"textContainerInset"];
        for (NSString *property in propertys) {
            @try {
                [self removeObserver:self forKeyPath:property];
            } @catch (NSException *exception) {}
        }
    }
    
    [self myDealloc];
}

#pragma mark - set && get
- (UITextView *)js_placeholderView {
    // 为了让占位文字和textView的实际文字位置能够完全一致，这里用UITextView
    UITextView *placeholderView = objc_getAssociatedObject(self, JSPlaceholderViewKey);
    
    if (!placeholderView) {
        
        // 初始化数组
        self.js_imageArray = [NSMutableArray array];
        
        placeholderView = [[UITextView alloc] init];
        // 动态添加属性的本质是: 让对象的某个属性与值产生关联
        objc_setAssociatedObject(self, JSPlaceholderViewKey, placeholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        placeholderView = placeholderView;
        
        // 设置基本属性
        placeholderView.scrollEnabled = placeholderView.userInteractionEnabled = NO;
        
        placeholderView.textColor = [UIColor lightGrayColor];
        placeholderView.backgroundColor = [UIColor clearColor];
        [self refreshPlaceholderView];
        [self addSubview:placeholderView];
        
        // 监听文字改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextChange) name:UITextViewTextDidChangeNotification object:self];
        
        // 这些属性改变时，都要作出一定的改变，尽管已经监听了TextDidChange的通知，也要监听text属性，因为通知监听不到setText：
        NSArray *propertys = @[@"frame", @"bounds", @"font", @"text", @"textAlignment", @"textContainerInset"];
        
        // 监听属性
        for (NSString *property in propertys) {
            [self addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew context:nil];
        }
        
    }
    return placeholderView;
}

- (void)setJs_placeholder:(NSString *)placeholder {
    // 为placeholder赋值
    [self js_placeholderView].text = placeholder;
}

- (NSString *)js_placeholder {
    // 如果有placeholder值才去调用，这步很重要
    if (self.placeholderExist) {
        return [self js_placeholderView].text;
    }
    
    return nil;
}

- (void)setJs_placeholderColor:(UIColor *)js_placeholderColor {
    // 如果有placeholder值才去调用，这步很重要
    if (!self.placeholderExist) {
        NSLog(@"请先设置placeholder值！");
    } else {
        self.js_placeholderView.textColor = js_placeholderColor;
        
        // 动态添加属性的本质是: 让对象的某个属性与值产生关联
        objc_setAssociatedObject(self, JSPlaceholderColorKey, js_placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (UIColor *)js_placeholderColor {
    return objc_getAssociatedObject(self, JSPlaceholderColorKey);
}

- (void)setJs_maxHeight:(CGFloat)js_maxHeight {
    CGFloat max = js_maxHeight;
    
    // 如果传入的最大高度小于textView本身的高度，则让最大高度等于本身高度
    if (js_maxHeight < self.frame.size.height) {
        max = self.frame.size.height;
    }
    
    objc_setAssociatedObject(self, JSTextViewMaxHeightKey, [NSString stringWithFormat:@"%lf", max], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)js_maxHeight {
    return [objc_getAssociatedObject(self, JSTextViewMaxHeightKey) doubleValue];
}

- (void)setJs_minHeight:(CGFloat)js_minHeight {
    objc_setAssociatedObject(self, JSTextViewMinHeightKey, [NSString stringWithFormat:@"%lf", js_minHeight], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)js_minHeight {
    return [objc_getAssociatedObject(self, JSTextViewMinHeightKey) doubleValue];
}

- (void)setJs_textViewHeightDidChanged:(textViewHeightDidChangedBlock)js_textViewHeightDidChanged {
    objc_setAssociatedObject(self, JSTextViewHeightDidChangedBlockKey, js_textViewHeightDidChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (textViewHeightDidChangedBlock)js_textViewHeightDidChanged {
    void(^textViewHeightDidChanged)(CGFloat currentHeight) = objc_getAssociatedObject(self, JSTextViewHeightDidChangedBlockKey);
    return textViewHeightDidChanged;
}

- (NSArray *)js_getImages {
    return self.js_imageArray;
}

- (void)setLastHeight:(CGFloat)lastHeight {
    objc_setAssociatedObject(self, JSTextViewLastHeightKey, [NSString stringWithFormat:@"%lf", lastHeight], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)lastHeight {
    return [objc_getAssociatedObject(self, JSTextViewLastHeightKey) doubleValue];
}

- (void)setJs_imageArray:(NSMutableArray *)js_imageArray {
    objc_setAssociatedObject(self, JSTextViewImageArrayKey, js_imageArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)js_imageArray {
    return objc_getAssociatedObject(self, JSTextViewImageArrayKey);
}

- (void)js_autoHeightWithMaxHeight:(CGFloat)maxHeight {
    [self js_autoHeightWithMaxHeight:maxHeight textViewHeightDidChanged:nil];
}
// 是否启用自动高度，默认为NO
static bool autoHeight = NO;
- (void)js_autoHeightWithMaxHeight:(CGFloat)maxHeight textViewHeightDidChanged:(textViewHeightDidChangedBlock)textViewHeightDidChanged {
    autoHeight = YES;
    [self js_placeholderView];
    self.js_maxHeight = maxHeight;
    if (textViewHeightDidChanged) self.js_textViewHeightDidChanged = textViewHeightDidChanged;
}

#pragma mark - addImage
/* 添加一张图片 */
- (void)js_addImage:(UIImage *)image {
    [self js_addImage:image size:CGSizeZero];
}

/* 添加一张图片 image:要添加的图片 size:图片大小 */
- (void)js_addImage:(UIImage *)image size:(CGSize)size {
    [self js_insertImage:image size:size index:self.attributedText.length > 0 ? self.attributedText.length : 0];
}

/* 插入一张图片 image:要添加的图片 size:图片大小 index:插入的位置 */
- (void)js_insertImage:(UIImage *)image size:(CGSize)size index:(NSInteger)index {
    [self js_addImage:image size:size index:index multiple:-1];
}

/* 添加一张图片 image:要添加的图片 multiple:放大／缩小的倍数 */
- (void)js_addImage:(UIImage *)image multiple:(CGFloat)multiple {
    [self js_addImage:image size:CGSizeZero index:self.attributedText.length > 0 ? self.attributedText.length : 0 multiple:multiple];
}

/* 插入一张图片 image:要添加的图片 multiple:放大／缩小的倍数 index:插入的位置 */
- (void)js_insertImage:(UIImage *)image multiple:(CGFloat)multiple index:(NSInteger)index {
    [self js_addImage:image size:CGSizeZero index:index multiple:multiple];
}

/* 插入一张图片 image:要添加的图片 size:图片大小 index:插入的位置 multiple:放大／缩小的倍数 */
- (void)js_addImage:(UIImage *)image size:(CGSize)size index:(NSInteger)index multiple:(CGFloat)multiple {
    if (image) [self.js_imageArray addObject:image];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = image;
    CGRect bounds = textAttachment.bounds;
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        bounds.size = size;
        textAttachment.bounds = bounds;
    } else if (multiple <= 0) {
        CGFloat oldWidth = textAttachment.image.size.width;
        CGFloat scaleFactor = oldWidth / (self.frame.size.width - 10);
        textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
    } else {
        bounds.size = image.size;
        textAttachment.bounds = bounds;
    }
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString replaceCharactersInRange:NSMakeRange(index, 0) withAttributedString:attrStringWithImage];
    self.attributedText = attributedString;
    [self textViewTextChange];
    [self refreshPlaceholderView];
}


#pragma mark - KVO监听属性改变
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self refreshPlaceholderView];
    if ([keyPath isEqualToString:@"text"]) [self textViewTextChange];
}

// 刷新PlaceholderView
- (void)refreshPlaceholderView {
    
    UITextView *placeholderView = objc_getAssociatedObject(self, JSPlaceholderViewKey);
    
    // 如果有值才去调用，这步很重要
    if (placeholderView) {
        self.js_placeholderView.frame = self.bounds;
        if (self.js_maxHeight < self.bounds.size.height) self.js_maxHeight = self.bounds.size.height;
        self.js_placeholderView.font = self.font;
        self.js_placeholderView.textAlignment = self.textAlignment;
        self.js_placeholderView.textContainerInset = self.textContainerInset;
        self.js_placeholderView.hidden = (self.text.length > 0 && self.text);
    }
}

// 处理文字改变
- (void)textViewTextChange {
    UITextView *placeholderView = objc_getAssociatedObject(self, JSPlaceholderViewKey);
    
    // 如果有值才去调用，这步很重要
    if (placeholderView) {
        self.js_placeholderView.hidden = (self.text.length > 0 && self.text);
    }
    // 如果没有启用自动高度，不执行以下方法
    if (!autoHeight) return;
    if (self.js_maxHeight >= self.bounds.size.height) {
        
        // 计算高度
        NSInteger currentHeight = ceil([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
        
        // 如果高度有变化，调用block
        if (currentHeight != self.lastHeight) {
            // 是否可以滚动
            self.scrollEnabled = currentHeight >= self.js_maxHeight;
            CGFloat currentTextViewHeight = currentHeight >= self.js_maxHeight ? self.js_maxHeight : currentHeight;
            // 改变textView的高度
            if (currentTextViewHeight >= self.js_minHeight) {
                CGRect frame = self.frame;
                frame.size.height = currentTextViewHeight;
                self.frame = frame;
                // 调用block
                if (self.js_textViewHeightDidChanged) self.js_textViewHeightDidChanged(currentTextViewHeight);
                // 记录当前高度
                self.lastHeight = currentTextViewHeight;
            }
        }
    }
    
    if (!self.isFirstResponder) [self becomeFirstResponder];
}

// 判断是否有placeholder值，这步很重要
- (BOOL)placeholderExist {
    
    // 获取对应属性的值
    UITextView *placeholderView = objc_getAssociatedObject(self, JSPlaceholderViewKey);
    
    // 如果有placeholder值
    if (placeholderView) return YES;
    
    return NO;
}

#pragma mark - 过期
- (NSString *)placeholder {
    return self.js_placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.js_placeholder = placeholder;
}

- (UIColor *)placeholderColor {
    return self.js_placeholderColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    self.js_placeholderColor = placeholderColor;
}

- (void)setMaxHeight:(CGFloat)maxHeight {
    self.js_maxHeight = maxHeight;
}

- (CGFloat)maxHeight {
    return self.maxHeight;
}

- (void)setMinHeight:(CGFloat)minHeight {
    self.js_minHeight = minHeight;
}

- (CGFloat)minHeight {
    return self.js_minHeight;
}

- (void)setTextViewHeightDidChanged:(textViewHeightDidChangedBlock)textViewHeightDidChanged {
    self.js_textViewHeightDidChanged = textViewHeightDidChanged;
}

- (textViewHeightDidChangedBlock)textViewHeightDidChanged {
    return self.js_textViewHeightDidChanged;
}

- (NSArray *)getImages {
    return self.js_getImages;
}

- (void)autoHeightWithMaxHeight:(CGFloat)maxHeight {
    [self js_autoHeightWithMaxHeight:maxHeight];
}

- (void)autoHeightWithMaxHeight:(CGFloat)maxHeight textViewHeightDidChanged:(void(^)(CGFloat currentTextViewHeight))textViewHeightDidChanged {
    [self js_autoHeightWithMaxHeight:maxHeight textViewHeightDidChanged:textViewHeightDidChanged];
}

- (void)addImage:(UIImage *)image {
    [self js_addImage:image];
}

- (void)addImage:(UIImage *)image size:(CGSize)size {
    [self js_addImage:image size:size];
}

- (void)insertImage:(UIImage *)image size:(CGSize)size index:(NSInteger)index {
    [self js_insertImage:image size:size index:index];
}

- (void)addImage:(UIImage *)image multiple:(CGFloat)multiple {
    [self js_addImage:image multiple:multiple];
}

- (void)insertImage:(UIImage *)image multiple:(CGFloat)multiple index:(NSInteger)index {
    [self js_insertImage:image multiple:multiple index:index];
}

@end
