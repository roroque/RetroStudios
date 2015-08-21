//
//  DropDownItem.h
//  Power Pong
//
//  Created by Elias Ayache on 21/08/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropDownItem : UIControl

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) id object;
@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong, readonly) UILabel *textLabel;

@property (nonatomic, assign) CGFloat paddingLeft;

- (id)copyWithZone:(NSZone *)zone;

@end
