//
//  AllInPay.m
// 
//
//  Created by FengZi on 2017/3/29.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "AllInPay.h"

@implementation AllInPay
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(pay:(NSString *)payDataInfo)
{
  //订单数据
  //  NSString *payData = [PaaCreater randomPaa];
  //@param mode
  //00 生产环境
  //01 测试环境
  //在测试与生产环境之间切换的时候请注意修改mode参数
  NSData *jsonData = [payDataInfo dataUsingEncoding:NSUTF8StringEncoding];
  NSError *err;
  NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                      options:NSJSONReadingMutableContainers
                                                        error:&err];
    __block UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
  
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    [APay startPay:payDataInfo viewController:rootVC delegate:self mode:@"00"];
    
    
  });
}

- (void)payResultSendEvent:(id)parameter
{
  [self sendEventWithName:@"allInPay" body:@{@"result":parameter}];

}
- (NSArray<NSString *> *)supportedEvents
{
  return @[@"allInPay"];//有几个就写几个
}
- (void)APayResult:(NSString *)result {
  
  NSLog(@"%@", result);
  NSArray *parts = [result componentsSeparatedByString:@"="];
  NSError *error;
  NSData *data = [[parts lastObject] dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
  NSInteger payResult = [dic[@"payResult"] integerValue];
  NSString *format_string = @"支付结果::支付%@";
  if (payResult == APayResultSuccess) {
    
    [self payResultSendEvent:@"success"];

  } else if (payResult == APayResultFail) {
    [self payResultSendEvent:@"fail"];
    
  } else if (payResult == APayResultCancel) {
    [self payResultSendEvent:@"cancel"];
  }
  
  NSLog(format_string,@"%@",payResult);

}
@end
