//
//  ViewController.m
//  ObjcHook
//
//  Created by 牛富贵 on 2021/5/5.
//  Copyright © 2021 牛富贵. All rights reserved.
//

#import "ViewController.h"
#import "ObjcHook.h"
#import "TestClass.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    TestClass *objA = [TestClass new];
    [objA obj_hookSelector:@selector(printABC) usingSelector:@selector(objAPrint)];
    TestClass *objB = [TestClass new];
    [objB obj_hookSelector:@selector(printABC) usingSelector:@selector(objBPrint) fromClass:self.class];
    TestClass *objC = [TestClass new];
    
    NSLog(@"--%@",[objA class]);
    [objA printABC];
    [objB printABC];
    [objC printABC];
}

- (void)objBPrint {
    NSLog(@"BBB");
}

- (void)testBlock {
    void(^block1)(void) = ^{
        NSLog(@"block1");
    };

    /// 如何通过NSInvocation来执行一个block，关键就在于获取block的方法签名
    NSMethodSignature *sign = [self blockSignature:block1];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sign];
    invocation.target = block1;
    [invocation invoke]; // 输出block1
}

- (NSMethodSignature *)blockSignature:(id)block {
    const char *sign = _Block_signature((__bridge void *)block);
    return [NSMethodSignature signatureWithObjCTypes:sign];
}

static struct Block_descriptor_3 * _Block_descriptor_3(struct Block_layout *aBlock)
{
    if (! (aBlock->flags & BLOCK_HAS_SIGNATURE)) return NULL;
    uint8_t *desc = (uint8_t *)aBlock->descriptor;
    desc += sizeof(struct Block_descriptor_1);
    if (aBlock->flags & BLOCK_HAS_COPY_DISPOSE) {
        desc += sizeof(struct Block_descriptor_2);
    }
    return (struct Block_descriptor_3 *)desc;
}

// Checks for a valid signature, not merely the BLOCK_HAS_SIGNATURE bit.
BLOCK_EXPORT
bool _Block_has_signature(void *aBlock) {
    return _Block_signature(aBlock) ? true : false;
}

BLOCK_EXPORT
const char * _Block_signature(void *aBlock)
{
    struct Block_descriptor_3 *desc3 = _Block_descriptor_3(aBlock);
    if (!desc3) return NULL;

    return desc3->signature;
}

作者：超越杨超越
链接：https://juejin.cn/post/6844904061557293069
来源：掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

@end
