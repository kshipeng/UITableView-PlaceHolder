//
//  UITableView+PlaceHolder.m
//  PlaceHolder
//
//  Created by 康世朋 on 2018/1/10.
//  Copyright © 2018年 康世朋. All rights reserved.
//

#import "UITableView+PlaceHolder.h"
#import <objc/runtime.h>

NSString * const kSPNoDataViewObserveKeyPath = @"frame";

@implementation UITableView (PlaceHolder)
/** 加载时, 交换方法 */
+ (void)load {
    //  只交换一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Method reloadData    = class_getInstanceMethod(self, @selector(reloadData));
        Method sp_reloadData = class_getInstanceMethod(self, @selector(sp_reloadData));
        method_exchangeImplementations(reloadData, sp_reloadData);
        
        Method dealloc       = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
        Method sp_dealloc    = class_getInstanceMethod(self, @selector(sp_dealloc));
        method_exchangeImplementations(dealloc, sp_dealloc);
    });
}

/** 在 ReloadData 的时候检查数据 */
- (void)sp_reloadData {
    self.tableFooterView = [UIView new];
    [self sp_reloadData];
    
    //  忽略第一次加载
    if (![self isInitFinish]) {
        [self sp_havingData:YES];
        [self setIsInitFinish:YES];
        return ;
    }
    //  刷新完成之后检测数据量
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSInteger numberOfSections = [self numberOfSections];
        BOOL havingData = NO;
        for (NSInteger i = 0; i < numberOfSections; i++) {
            if ([self numberOfRowsInSection:i] > 0) {
                havingData = YES;
                break;
            }
        }
        
        [self sp_havingData:havingData];
    });
}

/** 展示占位图 */
- (void)sp_havingData:(BOOL)havingData {
    
    //  不需要显示占位图
    if (havingData) {
        [self freeNoDataViewIfNeeded];
        self.backgroundView = nil;
        return ;
    }
    
    //  不需要重复创建
    if (self.backgroundView) {
        return ;
    }
    
    //  自定义了占位图
    if ([self.delegate respondsToSelector:@selector(sp_placeHolderView)]) {
        self.backgroundView = [self sp_customNoDataViewWithView:[self.delegate performSelector:@selector(sp_placeHolderView)]];
        [SPPlaceHolderView setPlaceHolder:[self.delegate performSelector:@selector(sp_placeHolderView)]];
    }else {
        if ([SPPlaceHolderView placeHolder] &&
            (   ![self.delegate respondsToSelector:@selector(sp_placeHolderImage)]
             || ![self.delegate respondsToSelector:@selector(sp_placeHolderMessage)]
             || ![self.delegate respondsToSelector:@selector(sp_placeHolderMessageColor)])) {
            self.backgroundView = [self sp_customNoDataViewWithView:[SPPlaceHolderView placeHolder]];
        }else {
            //  使用自带的
            UIImage  *img   = nil;
            NSString *msg   = @"暂无数据";
            UIColor  *color = [UIColor lightGrayColor];
            CGFloat  offset = 0;
            //  获取图片
            if ([self.delegate respondsToSelector:@selector(sp_placeHolderImage)]) {
                img = [self.delegate performSelector:@selector(sp_placeHolderImage)];
                [SPPlaceHolderView setImage:img];
            }else {
                if ([SPPlaceHolderView image]) {
                    img = [SPPlaceHolderView image];
                }
            }
            //  获取文字
            if ([self.delegate respondsToSelector:@selector(sp_placeHolderMessage)]) {
                msg = [self.delegate performSelector:@selector(sp_placeHolderMessage)];
                [SPPlaceHolderView setMessage:msg];
            }else {
                if ([SPPlaceHolderView message]) {
                    msg = [SPPlaceHolderView message];
                }
            }
            //  获取颜色
            if ([self.delegate respondsToSelector:@selector(sp_placeHolderMessageColor)]) {
                color = [self.delegate performSelector:@selector(sp_placeHolderMessageColor)];
                [SPPlaceHolderView setColor:color];
            }else {
                if ([SPPlaceHolderView color]) {
                    color = [SPPlaceHolderView color];
                }
            }
            //  获取偏移量
            if ([self.delegate respondsToSelector:@selector(sp_placeHolderViewCenterYOffset)]) {
                offset = [[self.delegate performSelector:@selector(sp_placeHolderViewCenterYOffset)] floatValue];
                [SPPlaceHolderView setCenterYOffset:offset];
            }else {
                if ([SPPlaceHolderView centerYOffset]) {
                    offset = [SPPlaceHolderView centerYOffset];
                }
            }
            
            //  创建占位图
            self.backgroundView = [self sp_defaultNoDataViewWithImage:img message:msg color:color offsetY:offset];
        }
        
    }
    
    //  实现跟随 TableView 滚动
    [self.backgroundView addObserver:self forKeyPath:kSPNoDataViewObserveKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

/** 默认的占位图 */
- (UIView *)sp_defaultNoDataViewWithImage:(UIImage *)image message:(NSString *)message color:(UIColor *)color offsetY:(CGFloat)offset {
    
    //  计算位置, 垂直居中, 图片默认中心偏上.
    CGFloat sW = self.bounds.size.width;
    CGFloat cX = sW / 2;
    CGFloat cY = self.bounds.size.height * (1.0 - 0.618) + offset;
    CGFloat iW = image.size.width;
    CGFloat iH = image.size.height;
    
    //  图片
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.image = image;
    imgView.frame = CGRectMake(cX - iW / 2, cY + CGRectGetHeight(self.tableHeaderView.frame) * 0.618 - iH / 2.0, iW, iH);
    
    //  文字
    UILabel *label       = [[UILabel alloc] init];
    label.font           = [UIFont systemFontOfSize:17];
    label.textColor      = color;
    label.text           = message;
    label.textAlignment  = NSTextAlignmentCenter;
    label.frame          = CGRectMake(0, CGRectGetMaxY(imgView.frame) + 24, sW, label.font.lineHeight);
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelClick)];
    [label addGestureRecognizer:tap];

    //  视图
    UIView *view   = [[UIView alloc] init];
    [view addSubview:imgView];
    [view addSubview:label];

    return view;
}

- (void)labelClick {
    if ([self.delegate respondsToSelector:@selector(sp_placeHolderViewClick)]) {
        [self.delegate performSelector:@selector(sp_placeHolderViewClick)];
    }
}

/** 自定义的占位图 */
- (UIView *)sp_customNoDataViewWithView:(UIView *)view {
    //  计算位置, 居中
    CGFloat sW = self.bounds.size.width;
    CGFloat cX = sW / 2;
    CGFloat offset = 0.0;
    //  获取偏移量
    if ([self.delegate respondsToSelector:@selector(sp_placeHolderViewCenterYOffset)]) {
        offset = [[self.delegate performSelector:@selector(sp_placeHolderViewCenterYOffset)] floatValue];
    }
    CGFloat cY = self.bounds.size.height * (1.0 - 0.618) + offset;
    CGFloat vW = view.frame.size.width;
    CGFloat vH = view.frame.size.height;
    view.frame = CGRectMake(cX-vW / 2, cY + CGRectGetHeight(self.tableHeaderView.frame) * 0.618 - vH / 2.0, vW, vH);

    //  视图
    UIView *bgview   = [[UIView alloc] init];
    [bgview addSubview:view];
    return bgview;
}


/** 监听 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kSPNoDataViewObserveKeyPath]) {
        
        /**
         默认：在 TableView 滚动 ContentOffset 改变时, 会同步改变 backgroundView 的 frame.origin.y
         可以实现, backgroundView 位置相对于 TableView 不动；
         现在：我们希望backgroundView 跟随 TableView 的滚动而滚动, 故强制设置 frame.origin.y 永远为 0
         */
        CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        if (frame.origin.y != 0) {
            frame.origin.y  = 0;
            self.backgroundView.frame = frame;
        }
    }
}
#pragma mark - 加载提示
static NSString * const kSPTableViewLoading = @"kSPTableViewLoading";
static NSString * const kSPTableViewLoadingView = @"kSPTableViewLoadingView";

- (void)setLoading:(BOOL)loading {
    objc_setAssociatedObject(self, &kSPTableViewLoading, @(loading), OBJC_ASSOCIATION_ASSIGN);
    [self addActivityIndicatorView];
}

- (BOOL)isLoading {
    id obj = objc_getAssociatedObject(self, &kSPTableViewLoading);
    return [obj boolValue];
}

- (void)setActivityView:(UIActivityIndicatorView *)activityView {
    objc_setAssociatedObject(self, &kSPTableViewLoadingView, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIActivityIndicatorView *)activityView {
    return objc_getAssociatedObject(self, &kSPTableViewLoadingView);
}

- (void)addActivityIndicatorView {
    CGFloat sW = self.bounds.size.width;
    CGFloat cX = sW / 2;
    CGFloat offset = 0.0;
    //  获取偏移量
    if ([self.delegate respondsToSelector:@selector(sp_placeHolderViewCenterYOffset)]) {
        offset = [[self.delegate performSelector:@selector(sp_placeHolderViewCenterYOffset)] floatValue];
    }
    CGFloat cY = self.bounds.size.height * (1.0 - 0.618) + offset;
    if (self.isLoading) {
        self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView.hidesWhenStopped = YES;
        self.activityView.center = CGPointMake(cX, cY+ CGRectGetHeight(self.tableHeaderView.frame) * 0.618 + offset);
        
        [self addSubview:self.activityView];
        [self.activityView startAnimating];
    }else {
        [self.activityView stopAnimating];
    }
    
}


#pragma mark - 属性

/// 加载完数据的标记属性名
static NSString * const kSPTableViewPropertyInitFinish = @"kSPTableViewPropertyInitFinish";

/** 设置已经加载完成数据了 */
- (void)setIsInitFinish:(BOOL)finish {
    objc_setAssociatedObject(self, &kSPTableViewPropertyInitFinish, @(finish), OBJC_ASSOCIATION_ASSIGN);
}

/** 是否已经加载完成数据 */
- (BOOL)isInitFinish {
    id obj = objc_getAssociatedObject(self, &kSPTableViewPropertyInitFinish);
    return [obj boolValue];
}

/** 移除 KVO 监听 */
- (void)freeNoDataViewIfNeeded {
    
    if ([self.backgroundView isKindOfClass:[UIView class]]) {
        [self.backgroundView removeObserver:self forKeyPath:kSPNoDataViewObserveKeyPath context:nil];
    }
}

- (void)sp_dealloc {
    [self freeNoDataViewIfNeeded];
    [self sp_dealloc];
    //NSLog(@"TableView + PlaceHolder 视图正常销毁");
}
@end


@interface SPPlaceHolderView()

@property (nonatomic, strong) UIView *palceHolderView;
@property (nonatomic, strong) UIImage *placeHolderImage;
@property (nonatomic, strong) NSString *placeHolderMessage;
@property (nonatomic, strong) UIColor *placeHolderMessageColor;
@property (nonatomic, assign) CGFloat placeHolderViewCenterYOffset;

@end

@implementation SPPlaceHolderView

+ (instancetype)shareInstance {
    static SPPlaceHolderView *place;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        place = [[self alloc]init];
        place.placeHolderViewCenterYOffset = 0.0;
    });
    return place;
}

+ (void)setPlaceHolder:(UIView *)view {
    [SPPlaceHolderView shareInstance].palceHolderView = view;
}
+ (UIView *)placeHolder {
    return [SPPlaceHolderView shareInstance].palceHolderView;
}

+ (void)setImage:(UIImage *)image {
    [SPPlaceHolderView shareInstance].placeHolderImage = image;
}
+ (UIImage *)image {
    return [SPPlaceHolderView shareInstance].placeHolderImage;
}

+ (void)setMessage:(NSString *)message {
    [SPPlaceHolderView shareInstance].placeHolderMessage = message;
}
+ (NSString *)message {
    return [SPPlaceHolderView shareInstance].placeHolderMessage;
}

+ (void)setColor:(UIColor *)color {
    [SPPlaceHolderView shareInstance].placeHolderMessageColor = color;
}
+ (UIColor *)color {
    return [SPPlaceHolderView shareInstance].placeHolderMessageColor;
}

+ (void)setCenterYOffset:(CGFloat)y {
    [SPPlaceHolderView shareInstance].placeHolderViewCenterYOffset = y;
}
+ (CGFloat)centerYOffset {
    return [SPPlaceHolderView shareInstance].placeHolderViewCenterYOffset;
}



@end

