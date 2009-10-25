MAGenerator: experimental generator support in Objective-C using blocks
=======================================================================

Introduction
------------
MAGenerator allows easy construction of generators in Objective-C. A generator is essentially a function which remembers its state between calls. A generator uses a 'yield' statement rather than a 'return' statement. When control reaches a 'yield' statement, the generator returns the indicated value, and saves its state. On the next call, execution resumes after the 'yield' statement, rather than at the top.

Generators can allow for "inside out" programming, lazy evaluation, and asynchronous state machines, while preserving a natural top-to-bottom flow of code.


How to Make Generators
----------------------

To create a generator using MAGenerator, start with the GENERATOR macro. The first parameter to this macro is the return type of the generator, which is what it returns on each call. The second parameter is the name of the generator creation function as well as the parameters that it takes, combined using function-declaration syntax. The third parameter is the parameters that the generator itself takes on each call. This is a bit confusing, so here are some examples.

This is an example of the start of a generator which takes a single parameter for the generator creation function, and no parameters for the generator itself:

    GENERATOR(int, Counter(int start), (void))

Here's one which takes two parameters for each:

    GENERATOR(int, Counter(int start, int end), (NSString *label, NSString *name))

Note that the generator must return some sort of value. Void is not allowed. If you don't want to return anything, then pick a reasonable type, like int, and then yield a reasonable value, like 0 when you wish to yield.

Follow the GENERATOR line with local variable declarations. Because of how generators are implemented, local variables MUST be declared here, and not inline with the code. (Doing so will cause their values to be forgotten, with potentially disastrous and hard-to-debug results.) Because generators are implemented using blocks, any local variable which you wish to mutate must be declared with the __block qualifier. Locals may have initializers; they will execute when the generator is created, and can use the generator creator's parameters if needed.

After declaring your local variables, if any, use the GENERATOR_BEGIN macro to start writing the generator code. The parameters to this are the parameters to the generator itself, and must match the third parameter passed to the GENERATOR macro.

Within the body of the generator, you can mostly write code like usual. Use the GENERATOR_YIELD macro to yield values. When yielding, control returns to the caller, and the caller receives the value passed to it. If and when the caller calls your generator again, control resumes after that GENERATOR_YIELD. When control resumes, local variables have the same value that they did previously, and generator parameters contain whatever the caller passed to the generator on the latest call.

If you allow execution to "fall off the bottom" of a generator, the generator will yield 0 (or its equivalent for non-integer types; the generator macros simply zero-fill the return value) and execution on the next invocation, if any, resumes at the top of the generator.

You must avoid switch statements and for/in loops (regular for loops and other loops are fine) which contain GENERATOR_YIELD invocations. Switch statements don't work because the generator mechanism is implemented using a switch statement, and it interferes. For/in loops involve implicit local variables (to hold the loop state) which will not be preserved across yields. The compiler will not warn about these in most cases, so beware.

After the body of the generator, you can optionally use GENERATOR_CLEANUP to begin a cleanup block. A cleanup block is executed when the generator block is deallocated. The main purpose of the cleanup block is to manage the memory of __block-qualified object pointers. The compiler will not automatically retain and release __block-qualified object pointer variables, you must do this yourself. Furthermore, it's a bad idea to store autoreleased objects in such variables across yields, because the caller could surround each call to your generator with an autorelease pool. You need to retain these objects (and release them when you reassign them), but you also need to release them when the generator is destroyed, because you can't guarantee that the caller will invoke your generator enough to make it get to the end. (If it even has an end; many generators simply loop forever.)

Here's how this sort of thing would look:

    __block NSString *str = nil;
    GENERATOR_BEGIN(void)
    {
        ...
        [str release];
        str = [[NSString alloc] initWith...];
        ...
    }
    GENERATOR_CLEANUP
    {
        [str release];
    }

Of course the cleanup block can do whatever else may be needed to clean things up as well, such as calling free() on other allocated memory, closing file descriptors, etc. In general, any code that must execute after the last call to the generator block goes here.

Finally, terminate the generator with GENERATOR_END. You'll know you forgot this part when the compiler starts complaining to you about not supporting nested functions in the code that follows your generator.

If you need a prototype for your generator, for use in a header file, use the GENERATOR_DECL macro. This macro takes the same parameters as the GENERATOR macro, but will produce output suitable for a function prototype declaration for a header file.


How to Use Generators
---------------------

The GENERATOR macro defines a function which creates a new instance of the generator. Generators are just blocks. As such, you declare a variable to hold them using standard block syntax, and manage their memory just like any other Objective-C object. Examples:

    int (^counter)(void) = Counter(42);
    [_counterIvar release];
    _counterIvar = [counter copy];

To call a generator, just use the standard block call syntax, since they actually are blocks:

    int nextValue = counter();

How to actually use any particular generator will depend on what it does, of course.

Generators which return objects and take no parameters can be thought of as enumerators. Calling the generator gets the next object. Returning nil will generally be a signal to stop. To make this usage more convenient, MAGenerator provides the MAGeneratorEnumerator function. This takes such a generator and returns an object conforming to NSFastEnumeration which wraps that generator. The result can then be used as the target of a for/in loop.

For example, take this generator declaration:

    GENERATOR_DECL(id, EnumerateObjects(id inSomething), (void));

You can use this generator in a for/in loop like so:

    for(id obj in MAGeneratorEnumerator(EnumerateObjects(something)))
        ...do something with obj...


Caveats
-------

MAGenerator twists the Objective-C language in various ways, so there are certain things that are just fine in normal Objective-C that don't quite work right inside a generator.

1) I said this above, but it bears repeating. Local variables declared after GENERATOR_BEGIN will not remember their values across invocations of GENERATOR_YIELD. If you declare local variables within the generator body, ensure that the entire lifetime of their usage does not include any invocations of GENERATOR_YIELD. To be safer, only declare local variables above GENERATOR_BEGIN.

2) Because of (1), it's not safe to use a for/in loop inside the generator body unless it doesn't contain any GENERATOR_YIELD invocations.

3) Because the generator macros use a switch statement internally to control execution flow, any switch statements you write explicitly must not contain any GENERATOR_YIELD invocations. (GENERATOR_YIELD generates case: labels which will end up associated with the inner switch statement if used this way.)

4) GENERATOR_YIELD makes use of the __LINE__ macro to generate unique case: labels. Because of this, you can't have more than one invocation of GENERATOR_YIELD on the same line.

5) When assigning to a __block-qualified object pointer local variable from within the generator block, you can't assume anything about the surrounding autorelease environment or future calls to the generator once you yield. As such, the object must be retained when assigning, and you must write a cleanup block that releases it.


Examples
--------

This stuff is weird at first, especially if you've never seen generators or coroutines in other languages before. The GeneratorTests.m file contains many examples, from simple counters to complicated parsers.


License
-------

MAGenerator is released under an MIT license. For the full, legal license, see the LICENSE file. Use in any and every sort of project is encouraged, as long as the terms of the license are followed (and they're easy!).


Further Reading
---------------

For more information about coroutines and generators, Wikipedia is a decent resource:

- http://en.wikipedia.org/wiki/Coroutine
- http://en.wikipedia.org/wiki/Generator_(computer_science)

MAGenerator was inspired by a similar system for making coroutines in C. Reading through the author's discussion may be help illustrate why MAGenerator is made the way it is:

- http://www.chiark.greenend.org.uk/~sgtatham/coroutines.html

Python is a well known language which makes much use of generators. Much of what can be found on the web about Python generators will apply, to greater or lesser degrees, to MAGenerator as well.

Finally, my Friday Q&A article about MAGenerator discusses its construction and use in greater detail:

- http://www.mikeash.com/?page=pyblog/friday-qa-2009-10-30-generators-in-objective-c.html


Authorship
----------

MAGenerator is written by Mike Ash. For questions about the code or to contribute patches, contact mike@mikeash.com.
