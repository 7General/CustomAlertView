
## HZAlertView
  * An easy way to use PUSH-ALERT-VIEW
  * 自定义的AlertView展示，和其他的几种展现方式（纯手工打造）
  * 用法简单的alert框架：一行代码搞定

## 效果图

  <img align="left" src="https://mmbiz.qlogo.cn/mmbiz/wFa30ADx7kLq0OYsfiacaDw1bZicnlnjticFD8SibSLSPicmorpT2klAc7nAv5hS441icHGhLOU7zdJlM4JIXmRgF7pQ/0?wx_fmt=gif" alt="建议使用" width="240" height="427"/>
  <img align="center" src="https://mmbiz.qlogo.cn/mmbiz/wFa30ADx7kLq0OYsfiacaDw1bZicnlnjticZn4elHLpJeHtsjpNwK6xyg6uWtzp9cnJgjYk40GOF8srUhMxJCxnzw/0?wx_fmt=gif" alt="模仿使用" width="240" height="427"/>
  <img align="right" src="https://mmbiz.qlogo.cn/mmbiz/wFa30ADx7kLq0OYsfiacaDw1bZicnlnjticTeKwpVfeibl77iaonMTIACtb38kiclJq3u3xYLVZhw9r5luqGgkDKzkWA/0?wx_fmt=jpeg" alt="项目结构" width="240" height="427"/>


更多消息
* 更多App信息可以关注：[洲洲哥](https://mmbiz.qlogo.cn/mmbiz/wFa30ADx7kLiboiaPKbKSTypo5VSAOShxYUf5zZ4JgQqadyy8J6GzHFvfAYicu5F8Ew0ngVibRM8qcaSxtjyX3blPA/0?wx_fmt=jpeg)

## <a id="如何使用HZAlertView"></a>如何使用HZAlertView

* 使用之前请添加代理[HZAlertViewDelegate]

* 测试文本消息
```objective-c
NSString * texts = @"国际在线专稿为了赢得比赛和价值2000美元（约合人民币12950元）的奖品，竟睡在临时搭在悉尼市最热闹的皮特街（Pitt Street）上空20米的临时帐篷中，令路人大跌眼镜。（杨柳）国际在线专稿：据英国《每日邮报》4月5日报道，新西兰一家户外装备品牌日前在澳大利亚举行名为“最狂野粉丝”的竞赛，25岁澳大利亚女子萨姆·米洛杰维奇（Sam Milojevic）为了赢得比赛和价值2000美元";
```

* 弹出AlertView

```objective-c
    HZAlertView * customAlert = [[HZAlertView alloc] initWithSystemTitle:L(@"ActionTitle") message:texts delegate:self cancelButtonTitle:L(@"Cancle") otherButtonTitles:L(@"Sure")];
    
    [customAlert show];
```

### Block 处理点击事件

取消事件（cancelButton）
```objc
[customAlert setCancelBlock:^{
        NSLog(@"取消");
    }];
```
确认事件（othersButton）
```objc
[alert setConfirmBlock:^{
                NSLog(@"---确认--");
    }];
```
### Delegate 代理处理点击事件

```objc
-(void)alertView:(HZAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"1111111");
    }
    if (buttonIndex == 0) {
        NSLog(@"000000");
    }
}
-(void)alertView:(HZAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"1111111");
    }
    if (buttonIndex == 0) {
        NSLog(@"000000");
    }
}
```
