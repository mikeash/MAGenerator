//
//  MAGenerator.m
//  MAGenerator
//
//  Created by Michael Ash on 10/21/09.
//

#import "MAGenerator.h"


static const void *CopyCleanupBlock(CFAllocatorRef allocator, const void *value)
{
    void (^block)(void) = (void (^)(void))value;
    return [block copy];
}

static void CallCleanupBlockAndRelease(CFAllocatorRef allocator, const void *value)
{
    if(value)
    {
        void (^block)(void) = (void (^)(void))value;
        block();
        [block release];
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
    return [NSMakeCollectable(array) autorelease];
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

- (void)dealloc
{
    [_generator release];
    [super dealloc];
}

- (id)nextObject
{
    return _generator();
}

@end


id <NSFastEnumeration> MAGeneratorEnumerator(id (^generator)(void))
{
    return [[[_MAGeneratorEnumerator alloc] initWithGenerator: generator] autorelease];
}
