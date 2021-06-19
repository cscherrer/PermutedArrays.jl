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
julia> @benchmark permute!($tv1, p) setup=(p=randperm(n))
samples: 1258; evals/sample: 1; memory estimate: 76.31 MiB; allocs estimate: 502
ns

 (3.3e6  - 4.5e6 ]  ██████████████████████████████ 1165
 (4.5e6  - 5.8e6 ]  █34
 (5.8e6  - 7.1e6 ]  ▍12
 (7.1e6  - 8.4e6 ]  ▍11
 (8.4e6  - 9.7e6 ]  ▍13
 (9.7e6  - 1.1e7 ]  ▏2
 (1.1e7  - 1.22e7]  ▎5
 (1.22e7 - 1.35e7]  ▎5
 (1.35e7 - 1.48e7]  ▎6
 (1.48e7 - 1.61e7]  ▏2
 (1.61e7 - 1.74e7]  ▏2
 (1.74e7 - 1.87e7]  ▏1

                  Counts

min: 3.255 ms (7.66% GC); mean: 3.964 ms (15.19% GC); median: 3.620 ms (14.60% GC); max: 18.671 ms (20.43% GC).
```

`PermutedArrays` lets us reduce this to
```julia
julia> @benchmark permute!($tv2, p) setup=(p=randperm(n))
samples: 10000; evals/sample: 198; memory estimate: 1.81 KiB; allocs estimate: 3
ns

 (440.0  - 820.0  ]  ██████████████████████████████ 9359
 (820.0  - 1190.0 ]  █▌436
 (1190.0 - 1570.0 ]  ▍94
 (1570.0 - 1950.0 ]  ▏20
 (1950.0 - 2320.0 ]  ▏9
 (2320.0 - 2700.0 ]  ▏2
 (2700.0 - 3080.0 ]   0
 (3080.0 - 3450.0 ]   0
 (3450.0 - 3830.0 ]   0
 (3830.0 - 4210.0 ]  ▏5
 (4210.0 - 4580.0 ]  ▏32
 (4580.0 - 4960.0 ]  ▏14
 (4960.0 - 5340.0 ]  ▏8
 (5340.0 - 5710.0 ]  ▏11
 (5710.0 - 19290.0]  ▏10

                  Counts

min: 438.944 ns (0.00% GC); mean: 617.635 ns (5.85% GC); median: 547.018 ns (0.00% GC); max: 19.288 μs (91.00% GC).
```

Note that doing this by converting to a `Vector` would require copying the data:
```julia
julia> @benchmark tv3 = Vector($tv1)
samples: 10000; evals/sample: 55; memory estimate: 7.19 KiB; allocs estimate: 1
ns

 (800.0   - 6500.0  ]  ██████████████████████████████ 9876
 (6500.0  - 12100.0 ]  ▎43
 (12100.0 - 17700.0 ]   0
 (17700.0 - 23300.0 ]   0
 (23300.0 - 29000.0 ]  ▏37
 (29000.0 - 34600.0 ]  ▏5
 (34600.0 - 40200.0 ]  ▏5
 (40200.0 - 45800.0 ]  ▏4
 (45800.0 - 51500.0 ]  ▏2
 (51500.0 - 57100.0 ]  ▏1
 (57100.0 - 62700.0 ]   0
 (62700.0 - 68400.0 ]  ▏6
 (68400.0 - 74000.0 ]  ▏6
 (74000.0 - 79600.0 ]  ▏5
 (79600.0 - 122000.0]  ▏10

                  Counts

min: 822.727 ns (0.00% GC); mean: 2.058 μs (16.98% GC); median: 1.149 μs (0.00% GC); max: 122.039 μs (91.17% GC).
```
But after paying that cost, that approach can be just as fast:
```julia
julia> @benchmark permute!($tv3, p) setup=(p=randperm(n))
samples: 10000; evals/sample: 195; memory estimate: 896 bytes; allocs estimate: 1
ns

 (480.0  - 790.0 ]  ██████████████████████████████ 9555
 (790.0  - 1110.0]  █▏325
 (1110.0 - 1430.0]  ▎58
 (1430.0 - 1750.0]  ▏16
 (1750.0 - 2060.0]  ▏8
 (2060.0 - 2380.0]   0
 (2380.0 - 2700.0]   0
 (2700.0 - 3010.0]   0
 (3010.0 - 3330.0]   0
 (3330.0 - 3650.0]   0
 (3650.0 - 3970.0]   0
 (3970.0 - 4280.0]  ▏8
 (4280.0 - 4600.0]  ▏13
 (4600.0 - 4920.0]  ▏7
 (4920.0 - 9460.0]  ▏10

                  Counts

min: 477.128 ns (0.00% GC); mean: 563.762 ns (2.74% GC); median: 517.728 ns (0.00% GC); max: 9.459 μs (87.89% GC).
```
However, the memory requirements have now doubled, and the `Vector` loses the original advantages of the packed format.
