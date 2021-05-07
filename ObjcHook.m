//
//  ObjcHook.m
//  ObjcHook
//
//  Created by 牛富贵 on 2021/5/5.
//  Copyright © 2021 牛富贵. All rights reserved.
//

#import "ObjcHook.h"
#import <objc/runtime.h>

@implementation ObjcHook

@end

@implementation NSObject (ObjcHook)

/// 只能对象使用
- (void)obj_hookSelector:(SEL)selector usingBlock:(id)block {
    /// 创建子类
    Class baseClass = object_getClass(self);
    NSString *className = NSStringFromClass(baseClass);
    const char *subclassName = [className stringByAppendingString:@"_OBJHook_"].UTF8String;
    Class subclass = objc_getClass(subclassName);
    subclass = objc_allocateClassPair(baseClass, subclassName, 0);
    

    /// 注册子类
    objc_registerClassPair(subclass);
    
    /// 获取该类要 hook 的方法
    Method targetMethod = class_getInstanceMethod(subclass, selector);
    /// 获取要hook方法的签名
    const char *typeEncoding = method_getTypeEncoding(targetMethod);
    /// 获取添加了前缀的方法名
    SEL aliasSelector = NSSelectorFromString([@"objhook_" stringByAppendingFormat:@"_%@", NSStringFromSelector(selector)]);
    /// 添加方法然后 replace
    class_addMethod(subclass, aliasSelector, method_getImplementation(targetMethod), typeEncoding);
    //在返回的新类上的原方法上hook进行消息转发
}

//此targetSelector属于被hook对象的类
- (void)obj_hookSelector:(SEL)sel usingSelector:(SEL)targetSelector {
    [self obj_hookSelector:sel usingSelector:targetSelector fromClass:self.class];
}

//此targetSelector属于selCls类
- (void)obj_hookSelector:(SEL)sel usingSelector:(SEL)targetSelector fromClass:(Class)selCls {
    //self来自objc_msgSend的第一个默认参数
    Class originalCls = self.class;
    const char *originalClsName = class_getName(originalCls);
    //以对象地址作为类名的一部分，防止同一类的多个对象都isa混写时，指向了同一个新类
    NSString *newClsName = [NSString stringWithFormat:@"OBJHook_%s_%p",originalClsName,self];
    Class cls = NSClassFromString(newClsName);
    if(cls == nil) {
        //创建新类实例
        cls = objc_allocateClassPair(originalCls, newClsName.UTF8String, 0);
        //注册新类
        objc_registerClassPair(cls);
    }
    if(cls == NULL) return;
    //对.clss方法隐藏新类
    SEL clsSel = @selector(class);
    IMP clsImp = imp_implementationWithBlock((Class)^{ return originalCls; });
    const char *types = method_getTypeEncoding(class_getInstanceMethod(NSObject.class, clsSel));
    class_addMethod(cls, clsSel, clsImp, types);
    //给新类添加原方法
    SEL originalSel = sel;
    SEL targetSel = targetSelector;
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method targetMethod = class_getInstanceMethod(selCls, targetSel);
    BOOL didAddMethod = class_addMethod(cls, originalSel, method_getImplementation(targetMethod), method_getTypeEncoding(targetMethod));
    //在新类上把原方法实现也加上，利用method swizzling来保存原实现
    if(didAddMethod) {
        class_replaceMethod(cls, targetSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, targetMethod);
    }

    object_setClass(self, cls);
}

@end
