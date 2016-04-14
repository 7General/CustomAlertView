//
//  HZAlertView.h
//  AlertView
//
//  Created by 王会洲 on 16/4/7.
//  Copyright © 2016年 王会洲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"

#if NS_BLOCKS_AVAILABLE
typedef void(^HZBasicActionBlock)();
#endif


@protocol HZAlertViewDelegate;


@interface HZAlertView : UIView

@property (nonatomic, strong) UIView * contentView;
// 取消按钮
@property (nonatomic, strong) UIButton * cancelButton;
// 其他按钮
@property (nonatomic, strong) UIButton * otherButton;



/*!
 在点击确认后,是否需要dismiss, 默认YES
 */
@property (nonatomic, assign) BOOL shouldDismissAfterConfirm;


#if NS_BLOCKS_AVAILABLE
@property (nonatomic, copy) HZBasicActionBlock  cancelBlock;
@property (nonatomic, copy) HZBasicActionBlock  confirmBlock;
#endif

/*!
 @abstract      点击取消按钮的回调
 @discussion    如果你不想用代理的方式来进行回调，可使用该方法
 @param         block  点击取消后执行的程序块
 */
- (void)setCancelBlock:(HZBasicActionBlock)block;

/*!
 @abstract      点击确定按钮的回调
 @discussion    如果你不想用代理的方式来进行回调，可使用该方法
 @param         block  点击确定后执行的程序块
 */
- (void)setConfirmBlock:(HZBasicActionBlock)block;



/**代理相关**/
@property (nonatomic, assign) id<HZAlertViewDelegate>  delegate;



/*!
 @abstract      初始话方法，默认的style：AlertViewStyleDefault
 @param         title  标题
 @param         message  内容
 @param         delegate  代理
 @param         cancelButtonTitle  取消按钮title
 @param         otherButtonTitle  其他按钮，如确定
 @result        BBAlertView的对象
 */
- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
             delegate:(id <HZAlertViewDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitle;



-(id)initWithTitle:(NSString *)title
                 message:(NSString *)message
              customView:(UIView *)customView
                    delegate:(id <HZAlertViewDelegate>)delegate
       cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitles:(NSString *)otherButtonTitle;


/******************************************************************************
 函数名称 : 模仿系统AlertView界面
 函数描述 : 系统alertView
 输入参数 : (NSString *)title                                       标题
 输入参数 : (NSString *)message                             文本信息
 输入参数 : (id<HZAlertViewDelegate>)delegate    代理
 输入参数 : (NSString *)cancelButtonTitle                取消文本
 输入参数 : (NSString *)otherButtonTitle                  其他文本
 输出参数 : N/A
 返回参数 :
 备注信息 :
 ******************************************************************************/
-(id)initWithSystemTitle:(NSString *)title
                        message:(NSString *)message
                         delegate:(id<HZAlertViewDelegate>)delegate
          cancelButtonTitle:(NSString *)cancelButtonTitle
          otherButtonTitles:(NSString *)otherButtonTitle;





/**
 *  弹出alert
 */
- (void)show;

@end


@protocol HZAlertViewDelegate <NSObject>

@optional
- (void)alertView:(HZAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)alertView:(HZAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

- (void)didRotationToInterfaceOrientation:(BOOL)Landscape view:(UIView*)view alertView:(HZAlertView *)aletView;

@end
