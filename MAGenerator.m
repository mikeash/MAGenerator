//
//  MAGenerator.m
//  MAGenerator
//
//  Created by Michael Ash on 10/21/09.
//

#import "MAGenerator.h"


static const void *CopyCleanupBlock(CFAllocatorRef allocator, const void *value)
{
    return Block_copy(value);
}

static void CallCleanupBlockAndRelease(CFAllocatorRef allocator, const void *value)
{
    if(value)
    {
        ((__bridge void (^)(void))value)();
		Block_release(value);
    }
}

static CFArrayCallBacks gCleanupCallbacks = {
    0, // version
    CopyCleanupBlock, // retain
    CallCleanupBlockAndRelease, // release
    NULL, // description
    NULL // equal
};

NSMutableArray *MAGeneratorMakeCleanupArray(void)
{
    CFMutableArrayRef array = CFArrayCreateMutable(NULL, 1, &gCleanupCallbacks);
    return CFBridgingRelease(array);
}


@interface _MAGeneratorEnumerator : NSEnumerator
{
    id (^_generator)(void);
}
- (id)initWithGenerator: (id (^)(void))generator;
@end

@implementation _MAGeneratorEnumerator

- (id)initWithGenerator: (id (^)(void))generator
{
    if((self = [self init]))
        _generator = [generator copy];
    return self;
}

- (id)nextObject
{
    return _generator();
}

@end


id <NSFastEnumeration> MAGeneratorEnumerator(id (^generator)(void))
{
    return [[_MAGeneratorEnumerator alloc] initWithGenerator: generator];
}
