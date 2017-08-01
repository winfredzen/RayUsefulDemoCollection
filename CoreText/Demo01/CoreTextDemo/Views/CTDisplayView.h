//
//  CTDisplayView.h
//  CoreTextDemo
//
//  Created by TangQiao on 13-12-7.
//  Copyright (c) 2013年 TangQiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextData.h"

extern NSString *const CTDisplayViewImagePressedNotification;
extern NSString *const CTDisplayViewLinkPressedNotification;

/**
 CTDisplayView类，持有CoreTextData类的实例，负责将CTFrameRef绘制到界面上
 */
@interface CTDisplayView : UIView

@property (strong, nonatomic) CoreTextData * data;

@end
