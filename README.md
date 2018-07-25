StaticDictionary.jl
===================

This is a very small package providing a facility for, well, a static
dictionary "data structure". I'll explain why the quotes in a moment. By a
"static dictionary" I mean that it is immutable, and the result of any operation
on the dictionary can, in principle, be determined by the compiler at the call
site.

The purpose of this "data structure" is to provide very fast lookup when there
is a small set of keys (and potential keys that you will try to look up!), and
a lookup table is to be constructed once and then used frequently. It is *not*
a general purpose dictionary, as operations to construct the dictionary or
insert items are quite slow due to significant abuse of Julia's type system.
What it *does* do well is extremely efficient observing operations once a
dictionary has been constructed. `keys`, `values`, `haskey`, and `getindex` are
all constant time operations with a nearly inobservable execution time, up to a
given size where the compiler's type inference hits a recursion limit. This size
is different for different operations and I haven't determined what exactly it
is.

I call this a "data structure" because there are not any data members stored; a
static dictionary is encoded as a singleton type `StaticDict{K, V, C}()` where
`K => V` is a key, value pair and `C` is either a `StaticDict`, if there are
more members, or `Nothing` if there are not. Operations operate on types; e.g.
the base signature for `getindex` is
`getindex(::Type{StaticDict{parameters...}}, ::Val{k})`. Up to the compiler's
recursion limit, this method will simply compile down to return a constant.
The more convenient interface `getindex(::D, k) where D<:StaticDict` simply
calls `getindex(D, Val{k})`, and the compiler is able to optimize the dynamic
creation of the type `Val{k}`.

From the description above you can probably see the performance gotcha - every
key that is looked up and every possible ordering of key, value pairs results
in a new method, so first time operations are expensive. After the first time,
however, operations are extremely fast. This fits the use case for which I
developed the structure.

Limitations: obviously you can only store keys and values that can be used as
type parameters - that is, `isbits` types and `Symbol`s. Also, because the
singleton type `StaticDict{Nothing, Nothing, Nothing}()` is used to represent
an empty dictionary, storing a key, value pair `Nothing => Nothing` will
probably result in strange behavior. However, I don't envision this probably
being an issue.

@TODO: Add usage examples here, and benchmarks once I write them to track
possible regressions on nightly.
