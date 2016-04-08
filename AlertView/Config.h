//
//  Config.h
//  AlertView
//
//  Created by 王会洲 on 16/4/7.
//  Copyright © 2016年 王会洲. All rights reserved.
//

#ifndef Config_h
#define Config_h

// ***********模拟系统界面
// 系统界面宽度
#define SYSALERTWIDTH 270
// 距离左右间距
#define SYSALERTPADDING 15
// 系统内容宽度 =  alet宽度 - （左边距 + 右边距）
#define SYSCONTENTWIDTH (SYSALERTWIDTH - (SYSALERTPADDING * 2))
#define SYSBUTTONFONT [UIFont systemFontOfSize:20.0f]




// 系统底部按钮高度
#define buttonPartHeight 44

// 基本弹出框宽度
#define BASICALERTWIDTH 260
// 基本弹出框内容宽度
#define BASICCONTENTWIDTH 220

#define TITLEFONT [UIFont systemFontOfSize:20.0f]
#define CONTENTFONT [UIFont systemFontOfSize:16.0f]
#define BBAlertLeavel  300

#define YSColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define leftBtnImage        [UIImage imageNamed:@"button_white_normal.png"]
#define rightBtnImage       [UIImage imageNamed:@"button_orange_normal.png"]

#endif /* Config_h */
