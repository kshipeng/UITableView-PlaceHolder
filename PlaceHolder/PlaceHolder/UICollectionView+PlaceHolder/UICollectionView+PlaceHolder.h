//
//  UICollectionView+PlaceHolder.h
//  PlaceHolder
//
//  Created by 康世朋 on 2018/1/12.
//  Copyright © 2018年 康世朋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SPCollectionViewDelegate <NSObject>
@optional
- (UIView   *)sp_placeHolderView;             //  完全自定义占位图
- (UIImage  *)sp_placeHolderImage;            //  使用默认占位图, 提供一张图片,    可不提供, 默认不显示
- (NSString *)sp_placeHolderMessage;          //  使用默认占位图, 提供显示文字,    可不提供, 默认为暂无数据
- (UIColor  *)sp_placeHolderMessageColor;     //  使用默认占位图, 提供显示文字颜色, 可不提供, 默认为灰色
- (NSNumber *)sp_placeHolderViewCenterYOffset;//  使用默认占位图, CenterY 向下的偏移量
- (void      )sp_placeHolderViewClick;        //  使用默认占位图, 点击事件
@end

@interface UICollectionView (PlaceHolder)

@property (nonatomic, assign, getter=isLoading) BOOL loading;

@end


@interface SPPlaceHolder : NSObject

+ (void)setPlaceHolder:(UIView *)view;
+ (UIView *)placeHolder;

+ (void)setImage:(UIImage *)image;
+ (UIImage *)image;

+ (void)setMessage:(NSString *)message;
+ (NSString *)message;

+ (void)setColor:(UIColor *)color;
+ (UIColor *)color;

+ (void)setCenterYOffset:(CGFloat)y;
+ (CGFloat)centerYOffset;

@end
