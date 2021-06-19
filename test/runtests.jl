using PermutedArrays
using Test
using Random

@testset "PermutedArrays.jl" begin
    
    function testiperm(v)
        @test v.perm[v.iperm] == v.data
        @test v.iperm[v.perm] == v.data
    end

    v =PermutedVector(1:9);

    @testset "`permute!`" begin
        permute!(v, randperm(9));
        testiperm(v)
    end

    @testset "`swap!`" begin
        swap!(v, 2, 7);
        testiperm(v)
    end

    @testset "`sortperm`" begin
        ℓ = sort(randn(100));
        x = PermutedVector(1:100);

        p = randperm(100);

        permute!(x,p);
        permute!(ℓ,p);

        @test sortperm(ℓ) == sortperm(x)
        testiperm(v)
    end


    @testset "`x .= x[p]`" begin
        ℓ = sort(randn(100));
        x = PermutedVector([1:100;]);

        p = randperm(100);

        x .= x[p]
        ℓ .= ℓ[p]

        @test sortperm(ℓ) == sortperm(x)
        testiperm(v)
    end

end
