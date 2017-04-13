//
//  NSString+Category.m
//  ZHBasedFrameWork
//
//  Created by 曾浩 on 2017/1/9.
//  Copyright © 2017年 zenghao. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

/**
 *  去掉首尾空字符串
 */
- (NSString *)replaceSpaceOfHeadTail
{
    NSMutableString *string = [[NSMutableString alloc] init];
    [string setString:self];
    CFStringTrimWhitespace((CFMutableStringRef)string);
    return string;
}

- (NSString *)replaceUnicode
{
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80);
    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:strEncode];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
    
}

/**
 获取缓存路径
 
 @return 将当前字符串拼接到cache目录后面
 */
- (NSString *)cacheDic
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [path stringByAppendingPathComponent:self.lastPathComponent];
}

/**
 获取document路径
 
 @return 将当前字符串拼接到document目录后面
 */
- (NSString *)docDic
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [path stringByAppendingPathComponent:self.lastPathComponent];
}

/**
 获取tmp路径
 
 @return 将当前字符串拼接到tmp目录后面
 */
- (NSString *)tmpDic
{
    NSString *path = NSTemporaryDirectory();
    
    return [path stringByAppendingPathComponent:self.lastPathComponent];
}

@end
