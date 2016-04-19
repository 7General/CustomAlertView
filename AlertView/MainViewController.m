//
//  MainViewController.m
//  AlertView
//
//  Created by 王会洲 on 16/4/7.
//  Copyright © 2016年 王会洲. All rights reserved.
//

#import "MainViewController.h"
#import "HZAlertView.h"

@interface MainViewController ()<HZAlertViewDelegate>
@property (nonatomic, strong) NSString * dataText;
@end

@implementation MainViewController

/********************************************************
 HZAlertView封装自系统的alertview，可能在尺寸上和
 系统控件有差别，在系统的原有的基础上增加了出现时的
 收缩动画。
 建议使用
 HZAlertView * customAlert = [[HZAlertView alloc] initWithSystemTitle:@"提示" message:@"dd" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"确定"];
 [customAlert show];
 
 
 其他函数是否比较丑陋，是模仿苏宁很早之前版本的alertview的UI
 ********************************************************/


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"====>>>%@",L(@"loding"));
    
    
    self.title = @"自定义alert";
    self.dataText = @"国际在线专稿：据英国《每日邮报》4月5日报道，新西兰一家户外装备品牌日前在澳大利亚举行名为“最狂野粉丝”的竞赛，25岁澳大利亚女子萨姆·米洛杰维奇（Sam Milojevic）为了赢得比赛和价值2000美元（约合人民币12950元）的奖品，竟睡在临时搭在悉尼市最热闹的皮特街（Pitt Street）上空20米的临时帐篷中，令路人大跌眼镜。（杨柳）国际在线专稿：据英国《每日邮报》4月5日报道，新西兰一家户外装备品牌日前在澳大利亚举行名为“最狂野粉丝”的竞赛，25岁澳大利亚女子萨姆·米洛杰维奇（Sam Milojevic）为了赢得比赛和价值2000美元";
    
    UIButton * alertButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    alertButton.frame = CGRectMake(100, 100, 100, 40);
    [alertButton setBackgroundImage:[UIImage imageNamed:@"button_orange_normal"] forState:UIControlStateNormal];
    [alertButton setTitle:@"常规" forState:UIControlStateNormal];
    [alertButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [alertButton addTarget:self action:@selector(alertClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:alertButton];
    
    
    UIButton * customButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(100, 180, 100, 40);
    [customButton setBackgroundImage:[UIImage imageNamed:@"button_orange_normal"] forState:UIControlStateNormal];
    [customButton setTitle:@"加载视图" forState:UIControlStateNormal];
    [customButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [customButton addTarget:self action:@selector(customClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:customButton];
    
    
    UIButton * systemButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    systemButton.frame = CGRectMake(100, 250, 100, 40);
    [systemButton setBackgroundImage:[UIImage imageNamed:@"button_orange_normal"] forState:UIControlStateNormal];
    [systemButton setTitle:@"系统视图" forState:UIControlStateNormal];
    [systemButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [systemButton addTarget:self action:@selector(systemClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:systemButton];
    
    
    
    UIButton * sysButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    sysButton.frame = CGRectMake(100, 320, 100, 40);
    [sysButton setBackgroundImage:[UIImage imageNamed:@"button_orange_normal"] forState:UIControlStateNormal];
    [sysButton setTitle:@"系统" forState:UIControlStateNormal];
    [sysButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [sysButton addTarget:self action:@selector(sysClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sysButton];
    
}

-(void)sysClickAction {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:self.dataText delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"我知道了", nil];
    [alert show];
}

-(void)systemClickAction {
    NSString * texts = @"国际在线专稿为了赢得比赛和价值2000美元（约合人民币12950元）的奖品，竟睡在临时搭在悉尼市最热闹的皮特街（Pitt Street）上空20米的临时帐篷中，令路人大跌眼镜。（杨柳）国际在线专稿：据英国《每日邮报》4月5日报道，新西兰一家户外装备品牌日前在澳大利亚举行名为“最狂野粉丝”的竞赛，25岁澳大利亚女子萨姆·米洛杰维奇（Sam Milojevic）为了赢得比赛和价值2000美元";
    
    HZAlertView * customAlert = [[HZAlertView alloc] initWithSystemTitle:L(@"ActionTitle") message:texts delegate:self cancelButtonTitle:L(@"Cancle") otherButtonTitles:L(@"Sure")];
    
    [customAlert show];
    
    [customAlert setCancelBlock:^{
        NSLog(@"dddddd");
    }];
}



-(void)customClickAction {
    
    UIView * CustomView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 100, 200)];
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 20)];
    titleLabel.text = @"添加信息";
    [CustomView addSubview:titleLabel];
    
//    UITextField * textf = [[UITextField alloc] initWithFrame:CGRectMake(10, 50, 150, 40)];
//    textf.placeholder = @"dddd";
//    textf.borderStyle = UITextBorderStyleRoundedRect;
//    [CustomView addSubview:textf];
    
    
    HZAlertView * customAlert = [[HZAlertView alloc] initWithTitle:nil message:self.dataText customView:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开票"];
    [customAlert show];
}

//******************************************************************************
-(void)alertClickAction {
    HZAlertView * alert = [[HZAlertView alloc] initWithTitle:nil message:@"ddd" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定"];
//    [alert setCancelBlock:^{
//        NSLog(@"---Cancle--");
//    }];
//    [alert setConfirmBlock:^{
//                NSLog(@"---submit--");
//    }];
    [alert show];
}


//-(void)alertView:(HZAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        NSLog(@"1111111");
//    }
//    if (buttonIndex == 0) {
//        NSLog(@"000000");
//    }
//}
//-(void)alertView:(HZAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        NSLog(@"1111111");
//    }
//    if (buttonIndex == 0) {
//        NSLog(@"000000");
//    }
//}
@end
