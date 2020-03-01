# TableTestSets

[![Build Status](https://github.com/ericphanson/TableTestSets.jl/workflows/CI/badge.svg)](https://github.com/ericphanson/TableTestSets.jl/actions)
[![Coverage](https://codecov.io/gh/ericphanson/TableTestSets.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ericphanson/TableTestSets.jl)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ericphanson.github.io/TableTestSets.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ericphanson.github.io/TableTestSets.jl/dev)

Testsets which can be printed to HTML tables. Provides
* a type `TableTestSet <: AbstractTestSet` which is only slightly modified from `Test.DefaultTestSet` to not throw errors, by default, and to implement the `Tables.jl` interface
* a function `html_table(io, ts::TableTestSet)` to print an HTML table formatted similarly to the usual test printing style
* and functions `TableTestSets.print_test_results(io::IO, ts::TableTestSet)` and `TableTestSets.print_test_errors(io::IO, ts::TableTestSet)` to print results or errors to an IO object.

Relies on a few internal functions from the Test standard library, so this code could potentially break in future minor releases of Julia (tested on 1.3).

## Example

```julia
results = @testset TableTestSet "outer" begin
        @testset "inner 1" begin
            @test 1 // 1 == 1
            @test false
        end

        @testset "inner 2" begin
            @test true
            @test error()
        end
    end

open("file.html", "w") do io
   TableTestSets.html_table(io,results; standalone=true)
end
```


<table>
<tr class="header">
<td style="text-align:left;border-right: solid 2px;">testset</td>
<td style="text-align:center;">pass</td>
<td style="text-align:center;">fail</td>
<td style="text-align:center;">error</td>
<td style="text-align:center;">broken</td>
<td style="text-align:center;">total</td>
</tr>
<tr><td style="text-align:left;border-right: solid 2px;">outer</td>
<td style="text-align:center;color:green;">2</td>
<td style="text-align:center;color:red;">1</td>
<td style="text-align:center;color:red;">1</td>
<td style="text-align:center;">0</td>
<td style="text-align:center;color:blue;">4</td>
</tr><tr><td style="text-align:left;border-right: solid 2px;">&nbsp;&nbsp;inner 1</td>
<td style="text-align:center;color:green;">1</td>
<td style="text-align:center;color:red;">1</td>
<td style="text-align:center;">0</td>
<td style="text-align:center;">0</td>
<td style="text-align:center;color:blue;">2</td>
</tr><tr><td style="text-align:left;border-right: solid 2px;">&nbsp;&nbsp;inner 2</td>
<td style="text-align:center;color:green;">1</td>
<td style="text-align:center;">0</td>
<td style="text-align:center;color:red;">1</td>
<td style="text-align:center;">0</td>
<td style="text-align:center;color:blue;">2</td>
</tr></table>
