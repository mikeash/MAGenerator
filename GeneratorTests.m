//
//  GeneratorTests.m
//  MAGenerator
//
//  Created by Michael Ash on 10/21/09.
//

#import "MAGenerator.h"


GENERATOR(int, Primes(void), (void))
{
    __block int n;
    __block int i;
    GENERATOR_BEGIN(void)
    {
        for(n = 2; ; n++)
        {
            for(i = 2; i < n; i++)
                if(n % i == 0)
                    break;
            if(i == n)
                GENERATOR_YIELD(n);
        }
    }
    GENERATOR_END
}

GENERATOR(NSArray *, ArrayBuilder(void), (id obj))
{
    __block NSMutableArray *array = nil;
    GENERATOR_BEGIN(id obj)
    {
        array = [[NSMutableArray alloc] init];
        for(;;)
            if(obj)
            {
                [array addObject: obj];
                GENERATOR_YIELD((NSArray *)array);
            }
    }
    GENERATOR_CLEANUP
    {
        NSLog(@"Cleaning up");
        [array release];
    }
    GENERATOR_END
}

GENERATOR(NSString *, WordParser(void), (unichar ch))
{
    NSMutableString *buffer = [NSMutableString string];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    GENERATOR_BEGIN(unichar ch)
    {
        for(;;)
        {
            if(ch == 0 || [whitespace characterIsMember: ch])
            {
                GENERATOR_YIELD([buffer length] ? (NSString *)buffer : nil);
                [buffer setString: @""];
            }
            else
            {
                [buffer appendFormat: @"%C", ch];
                GENERATOR_YIELD((NSString *)nil);
            }
        }
    }
    GENERATOR_END
}

int main(int argc, char **argv)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int (^primes)(void) = Primes();
    for(int i = 0; i < 10; i++)
        NSLog(@"%d", primes());
    
    NSArray *(^builder)(id) = ArrayBuilder();
    NSLog(@"%@", builder(@"hello"));
    NSLog(@"%@", builder(@"world"));
    NSLog(@"%@", builder(@"how"));
    NSLog(@"%@", builder(@"are"));
    NSLog(@"%@", builder(@"you?"));
    
    NSString *(^wordParser)(unichar ch) = WordParser();
    NSLog(@"%@", wordParser('h'));
    NSLog(@"%@", wordParser('e'));
    NSLog(@"%@", wordParser('l'));
    NSLog(@"%@", wordParser('l'));
    NSLog(@"%@", wordParser('o'));
    NSLog(@"%@", wordParser(' '));
    NSLog(@"%@", wordParser('w'));
    NSLog(@"%@", wordParser('o'));
    NSLog(@"%@", wordParser('r'));
    NSLog(@"%@", wordParser('l'));
    NSLog(@"%@", wordParser('d'));
    NSLog(@"%@", wordParser('!'));
    NSLog(@"%@", wordParser(0));
    
    [pool release];
    
    return 0;
}
