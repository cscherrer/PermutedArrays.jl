using PermutedArrays
using Documenter

DocMeta.setdocmeta!(PermutedArrays, :DocTestSetup, :(using PermutedArrays); recursive=true)

makedocs(;
    modules=[PermutedArrays],
    authors="Chad Scherrer <chad.scherrer@gmail.com> and contributors",
    repo="https://github.com/cscherrer/PermutedArrays.jl/blob/{commit}{path}#{line}",
    sitename="PermutedArrays.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cscherrer.github.io/PermutedArrays.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/cscherrer/PermutedArrays.jl",
)
