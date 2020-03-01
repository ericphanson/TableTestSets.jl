using TableTestSets
using Test

@testset "TableTestSets.jl" begin
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

    io = IOBuffer()
    html_table(io, results)
    str = String(take!(io))

    @test str == "<!DOCTYPE html>\n<html>\n<meta charset=\"UTF-8\">\n<style>\ntable, td, th {\n    border-collapse: collapse;\n    font-family: sans-serif;\n}\n\ntr.headerLastRow th:first-child {\n    text-align:left !important;\n    border-right: solid 2px;\n}\n\ntr td:first-child {\n    border-right: solid 2px;\n}\ntd, th {\n    border-bottom: 0;\n    background: #fff !important;\n    padding: 6px\n}\ntr.header {\n    background: #fff !important;\n    font-weight: bold;\n}\ntr.subheader {\n    background: #fff !important;\n    color: dimgray;\n}\ntr.headerLastRow {\n    border-bottom: 2px solid black;\n}\nth.rowNumber, td.rowNumber {\n    text-align: right;\n}\n\n</style>\n<body>\n<table>\n<tr class = \"header headerLastRow\">\n<th style = \"text-align: right; \">testset</th>\n<th style = \"text-align: right; \">pass</th>\n<th style = \"text-align: right; \">fail</th>\n<th style = \"text-align: right; \">error</th>\n<th style = \"text-align: right; \">broken</th>\n<th style = \"text-align: right; \">total</th>\n</tr>\n<tr>\n<td style = \"text-align: left; \">outer</td>\n<td style = \"color: green; text-align: center; \">2</td>\n<td style = \"color: red; text-align: center; \">1</td>\n<td style = \"color: red; text-align: center; \">1</td>\n<td style = \"text-align: center; \">0</td>\n<td style = \"text-align: center; \">4</td>\n</tr>\n<tr>\n<td style = \"text-align: left; \">&nbsp;inner 1</td>\n<td style = \"color: green; text-align: center; \">1</td>\n<td style = \"color: red; text-align: center; \">1</td>\n<td style = \"text-align: center; \">0</td>\n<td style = \"text-align: center; \">0</td>\n<td style = \"text-align: center; \">2</td>\n</tr>\n<tr>\n<td style = \"text-align: left; \">&nbsp;inner 2</td>\n<td style = \"color: green; text-align: center; \">1</td>\n<td style = \"text-align: center; \">0</td>\n<td style = \"color: red; text-align: center; \">1</td>\n<td style = \"text-align: center; \">0</td>\n<td style = \"text-align: center; \">2</td>\n</tr>\n</table>\n</body>\n</html>\n"
end
