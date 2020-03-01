using TableTestSets
using Documenter

makedocs(;
    modules=[TableTestSets],
    authors="Eric P. Hanson",
    repo="https://github.com/ericphanson/TableTestSets.jl/blob/{commit}{path}#L{line}",
    sitename="TableTestSets.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ericphanson.github.io/TableTestSets.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ericphanson/TableTestSets.jl",
)
