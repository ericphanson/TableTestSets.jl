module TableTestSets

export html_table
export TableTestSet

using Test
using Test: AbstractTestSet, Result, Pass, Fail, Error, Broken, TestSetException
using Test: get_testset_depth, get_testset, myid, scrub_backtrace, record

using Tables

include("tabletestset.jl")
include("tables.jl")
include("htmltable.jl")

end
