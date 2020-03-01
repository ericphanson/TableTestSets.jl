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

    @test str == "<table>\n<tr class=\"header\">\n<td style=\"text-align:left;border-right: solid 2px;\">testset</td>\n<td style=\"text-align:center;\">pass</td>\n<td style=\"text-align:center;\">fail</td>\n<td style=\"text-align:center;\">error</td>\n<td style=\"text-align:center;\">broken</td>\n<td style=\"text-align:center;\">total</td>\n</tr>\n<tr><td style=\"text-align:left;border-right: solid 2px;\">outer</td>\n<td style=\"text-align:center;color:green;\">2</td>\n<td style=\"text-align:center;color:red;\">1</td>\n<td style=\"text-align:center;color:red;\">1</td>\n<td style=\"text-align:center;\">0</td>\n<td style=\"text-align:center;color:blue;\">4</td>\n</tr><tr><td style=\"text-align:left;border-right: solid 2px;\">&nbsp;&nbsp;inner 1</td>\n<td style=\"text-align:center;color:green;\">1</td>\n<td style=\"text-align:center;color:red;\">1</td>\n<td style=\"text-align:center;\">0</td>\n<td style=\"text-align:center;\">0</td>\n<td style=\"text-align:center;color:blue;\">2</td>\n</tr><tr><td style=\"text-align:left;border-right: solid 2px;\">&nbsp;&nbsp;inner 2</td>\n<td style=\"text-align:center;color:green;\">1</td>\n<td style=\"text-align:center;\">0</td>\n<td style=\"text-align:center;color:red;\">1</td>\n<td style=\"text-align:center;\">0</td>\n<td style=\"text-align:center;color:blue;\">2</td>\n</tr></table>\n"
end
