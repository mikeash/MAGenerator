//
//  MAGenerator.m
//  MAGenerator
//
//  Created by Michael Ash on 10/21/09.
//

#import "MAGenerator.h"


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
    NULL, // retain
    CallCleanupBlockAndRelease, // release
    NULL, // description
    NULL // equal
};

NSMutableArray *MAGeneratorMakeCleanupArray(void)
{
    CFMutableArrayRef array = CFArrayCreateMutable(NULL, 1, &gCleanupCallbacks);
    return [NSMakeCollectable(array) autorelease];
}
