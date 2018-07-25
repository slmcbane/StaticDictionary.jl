__precompile__()

module StaticDictionary

export StaticDict, additem

import Base: keys, values, getindex, haskey
using Base: @pure

struct StaticDict{K, V, C}
    @inline @pure StaticDict{K, V}() where {K, V} = new{K, V, Nothing}()
    @inline @pure StaticDict{K, V}(::Type{C}) where {K, V} where C <: StaticDict = haskey(C, Val{K}) ? additem(C, Pair{Val{K}, Val{V}}) : new{K, V, C}()
    @inline @pure StaticDict{K, V}(::C) where {K, V} where C <: StaticDict = StaticDict{K, V}(C)
    @inline @pure StaticDict{K, V, Nothing}() where {K, V} = StaticDict{K, V}()
    @inline @pure StaticDict{K, V, C}() where {K, V, C} = StaticDict{K, V}(C)
end

@inline @pure StaticDict(::Type{Val{K}}, ::Type{Val{V}}) where K where V = StaticDict{K, V}()
@inline @pure StaticDict(::Type{Pair{Val{K}, Val{V}}}) where K where V = StaticDict{K, V}()
@inline @pure StaticDict(::Type{Pair{Val{K}, Val{V}}}, kvs::DataType...) where {K, V} = StaticDict{K, V}(StaticDict(kvs...))
@inline @pure StaticDict(k, v) = StaticDict(Val{k}, Val{v})
@inline @pure StaticDict(kv::Pair) = StaticDict(Val{kv[1]}, Val{kv[2]})
@inline @pure StaticDict(kv::Pair, kvs::Pair...) = additem(StaticDict(kvs...), kv)
@inline @pure StaticDict() = StaticDict{Nothing, Nothing, Nothing}()

@inline @pure keys(::Type{StaticDict{Nothing, Nothing, Nothing}}) = ()
@inline @pure keys(::Type{StaticDict{K, V, Nothing}}) where {K, V} = (K,)
@inline @pure keys(::Type{StaticDict{K, V, C}}) where {K, V} where C <: StaticDict = tuple_cat((K,), keys(C()))
@inline @pure keys(::C) where C <: StaticDict = keys(C)

@inline @pure values(::Type{StaticDict{Nothing, Nothing, Nothing}}) = ()
@inline @pure values(::Type{StaticDict{K, V, Nothing}}) where {K, V} = (V,)
@inline @pure values(::Type{StaticDict{K, V, C}}) where {K, V} where C <: StaticDict = tuple_cat((V,), values(C()))
@inline @pure values(::C) where C <: StaticDict = values(C)

@inline @pure getindex(::Type{StaticDict{Nothing, Nothing, Nothing}}, k) = nothing
@inline @pure getindex(::Type{StaticDict{K, V, Nothing}}, ::Type{Val{K}}) where {K, V} = V
@inline @pure getindex(::Type{StaticDict{K, V, Nothing}}, ::Type{Val{N}}) where {K, V, N} = nothing
@inline @pure getindex(::Type{StaticDict{K, V, C}}, ::Type{Val{K}}) where {K, V} where C <: StaticDict = V
@inline @pure getindex(::Type{StaticDict{K, V, C}}, ::Type{Val{N}}) where {K, V, N} where C <: StaticDict = getindex(C, Val{N})
@inline @pure getindex(::C, k) where C <: StaticDict = getindex(C, Val{k})

@inline @pure haskey(::Type{StaticDict{Nothing, Nothing, Nothing}}, k) = false
@inline @pure haskey(::Type{StaticDict{K, V, Nothing}}, ::Type{Val{K}}) where {K, V} = true
@inline @pure haskey(::Type{StaticDict{K, V, Nothing}}, ::Type{Val{N}}) where {K, V, N} = false
@inline @pure haskey(::Type{StaticDict{K, V, C}}, ::Type{Val{K}}) where {K, V} where C <: StaticDict = true
@inline @pure haskey(::Type{StaticDict{K, V, C}}, ::Type{Val{N}}) where {K, V, N} where C <: StaticDict = haskey(C, Val{N})
@inline @pure haskey(::C, k) where C <: StaticDict = haskey(C, Val{k})

@inline @pure additem(::Type{StaticDict{Nothing, Nothing, Nothing}}, ::Type{Pair{Val{K}, Val{V}}}) where {K, V} = StaticDict{K, V}()
@inline @pure additem(::Type{StaticDict{K, V, Nothing}}, ::Type{Pair{Val{K}, Val{NV}}}) where {K, V, NV} = StaticDict{K, NV}()
@inline @pure additem(::Type{StaticDict{K, V, Nothing}}, ::Type{Pair{Val{NK}, Val{NV}}}) where {K, V, NK, NV} = StaticDict{K, V}(StaticDict{NK, NV, Nothing})
@inline @pure additem(::Type{StaticDict{K, V, C}}, ::Type{Pair{Val{K}, Val{NV}}}) where {K, V, NV} where C <: StaticDict = StaticDict{K, NV}(C)
@inline @pure additem(::Type{StaticDict{K, V, C}}, ::Type{Pair{Val{NK}, Val{NV}}}) where {K, V, NK, NV} where C <: StaticDict = StaticDict{K, V}(additem(C, Pair{Val{NK}, Val{NV}}))
@inline @pure additem(::C, kv::Pair) where C <: StaticDict = additem(C, Pair{Val{kv[1]}, Val{kv[2]}})

@inline @pure tuple_cat(x::Tuple) = x
@inline @pure tuple_cat(x::Tuple, ::Nothing) = x
@inline @pure tuple_cat(x::Tuple, y::Tuple) = (x..., y...)
@inline @pure tuple_cat(x::Tuple, y::Tuple, zs::Tuple...) = (x..., tuple_cat(y, zs...)...)

end # module
