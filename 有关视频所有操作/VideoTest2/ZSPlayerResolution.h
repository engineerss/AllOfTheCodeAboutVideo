//
//  ZSPlayerResolution.h
//  VideoTest2
//
//  Created by zs mac on 16/9/20.
//  Copyright © 2016年 zs mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSPlayerResolution : NSObject
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, copy  ) NSString  *name;
@property (nonatomic, copy  ) NSString  *type;
@property (nonatomic, copy  ) NSString  *url;
@end
