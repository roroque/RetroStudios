//
//  DropDownMenu.h
//  Power Pong
//
//  Created by Elias Ayache on 21/08/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownItem.h"
@class DropDownMenu;

typedef NS_ENUM(NSUInteger, DropDownMenuRotate) {
    DropDownMenuRotateNone,
    DropDownMenuRotateLeft,
    DropDownMenuRotateRight,
    DropDownMenuRotateRandom
};

typedef NS_ENUM(NSUInteger, DropDownMenuType) {
    DropDownMenuTypeNormal,
    DropDownMenuTypeStack,
    DropDownMenuTypeSlidingInBoth,
    DropDownMenuTypeSlidingInFromLeft,
    DropDownMenuTypeSlidingInFromRight
};

typedef NS_ENUM(NSUInteger, DropDownMenuDirection) {
    DropDownMenuDirectionDown,
    DropDownMenuDirectionUp,
    DropDownMenuDirectionRight,
    DropDownMenuDirectionLeft
};

@protocol DropDownMenuDelegate <NSObject>

- (void)dropDownMenu:(DropDownMenu*)dropDownMenu selectedItemAtIndex:(NSInteger)index;

@end

@interface DropDownMenu : UIControl

@property (nonatomic, strong, readonly) DropDownItem *menuButton;
@property (nonatomic, copy) NSString* menuText;
@property (nonatomic, strong) id object;
@property (nonatomic, strong) UIImage *menuIconImage;
@property (nonatomic, copy) NSArray* dropDownItems;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign, readonly) NSInteger selectedIndex;

@property (nonatomic, assign) CGFloat paddingLeft;

@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) UIViewAnimationOptions animationOption;
@property (nonatomic, assign) CGFloat itemAnimationDelay;
@property (nonatomic, assign) DropDownMenuRotate rotate;
@property (nonatomic, assign) DropDownMenuType type;
@property (nonatomic, assign) DropDownMenuDirection direction;
@property (nonatomic, assign) CGFloat slidingInOffset;
@property (nonatomic, assign) CGFloat gutterY;
@property (nonatomic, assign) CGFloat alphaOnFold;
@property (nonatomic, assign, getter = isExpanding) BOOL expanding;
@property (nonatomic, assign, getter = shouldFlipWhenToggleView) BOOL flipWhenToggleView;
@property (nonatomic, assign, getter = shouldUseSpringAnimation) BOOL useSpringAnimation;

@property (nonatomic, assign) id<DropDownMenuDelegate> delegate;

- (void)reloadView;
- (void)resetParams;
- (void)selectItemAtIndex:(NSUInteger)index;
- (void)addSelectedItemChangeBlock:(void (^)(NSInteger selectedIndex))block;
- (void)toggleView;

@end
