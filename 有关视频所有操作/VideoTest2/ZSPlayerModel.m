//
//  ZSPlayerModel.m
//  VideoTest2
//
//  Created by zs mac on 16/9/20.
//  Copyright © 2016年 zs mac. All rights reserved.
//
#import "ZSPlayerResolution.h"
#import "ZSPlayerModel.h"

@implementation ZSPlayerModel
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"description"]) {
        self.video_description = [NSString stringWithFormat:@"%@",value];
    }
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"playInfo"]) {
        self.playInfo = @[].mutableCopy;
        NSMutableArray *array = @[].mutableCopy;
        
        for (NSDictionary *dataDic in value)
        {
            ZSPlayerResolution *resolution = [[ZSPlayerResolution alloc]init];
            
            [resolution setValuesForKeysWithDictionary:dataDic];
            [array addObject:resolution];
            
            
        }
        
        [self.playInfo removeAllObjects];
        [self.playInfo addObjectsFromArray:array];
        
    }else if ([key isEqualToString:@"title"])
    {
        self.title = value;
    }else if ([key isEqualToString:@"playUrl"])
    {
        self.playUrl = value;
    }else if ([key isEqualToString:@"coverForFeed"])
    {
        self.coverForFeed = value;
    }
}








@end
