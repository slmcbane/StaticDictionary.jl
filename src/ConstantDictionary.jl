__precompile__()

module ConstantDictionary

export ConstDict, additem

import Base: keys, values, getindex, haskey

struct ConstDict{KT, VT, K, V, C} 
    @inline function ConstDict{KT, VT}(k::KT, v::VT) where KT where VT
        new{KT, VT, k, v, Nothing}()
    end
    
    @inline function ConstDict{KT, VT}(k::KT, v::VT, c::ConstDict) where KT where VT
        @assert !haskey(c, k) "Key $k is already in keys of child dictionary"
        new{KT, VT, k, v, typeof(c)}()
    end
    
    @inline function ConstDict{KT, VT, K, V, C}() where {KT, VT, K, V} where C <: Union{ConstDict, Nothing}
        new{KT, VT, K, V, C}()
    end
end

@inline ConstDict(k::K, v::V) where K where V = ConstDict{K, V}(k, v)
@inline ConstDict(kv::Pair{K, V}) where K where V = ConstDict(kv[1], kv[2])
@inline ConstDict(kv::Pair{K, V}, kvs::Pair...) where {K, V} = ConstDict{K, V}(kv[1], kv[2], ConstDict(kvs...))

@inline keys(::ConstDict{KT, VT, K, V, Nothing}) where {KT, VT, K, V} = (K,)
@inline keys(::ConstDict{KT, VT, K, V, C}) where {KT, VT, K, V} where C <: ConstDict = tuple_cat((K,), keys(C()))

@inline values(::ConstDict{KT, VT, K, V, Nothing}) where {KT, VT, K, V} = (V,)
@inline values(::ConstDict{KT, VT, K, V, C}) where {KT, VT, K, V} where C <: ConstDict = tuple_cat((V,), values(C()))

@inline function getindex(::ConstDict{KT, VT, K, V, Nothing}, k) where {KT, VT, K, V}
    @assert k == K
    V
end

@inline function getindex(::ConstDict{KT, VT, K, V, C}, k) where {KT, VT, K, V} where C <: ConstDict
    k == K ? V : getindex(C(), k)
end

@inline function haskey(::ConstDict{KT, VT, K, V, C}, k) where {KT, VT, K, V} where C <: ConstDict
    k == K || haskey(C(), k)
end

@inline function haskey(::ConstDict{KT, VT, K, V, Nothing}, k) where {KT, VT, K, V}
    k == K
end

@inline function additem(c::ConstDict{KT, VT, K, V}, kv::Pair{NK, NV}) where {KT, VT, K, V, NK, NV}
    ConstDict{NK, NV}(kv[1], kv[2], c)
end

@inline tuple_cat(x::Tuple) = x
@inline tuple_cat(x::Tuple, y::Tuple) = (x..., y...)
@inline tuple_cat(x::Tuple, y::Tuple, zs::Tuple...) = (x..., tuple_cat(y, zs...)...)

end # module
