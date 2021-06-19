module PermutedArrays

using Base.Order

export PermutedVector
struct PermutedVector{T, V} <: AbstractVector{T}
    data::V
    perm::Vector{Int}
    iperm::Vector{Int}
end

function PermutedVector(v::V) where {T, V <: AbstractVector{T}}
    n = length(v)
    perm = collect(1:n)
    iperm = copy(perm)
    PermutedVector{T,V}(v, perm, iperm)
end

Base.size(v::PermutedVector) = size(v.data)
Base.length(v::PermutedVector) = length(v.data)

function Base.permute!(v::PermutedVector, p::Vector{Int})
    permute!(v.perm, p)
    invpermute!(v.iperm, p)
    return v
end

Base.getindex(v::PermutedVector, i::Int) = getindex(v.data, v.perm[i])

function Base.setindex!(v::PermutedVector, x, i::Int)
    setindex!(v.data, x, v.perm[i])
end

function swap!(v::AbstractVector, i::Int, j::Int)
    (v[i], v[j]) = (v[j], v[i])
    return v
end

export swap!
function swap!(v::PermutedVector, i::Int, j::Int)
    p = v.perm
    q = v.iperm
    swap!(p, i, j)
    swap!(q, p[i], p[j])
    return v
end

swap!(::Nothing, i::Int, j::Int) = nothing

end # module