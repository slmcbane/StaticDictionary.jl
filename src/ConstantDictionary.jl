__precompile__()

module ConstantDictionary

export ConstDict, additem

import Base: keys, values, getindex, haskey
using Base: @pure

struct ConstDict{K, V, C}
    @inline @pure ConstDict{K, V}() where {K, V} = new{K, V, Nothing}()
    @inline @pure ConstDict{K, V}(::Type{C}) where {K, V} where C <: ConstDict = haskey(C, Val{K}) ? additem(C, Pair{Val{K}, Val{V}}) : new{K, V, C}()
    @inline @pure ConstDict{K, V}(::C) where {K, V} where C <: ConstDict = ConstDict{K, V}(C)
    @inline @pure ConstDict{K, V, Nothing}() where {K, V} = ConstDict{K, V}()
    @inline @pure ConstDict{K, V, C}() where {K, V, C} = ConstDict{K, V}(C())
end

@inline @pure ConstDict(::Type{Val{K}}, ::Type{Val{V}}) where K where V = ConstDict{K, V}()
@inline @pure ConstDict(::Type{Pair{Val{K}, Val{V}}}) where K where V = ConstDict{K, V}()
@inline @pure ConstDict(::Type{Pair{Val{K}, Val{V}}}, kvs::DataType...) where {K, V} = ConstDict{K, V}(ConstDict(kvs...))
@inline @pure ConstDict(k, v) = ConstDict(Val{k}, Val{v})
@inline @pure ConstDict(kv::Pair) = ConstDict(Val{kv[1]}, Val{kv[2]})
@inline @pure ConstDict(kv::Pair, kvs::Pair...) = additem(ConstDict(kvs...), kv)
@inline @pure ConstDict() = ConstDict{Nothing, Nothing, Nothing}()

@inline @pure keys(::Type{ConstDict{Nothing, Nothing, Nothing}}) = ()
@inline @pure keys(::Type{ConstDict{K, V, Nothing}}) where {K, V} = (K,)
@inline @pure keys(::Type{ConstDict{K, V, C}}) where {K, V} where C <: ConstDict = tuple_cat((K,), keys(C()))
@inline @pure keys(::C) where C <: ConstDict = keys(C)

@inline @pure values(::Type{ConstDict{Nothing, Nothing, Nothing}}) = ()
@inline @pure values(::Type{ConstDict{K, V, Nothing}}) where {K, V} = (V,)
@inline @pure values(::Type{ConstDict{K, V, C}}) where {K, V} where C <: ConstDict = tuple_cat((V,), values(C()))
@inline @pure values(::C) where C <: ConstDict = values(C)

@inline @pure getindex(::Type{ConstDict{Nothing, Nothing, Nothing}}, k) = nothing
@inline @pure getindex(::Type{ConstDict{K, V, Nothing}}, ::Type{Val{K}}) where {K, V} = V
@inline @pure getindex(::Type{ConstDict{K, V, Nothing}}, ::Type{Val{N}}) where {K, V, N} = nothing
@inline @pure getindex(::Type{ConstDict{K, V, C}}, ::Type{Val{K}}) where {K, V} where C <: ConstDict = V
@inline @pure getindex(::Type{ConstDict{K, V, C}}, ::Type{Val{N}}) where {K, V, N} where C <: ConstDict = getindex(C, Val{N})
@inline @pure getindex(::C, k) where C <: ConstDict = getindex(C, Val{k})

@inline @pure haskey(::Type{ConstDict{Nothing, Nothing, Nothing}}, k) = false
@inline @pure haskey(::Type{ConstDict{K, V, Nothing}}, ::Type{Val{K}}) where {K, V} = true
@inline @pure haskey(::Type{ConstDict{K, V, Nothing}}, ::Type{Val{N}}) where {K, V, N} = false
@inline @pure haskey(::Type{ConstDict{K, V, C}}, ::Type{Val{K}}) where {K, V} where C <: ConstDict = true
@inline @pure haskey(::Type{ConstDict{K, V, C}}, ::Type{Val{N}}) where {K, V, N} where C <: ConstDict = haskey(C, Val{N})
@inline @pure haskey(::C, k) where C <: ConstDict = haskey(C, Val{k})

@inline @pure additem(::Type{ConstDict{Nothing, Nothing, Nothing}}, ::Type{Pair{Val{K}, Val{V}}}) where {K, V} = ConstDict{K, V}()
@inline @pure additem(::Type{ConstDict{K, V, Nothing}}, ::Type{Pair{Val{K}, Val{NV}}}) where {K, V, NV} = ConstDict{K, NV}()
@inline @pure additem(::Type{ConstDict{K, V, Nothing}}, ::Type{Pair{Val{NK}, Val{NV}}}) where {K, V, NK, NV} = ConstDict{K, V}(ConstDict{NK, NV, Nothing})
@inline @pure additem(::Type{ConstDict{K, V, C}}, ::Type{Pair{Val{K}, Val{NV}}}) where {K, V, NV} where C <: ConstDict = ConstDict{K, NV}(C)
@inline @pure additem(::Type{ConstDict{K, V, C}}, ::Type{Pair{Val{NK}, Val{NV}}}) where {K, V, NK, NV} where C <: ConstDict = ConstDict{K, V}(additem(C, Pair{Val{NK}, Val{NV}}))
@inline @pure additem(::C, kv::Pair) where C <: ConstDict = additem(C, Pair{Val{kv[1]}, Val{kv[2]}})

@inline @pure tuple_cat(x::Tuple) = x
@inline @pure tuple_cat(x::Tuple, ::Nothing) = x
@inline @pure tuple_cat(x::Tuple, y::Tuple) = (x..., y...)
@inline @pure tuple_cat(x::Tuple, y::Tuple, zs::Tuple...) = (x..., tuple_cat(y, zs...)...)

end # module
