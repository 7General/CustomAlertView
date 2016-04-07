//
//  HZAlertView.m
//  AlertView
//
//  Created by 王会洲 on 16/4/7.
//  Copyright © 2016年 王会洲. All rights reserved.
//


#import "HZAlertView.h"
#import "UIView+Additions.h"
@interface HZAlertView ()
/****内容相关*****/
@property (nonatomic, strong) UITextView * bodyTextView;
@property (nonatomic, strong) UILabel * bodyTextLabel;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIView * customView;




// 点击按钮的TAG
@property (nonatomic, assign) NSInteger  clickedButtonIndex;

// 是否已经显示
@property (nonatomic, assign) BOOL  visible;

@property (nonatomic, strong) UIView * backgroundView;

/**
 *  设备旋转办法
 */
@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end


static CGFloat kTransitionDuration = 0.3f;
static NSMutableArray * gAlertViewStack = nil;
static UIWindow *gPreviouseKeyWindow = nil;
static UIWindow * gMaskWindow = nil;


@implementation HZAlertView

/**懒加载数据**/
-(UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitle:(@"Ok") forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)otherButton{
    if (!_otherButton) {
        _otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_otherButton setTitle:(@"Ok") forState:UIControlStateNormal];
        [_otherButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherButton;
}
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (UILabel *)bodyTextLabel
{
    if (!_bodyTextLabel) {
        _bodyTextLabel = [[UILabel alloc] init];
        _bodyTextLabel.numberOfLines = 0;
        //        _bodyTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        //        _bodyTextLabel.textAlignment = _contentAlignment;
        _bodyTextLabel.backgroundColor = [UIColor clearColor];
    }
    return _bodyTextLabel;
}

- (UITextView *)bodyTextView
{
    if (!_bodyTextView) {
        _bodyTextView = [[UITextView alloc] init];
        //        _bodyTextView.textAlignment = _contentAlignment;
        _bodyTextView.bounces = NO;
        _bodyTextView.backgroundColor = [UIColor clearColor];
        _bodyTextView.editable = NO;
    }
    return _bodyTextView;
}


#pragma mark -按钮点击事件
#pragma mark button action
- (void)buttonTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    self.clickedButtonIndex = tag;
    
    if ([self.delegate conformsToProtocol:@protocol(HZAlertViewDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
            // 调用代理函数
            [self.delegate alertView:self willDismissWithButtonIndex:tag];
        }
    }
    
    if (button == self.cancelButton) {
        if (self.cancelBlock) {
            self.cancelBlock();
        }
        [self dismiss];
    }
    else if (button == self.otherButton)
    {
        
        if (self.confirmBlock) {
            self.confirmBlock();
        }
        if (_shouldDismissAfterConfirm) {
            [self dismiss];
        }
    }
    
}

/***************************/
/**
 *  显示
 */
- (void)show
{
    if (_visible) {
        return;
    }
    _visible = YES;
    
    //[self registerObservers];//添加消息，在设备发生旋转时会有相应的处理
    //[self sizeToFitOrientation:NO];
    
    
    //如果栈中没有alertview,就表示maskWindow没有弹出，所以弹出maskWindow
    if (![HZAlertView getStackTopAlertView]) {
        [HZAlertView presentMaskWindow];
    }
    
    //如果有背景图片，添加背景图片
    if (nil != self.backgroundView && ![[gMaskWindow subviews] containsObject:self.backgroundView]) {
        [gMaskWindow addSubview:self.backgroundView];
    }
    //将alertView显示在window上
    [HZAlertView addAlertViewOnMaskWindow:self];
    
    self.alpha = 1.0;
    
    //alertView弹出动画
    [self bounce0Animation];
}

/**
 *  把当前的alertView添加到当前队列中
 *
 *  @param alertView <#alertView description#>
 */
+ (void)addAlertViewOnMaskWindow:(HZAlertView *)alertView{
    if (!gMaskWindow ||[gMaskWindow.subviews containsObject:alertView]) {
        return;
    }
    
    [gMaskWindow addSubview:alertView];
    alertView.hidden = NO;
    
    HZAlertView *previousAlertView = [HZAlertView getStackTopAlertView];
    if (previousAlertView) {
        previousAlertView.hidden = YES;
    }
    [HZAlertView pushAlertViewInStack:alertView];
}

/**
 *  取得最靠前的window
 */
+ (void)presentMaskWindow{
    
    if (!gMaskWindow) {
        gMaskWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        //edited by gjf 修改alertview leavel
        gMaskWindow.windowLevel = UIWindowLevelStatusBar + BBAlertLeavel;
        gMaskWindow.backgroundColor = [UIColor clearColor];
        gMaskWindow.hidden = YES;
        
        // FIXME: window at index 0 is not awalys previous key window.
        gPreviouseKeyWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [gMaskWindow makeKeyAndVisible];
        
        // Fade in background
        gMaskWindow.alpha = 0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        gMaskWindow.alpha = 1;
        [UIView commitAnimations];
    }
}

/**
 *  消失
 */
- (void)dismiss
{
    if (!_visible) {
        return;
    }
    _visible = NO;
    
    UIView *__bgView = self->_backgroundView;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissAlertView)];
    self.alpha = 0;
    [UIView commitAnimations];
    
    if (__bgView && [[gMaskWindow subviews] containsObject:__bgView]) {
        [__bgView removeFromSuperview];
    }
}


- (void)dismissAlertView{
    [HZAlertView removeAlertViewFormMaskWindow:self];
    
    // If there are no dialogs visible, dissmiss mask window too.
    if (![HZAlertView getStackTopAlertView]) {
        [HZAlertView dismissMaskWindow];
    }
    
    //if (_style != BBAlertViewStyleCustomView) {
    if ([self.delegate conformsToProtocol:@protocol(HZAlertViewDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
            [self.delegate alertView:self didDismissWithButtonIndex:self.clickedButtonIndex];
        }
    }
    //}
    
    //[self removeObservers];
}
+ (void)removeAlertViewFormMaskWindow:(HZAlertView *)alertView{
    if (!gMaskWindow || ![gMaskWindow.subviews containsObject:alertView]) {
        return;
    }
    
    [alertView removeFromSuperview];
    alertView.hidden = YES;
    
    [HZAlertView popAlertViewFromStack];
    HZAlertView *previousAlertView = [HZAlertView getStackTopAlertView];
    if (previousAlertView) {
        previousAlertView.hidden = NO;
        [previousAlertView bounce0Animation];
    }
}


#pragma mark -出栈
+ (void)popAlertViewFromStack{
    if (![gAlertViewStack count]) {
        return;
    }
    [gAlertViewStack removeLastObject];
    
    if ([gAlertViewStack count] == 0) {
        gAlertViewStack = nil;
    }
}


#pragma mark -入栈
+ (void)pushAlertViewInStack:(HZAlertView *)alertView{
    if (!gAlertViewStack) {
        gAlertViewStack = [[NSMutableArray alloc] init];
    }
    [gAlertViewStack addObject:alertView];
}


#pragma mark - 栈区顶层的view
+ (HZAlertView *)getStackTopAlertView{
    HZAlertView * topItem = nil;
    if (0 != [gAlertViewStack count]) {
        topItem = [gAlertViewStack lastObject];
    }
    return topItem;
}
+ (void)dismissMaskWindow{
    // make previouse window the key again
    if (gMaskWindow) {
        [gPreviouseKeyWindow makeKeyWindow];
        gPreviouseKeyWindow = nil;
        
        gMaskWindow = nil;
    }
}

#pragma mark block setter block构造器
- (void)setCancelBlock:(HZBasicActionBlock)block {
    _cancelBlock = [block copy];
}
- (void)setConfirmBlock:(HZBasicActionBlock)block {
    _confirmBlock = [block copy];
}

//- (void)sizeToFitOrientation:(BOOL)transform
//{
//    if (transform) {
//        self.transform = CGAffineTransformIdentity;
//    }
//    _orientation = [UIApplication sharedApplication].statusBarOrientation;
//    [self sizeToFit];
//    CGSize screenSize = [UIScreen mainScreen].bounds.size;
//    [self setCenter:CGPointMake(screenSize.width/2, screenSize.height/2)];
//    if (transform) {
//        self.transform = [self transformForOrientation];
//    }
//}



- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id <HZAlertViewDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitle {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self initData];
        _delegate = delegate;
        
        [self HZAlertBasciView:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle];
    }
    return self;
}

/**
 *  aletView基本元素绘图
 *
 *  @param title             标题
 *  @param message           内容
 *  @param cancelButtonTitle 取消按钮
 *  @param otherButtonTitle  其他按钮
 */
-(void)HZAlertBasciView:(NSString *)title
                message:(NSString *)message
      cancelButtonTitle:(NSString *)cancelButtonTitle
      otherButtonTitles:(NSString *)otherButtonTitle {
    
    CGFloat titleHeight = 0.0f;
    // 标题高度
    if (title)
    {
        titleHeight = 42.0f;
    }
    
    //content view
    CGFloat boxWidth = ALERTWIDTH;   //弹出框宽度
    // 文字内容区域宽度
    CGFloat contentWidth = 220;
    // 标题frame

    CGRect titleBgFrame = CGRectMake(0, 0, boxWidth, titleHeight);
    // 计算内容区域content的frame
    CGSize maxSize = CGSizeMake(contentWidth, MAXFLOAT);
    CGSize messageSize = [HZAlertView sizeWithText:message font:CONTENTFONT maxSize:maxSize];
    
    CGFloat contentHeight = messageSize.height > 20 ? messageSize.height : 20;
    
    BOOL isNeedUseTextView = NO;
    // 如果内容区域高度 > 240 12 行
    if (contentHeight > 240)
    {
        isNeedUseTextView = YES;
        contentHeight = 240;
    }else if (contentHeight < 60){
        contentHeight = 60;
    }
    
    // 内容区域frame
    CGFloat paddingBottom =  titleHeight > 0 ? 0 : 15;
    CGRect contentFrame = CGRectMake((boxWidth-contentWidth)/2, CGRectGetMaxY(titleBgFrame)+paddingBottom, contentWidth, contentHeight);
    
    //button 1
    CGFloat btnTop = CGRectGetMaxY(contentFrame) + 9;
    CGFloat btnHeight = 35;
    
    if (cancelButtonTitle && otherButtonTitle) {
        CGFloat btnWidth = 115;
        [self.cancelButton setBackgroundImage:leftBtnImage forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor darkGrayColor]  forState:UIControlStateNormal];
        [self.cancelButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [self.cancelButton setFrame:CGRectMake(10, btnTop, btnWidth, btnHeight)];
        [self.cancelButton setTag:0];
        
        [self.otherButton setBackgroundImage:rightBtnImage forState:UIControlStateNormal];
        [self.otherButton setTitleColor:YSColor(255, 255, 255) forState:UIControlStateNormal];
        
        [self.otherButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
        [self.otherButton setFrame:CGRectMake(self.cancelButton.right+10, btnTop, btnWidth, btnHeight)];
        [self.otherButton setTag:1];
        
        [self.contentView addSubview:self.cancelButton];
        [self.contentView addSubview:self.otherButton];
    }else if (cancelButtonTitle){
        CGFloat btnWidth = 140;
        UIImage *image2 = rightBtnImage;
        [self.cancelButton setBackgroundImage:image2 forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:YSColor(255, 255, 255) forState:UIControlStateNormal];
        [self.cancelButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [self.cancelButton setFrame:CGRectMake(60, btnTop - 9, btnWidth, btnHeight)];
        [self.cancelButton setTag:0];
        [self.contentView addSubview:self.cancelButton];
        
    }else if (otherButtonTitle){
        CGFloat btnWidth = 140;
        UIImage *image2 = rightBtnImage;
        [self.otherButton setBackgroundImage:image2 forState:UIControlStateNormal];
        [self.otherButton setTitleColor:YSColor(255, 255, 255) forState:UIControlStateNormal];
        [self.otherButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
        [self.otherButton setFrame:CGRectMake(60, btnTop - 9, btnWidth, btnHeight)];
        [self.otherButton setTag:0];
        [self.contentView addSubview:self.otherButton];
    }
    CGFloat boxHeight = titleBgFrame.size.height+15+contentHeight+10+btnHeight+10;
    
    self.contentView.center = CGPointMake(self.centerX, self.centerY);
    self.contentView.bounds = CGRectMake(0, 0, boxWidth, boxHeight);
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 1.0;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    //titleBg imageView
    //        UIImageView *titleBg = [[UIImageView alloc] init];
    //        titleBg.layer.shadowColor = [UIColor grayColor].CGColor;
    //        titleBg.layer.shadowOffset = CGSizeMake(0.7, 0.7);
    //        titleBg.layer.shadowOpacity = 0.8;
    //        titleBg.clipsToBounds = NO;
    //        titleBg.frame = titleBgFrame;
    //        titleBg.image = [UIImage imageNamed:@"system_nav_bg.png"];
    //        [self.contentView addSubview:titleBg];
    //        TT_RELEASE_SAFELY(titleBg);
    
    //titleLabel
    self.titleLabel.text = title;
    self.titleLabel.frame = titleBgFrame;
    
    self.titleLabel.textColor = [UIColor darkTextColor];
//    self.titleLabel.shadowOffset = CGSizeMake(1, 1);
//    self.titleLabel.shadowColor = YSColor(246, 242, 224);
    self.titleLabel.font = TITLEFONT;
    [self.contentView addSubview:self.titleLabel];
    
    //message
    
    if (isNeedUseTextView) {
        self.bodyTextView.text = message;
        self.bodyTextView.frame = contentFrame;
        self.bodyTextView.font = CONTENTFONT;
        self.bodyTextView.textColor = YSColor(0, 0, 0);
        
        [self.contentView addSubview:self.bodyTextView];
    }else{
        self.bodyTextLabel.text = message;
        self.bodyTextLabel.frame = contentFrame;
        self.bodyTextLabel.font = CONTENTFONT;
        self.bodyTextLabel.textColor = YSColor(0, 0, 0);
        [self.contentView addSubview:self.bodyTextLabel];
    }
    
}



-(id)initWithTitle:(NSString *)title
        customView:(UIView *)customView
          delegate:(id <HZAlertViewDelegate>)delegate
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitle {
    
    return   [self initWithTitle:title message:nil delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle];
    
    
}


-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
        customView:(UIView *)customView
          delegate:(id <HZAlertViewDelegate>)delegate
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitle
{
    //content view
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self initData];
        _delegate = delegate;
        
        CGFloat titleHeight = 0.0f;
        // 标题高度
        if (title)
        {
            titleHeight = 42.0f;
        }
        
        CGFloat bodyHeight = 0.0f;
        // 文本信息
        if (message)
        {
            CGFloat contentWidth = 220;
            CGSize BodySize = CGSizeMake(contentWidth, MAXFLOAT);
            bodyHeight = [HZAlertView sizeWithText:message font:CONTENTFONT maxSize:BodySize].height + 20;
        }
        
        CGFloat customViewHeight = 0.0f;
        if (customView) {
            self.customView = customView;
            customViewHeight = customView.height;
        }
        CGFloat buttonPartHeight = 50.0f;
        
        
        BOOL isNeedUserTextView = bodyHeight > 170;
        bodyHeight = isNeedUserTextView?170:bodyHeight;
        // alertView高度 = 标题高度+文本高度  +   自定义view高度 + 按钮高度
        CGFloat finalHeight = titleHeight+bodyHeight+customViewHeight+buttonPartHeight;
        
        self.contentView.backgroundColor = YSColor(255, 255, 255);
        
        self.contentView.center = CGPointMake(self.centerX, self.centerY);
        self.contentView.bounds = CGRectMake(0, 0, 280, finalHeight);
        
        UIView *alertMainView = [[UIView alloc] init];
        alertMainView.frame = CGRectMake(0, 0, 280, finalHeight);
        alertMainView.backgroundColor = [UIColor whiteColor];
        //alertMainView.layer.cornerRadius = 4.0;
        [self.contentView addSubview:alertMainView];
        
        
        // 标题背景图片
        UIImageView *titleBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, titleHeight)];
        UIImage *image1 = [UIImage imageNamed:@"MessageFilterConfirmBtn"];
        UIImage *streImage1 = [image1 stretchableImageWithLeftCapWidth:image1.size.width/2 topCapHeight:0];
        titleBgImageView.image = streImage1;
        [alertMainView addSubview:titleBgImageView];
        
        
        
        //titleLabel
        CGSize titleMaxSize = CGSizeMake(MAXFLOAT, titleHeight);
        CGSize titleSize = [HZAlertView sizeWithText:title font:TITLEFONT maxSize:titleMaxSize];
        CGFloat titleWidth = titleSize.width<240?titleSize.width:240;
        self.titleLabel.text = title;
        self.titleLabel.font = TITLEFONT;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.center = CGPointMake(titleBgImageView.centerX, titleBgImageView.centerY);
        self.titleLabel.bounds = CGRectMake(0, 0, titleWidth, titleHeight);
        [alertMainView addSubview:self.titleLabel];
        
        
        
        //bodyLabel
        if (isNeedUserTextView) {
            self.bodyTextView.text = message;
            self.bodyTextView.frame = CGRectMake(5, titleHeight, ALERTWIDTH, bodyHeight);
            self.bodyTextView.font = [UIFont systemFontOfSize:16.0f];
            [alertMainView addSubview:self.bodyTextView];
        }else{
            self.bodyTextLabel.text = message;
            self.bodyTextLabel.frame = CGRectMake(5, titleHeight, ALERTWIDTH, bodyHeight);
            self.bodyTextLabel.font = [UIFont systemFontOfSize:16.0f];
            [alertMainView addSubview:self.bodyTextLabel];
        }

        
        
        
        //custom view
        if (customView) {
            customView.frame = CGRectMake(customView.left, titleHeight, customView.width, customView.height);
            [alertMainView addSubview:customView];
        }
        
        //buttons
        if (cancelButtonTitle && otherButtonTitle) {
            CGFloat buttonTopPosition = titleHeight+bodyHeight+customViewHeight+10;
            UIImage *image3 = [UIImage imageNamed:@"MessageFilterConfirmBtn"];
            UIImage *image4 = [UIImage imageNamed:@"MessageFilterCancelBtn"];
            
            UIImage *streImage3 = [image3 stretchableImageWithLeftCapWidth:image3.size.width/2 topCapHeight:0];
            UIImage *streImage4 = [image4 stretchableImageWithLeftCapWidth:image4.size.width/2 topCapHeight:0];
            [self.cancelButton setBackgroundImage:streImage4 forState:UIControlStateNormal];
            [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.cancelButton setFrame:CGRectMake(30, buttonTopPosition, 80, 33)];
            [self.cancelButton setTag:0];
            
            [self.otherButton setBackgroundImage:streImage3 forState:UIControlStateNormal];
            [self.otherButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
            [self.otherButton setFrame:CGRectMake(self.cancelButton.right+50, buttonTopPosition, 80, 33)];
            [self.otherButton setTag:1];
            [alertMainView addSubview:self.cancelButton];
            [alertMainView addSubview:self.otherButton];
        }else if (cancelButtonTitle){
            CGFloat buttonTopPosition = titleHeight+bodyHeight+customViewHeight+10;
            UIImage *image3 = rightBtnImage;
            UIImage *streImage3 = [image3 stretchableImageWithLeftCapWidth:image3.size.width/2 topCapHeight:0];
            [self.cancelButton setBackgroundImage:streImage3 forState:UIControlStateNormal];
            [self.cancelButton setTitle:cancelButtonTitle?cancelButtonTitle:otherButtonTitle forState:UIControlStateNormal];
            [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.cancelButton setFrame:CGRectMake(30, buttonTopPosition, 210, 33)];
            [self.cancelButton setTag:0];
            [alertMainView addSubview:self.cancelButton];
        }else if (otherButtonTitle){
            CGFloat buttonTopPosition = titleHeight+bodyHeight+customViewHeight+10;
            UIImage *image3 = rightBtnImage;
            UIImage *streImage3 = [image3 stretchableImageWithLeftCapWidth:image3.size.width/2 topCapHeight:0];
            [self.otherButton setBackgroundImage:streImage3 forState:UIControlStateNormal];
            [self.otherButton setTitle:cancelButtonTitle?cancelButtonTitle:otherButtonTitle forState:UIControlStateNormal];
            [self.otherButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.otherButton setFrame:CGRectMake(30, buttonTopPosition, 210, 33)];
            [self.otherButton setTag:0];
            [alertMainView addSubview:self.otherButton];
        }
        
        
    }
    return self;
}


/**
 *  添加按钮布局
 *
 *  @param startLeft <#startLeft description#>
 *  @param btnWidth  <#btnWidth description#>
 *  @param btnHeigth <#btnHeigth description#>
 */
-(void)setButtonPartView:(CGFloat)startLeft
                     Top:(CGFloat)btnTop
                       W:(CGFloat)btnWidth
                       H:(CGFloat)btnHeight
                paddingH:(CGFloat)btnDistance
           singleBtnLeft:(CGFloat)singleleft
              singleBtnW:(CGFloat)singleWidth
       cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitles:(NSString *)otherButtonTitle {
    
    if (cancelButtonTitle && otherButtonTitle) {
        
        [self.cancelButton setBackgroundImage:leftBtnImage forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor darkGrayColor]  forState:UIControlStateNormal];
        [self.cancelButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [self.cancelButton setFrame:CGRectMake(startLeft, btnTop, btnWidth, btnHeight)];
        [self.cancelButton setTag:0];
        
        [self.otherButton setBackgroundImage:rightBtnImage forState:UIControlStateNormal];
        [self.otherButton setTitleColor:YSColor(255, 255, 255) forState:UIControlStateNormal];
        
        [self.otherButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
        [self.otherButton setFrame:CGRectMake(self.cancelButton.right+10, btnTop, btnWidth, btnHeight)];
        [self.otherButton setTag:1];
        
        [self.contentView addSubview:self.cancelButton];
        [self.contentView addSubview:self.otherButton];
    }else if (cancelButtonTitle){
        
        UIImage *image2 = rightBtnImage;
        [self.cancelButton setBackgroundImage:image2 forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:YSColor(255, 255, 255) forState:UIControlStateNormal];
        [self.cancelButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [self.cancelButton setFrame:CGRectMake(60, btnTop - 9, singleWidth, btnHeight)];
        [self.cancelButton setTag:0];
        [self.contentView addSubview:self.cancelButton];
        
    }else if (otherButtonTitle){
        
        UIImage *image2 = rightBtnImage;
        [self.otherButton setBackgroundImage:image2 forState:UIControlStateNormal];
        [self.otherButton setTitleColor:YSColor(255, 255, 255) forState:UIControlStateNormal];
        [self.otherButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
        [self.otherButton setFrame:CGRectMake(60, btnTop - 9, singleWidth, btnHeight)];
        [self.otherButton setTag:0];
        [self.contentView addSubview:self.otherButton];
    }
}

- (void)dealloc {
    _delegate = nil;
    
    //    TT_RELEASE_SAFELY(_titleLabel);
    //    TT_RELEASE_SAFELY(_bodyTextLabel);
    //    TT_RELEASE_SAFELY(_bodyTextView);
    //    TT_RELEASE_SAFELY(_customView);
    //    TT_RELEASE_SAFELY(_backgroundView);
    //    TT_RELEASE_SAFELY(_contentView);
    //    TT_RELEASE_SAFELY(_cancelButton);
    //    TT_RELEASE_SAFELY(_otherButton);
    _cancelBlock = nil;
    _confirmBlock = nil;
    [self removeObserver:self forKeyPath:@"dimBackground"];
    [self removeObserver:self forKeyPath:@"contentAlignment"];
}

/**
 *  初始化数据
 */
- (void)initData
{
    self.shouldDismissAfterConfirm = YES;
    //_dimBackground = YES;
    self.backgroundColor = [UIColor clearColor];
    //_contentAlignment = UITextAlignmentCenter;
    
    [self addObserver:self  forKeyPath:@"dimBackground"   options:NSKeyValueObservingOptionNew  context:NULL];
    
    [self addObserver:self  forKeyPath:@"contentAlignment"  options:NSKeyValueObservingOptionNew   context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"dimBackground"]) {
        [self setNeedsDisplay];
    }else if ([keyPath isEqualToString:@"contentAlignment"]){
        //self.bodyTextLabel.textAlignment = self.contentAlignment;
        //self.bodyTextView.textAlignment = self.contentAlignment;
    }
}












-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    size_t gradLocationsNum = 2;
    CGFloat gradLocations[2] = {0.0f, 0.0f};
    CGFloat gradColors[8] = {
        0.0f,0.0f,0.0f,
        0.0f,0.0f,0.0f,
        0.0f,0.40f
    };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
    CGColorSpaceRelease(colorSpace);
    //Gradient center
    CGPoint gradCenter = self.contentView.center;
    //Gradient radius
    float gradRadius = 320 ;
    //Gradient draw
    CGContextDrawRadialGradient (context, gradient, gradCenter,
                                 0, gradCenter, gradRadius,
                                 kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}
#pragma mark -
#pragma mark animation

- (void)bounce0Animation{
    self.contentView.transform = CGAffineTransformScale([self transformForOrientation], 0.001f, 0.001f);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationDidStop)];
    self.contentView.transform = CGAffineTransformScale([self transformForOrientation], 1.1f, 1.1f);
    [UIView commitAnimations];
}


- (void)bounce1AnimationDidStop{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationDidStop)];
    self.contentView.transform = CGAffineTransformScale([self transformForOrientation], 0.9f, 0.9f);
    [UIView commitAnimations];
}
- (void)bounce2AnimationDidStop{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounceDidStop)];
    self.contentView.transform = [self transformForOrientation];
    [UIView commitAnimations];
}

- (void)bounceDidStop{
    
}

- (CGAffineTransform)transformForOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5f);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2.0f);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}


+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary * attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}
@end
