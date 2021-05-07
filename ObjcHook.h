//
//  ObjcHook.h
//  ObjcHook
//
//  Created by 牛富贵 on 2021/5/5.
//  Copyright © 2021 牛富贵. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjcHook : NSObject

@end

@interface NSObject (ObjcHook)

- (void)obj_hookSelector:(SEL)selector usingBlock:(id)block;

- (void)obj_hookSelector:(SEL)sel usingSelector:(SEL)targetSelector;

- (void)obj_hookSelector:(SEL)sel usingSelector:(SEL)targetSelector fromClass:(Class)selCls;

@end

NS_ASSUME_NONNULL_END
