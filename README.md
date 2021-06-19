# PermutedArrays

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cscherrer.github.io/PermutedArrays.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cscherrer.github.io/PermutedArrays.jl/dev)
[![Build Status](https://github.com/cscherrer/PermutedArrays.jl/workflows/CI/badge.svg)](https://github.com/cscherrer/PermutedArrays.jl/actions)
[![Coverage](https://codecov.io/gh/cscherrer/PermutedArrays.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cscherrer/PermutedArrays.jl)

It's very common in Julia to build `<:AbstractArray` data structures with memory layouts different than an array of pointers. Examples include [StructArrays](https://github.com/JuliaArrays/StructArrays.jl), [ArraysOfArrays](https://github.com/JuliaArrays/ArraysOfArrays.jl), and [TupleVectors](https://github.com/cscherrer/TupleVectors.jl), and of course standard `Array`s where each element is the same immutable type.

This is great, until you need to permute the values. For example, say we have a TupleVector
```julia
using TupleVectors
using PermutedArrays
using Random
using BenchmarkHistograms

n = 100
k = 1000
x = TupleVectors.chainvec(randn(k), n);
for j in 2:n
    x[j] .= randn(k);
end

tv1 = TupleVector((x=x,));
```
Then the cost of a random permutation is
```julia
julia> @btime permute!($tv1, p) setup=(p=randperm(n));
  3.204 ms (502 allocations: 76.31 MiB)
```

`PermutedArrays` lets us reduce this to
```julia
julia> @btime permute!($tv2, p) setup=(p=randperm(n));
  438.015 ns (3 allocations: 1.81 KiB)
```

Note that doing this by converting to a `Vector` would require copying the data:
```julia
julia> @btime tv3 = Vector($tv1);
  818.211 ns (1 allocation: 7.19 KiB)
```
But after paying that cost, that approach can be just as fast:
```julia
julia> tv3 = Vector(tv1);

julia> @btime permute!($tv3, p) setup=(p=randperm(n));
  473.760 ns (1 allocation: 896 bytes)
```
However, the memory requirements have now doubled, and the `Vector` loses the original advantages of the packed format.

## Implementation

The setup is relatively simple:
```julia
struct PermutedVector{T, V} <: AbstractVector{T}
    data::V
    perm::Vector{Int}
    iperm::Vector{Int}
end
```
`perm` is the permutation to be applied implicitly to `data`, and `iperm` is its inverse.
