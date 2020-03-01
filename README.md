# TableTestSets

[![Build Status](https://github.com/ericphanson/TableTestSets.jl/workflows/CI/badge.svg)](https://github.com/ericphanson/TableTestSets.jl/actions)
[![Coverage](https://codecov.io/gh/ericphanson/TableTestSets.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ericphanson/TableTestSets.jl)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ericphanson.github.io/TableTestSets.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ericphanson.github.io/TableTestSets.jl/dev)

Testsets which can be printed to HTML tables.

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
    html_table(io, results)
end
```


<table>
<tr class = "header headerLastRow">
<th style = "text-align: right; ">testset</th>
<th style = "text-align: right; ">pass</th>
<th style = "text-align: right; ">fail</th>
<th style = "text-align: right; ">error</th>
<th style = "text-align: right; ">broken</th>
<th style = "text-align: right; ">total</th>
</tr>
<tr>
<td style = "text-align: left; ">outer</td>
<td style = "color: green; text-align: center; ">2</td>
<td style = "color: red; text-align: center; ">1</td>
<td style = "color: red; text-align: center; ">1</td>
<td style = "text-align: center; ">0</td>
<td style = "text-align: center; ">4</td>
</tr>
<tr>
<td style = "text-align: left; ">&nbsp;inner 1</td>
<td style = "color: green; text-align: center; ">1</td>
<td style = "color: red; text-align: center; ">1</td>
<td style = "text-align: center; ">0</td>
<td style = "text-align: center; ">0</td>
<td style = "text-align: center; ">2</td>
</tr>
<tr>
<td style = "text-align: left; ">&nbsp;inner 2</td>
<td style = "color: green; text-align: center; ">1</td>
<td style = "text-align: center; ">0</td>
<td style = "color: red; text-align: center; ">1</td>
<td style = "text-align: center; ">0</td>
<td style = "text-align: center; ">2</td>
</tr>
</table>
