//
//  MAGenerator.h
//  MAGenerator
//
//  Created by Michael Ash on 10/21/09.
//

#import <Foundation/Foundation.h>


#define GENERATOR_DECL(returnType, nameAndCreationParams, perCallParams) \
    returnType (^nameAndCreationParams) perCallParams

#define GENERATOR(returnType, nameAndCreationParams, perCallParams) \
    returnType (^nameAndCreationParams) perCallParams \
    { \
        returnType GENERATOR_zeroReturnValue; \
        bzero(&GENERATOR_zeroReturnValue, sizeof(GENERATOR_zeroReturnValue)); \
        returnType (^GENERATOR_cleanupBlock)(void) = nil;

#define GENERATOR_BEGIN(...) \
        __block int GENERATOR_where = -1; \
        NSMutableArray *GENERATOR_cleanupArray = MAGeneratorMakeCleanupArray(); \
        id GENERATOR_mainBlock = ^ (__VA_ARGS__) { \
            [GENERATOR_cleanupArray self]; \
            switch(GENERATOR_where) \
            { \
                case -1:

#define GENERATOR_YIELD(...) \
                    do { \
                        GENERATOR_where = __LINE__; \
                        return __VA_ARGS__; \
                case __LINE__: ; \
                    } while(0)

#define GENERATOR_CLEANUP \
            } \
            GENERATOR_where = -1; \
            return GENERATOR_zeroReturnValue; \
        }; \
        GENERATOR_cleanupBlock = ^{{
        
#define GENERATOR_END \
            } \
            GENERATOR_where = -1; \
            return GENERATOR_zeroReturnValue; \
        }; \
        if(GENERATOR_cleanupBlock) \
            [GENERATOR_cleanupArray addObject: ^{ GENERATOR_cleanupBlock(); }]; \
        return [GENERATOR_mainBlock copy]; \
    }



NSMutableArray *MAGeneratorMakeCleanupArray(void);
id <NSFastEnumeration> MAGeneratorEnumerator(id (^generator)(void));
