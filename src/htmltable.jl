function write_html_table(io::IO, tab; header = Tables.columnnames(first(Tables.rows(tab))), style = (value, i, j) -> "", format = (value, i, j) -> value, include_columns = 1:length(header), standalone = false, css = """
    table, td, th {
        border-collapse: collapse;
        font-family: sans-serif;
    }
    td, th {
        border-bottom: 0;
        background: #fff !important;
        padding: 6px
    }
    tr.header {
        background: #fff !important;
        font-weight: bold;
    }
    """)
    rows = Tables.rows(tab)
    if standalone
        println(io,"""
        <!DOCTYPE html>
        <html>
        <meta charset="UTF-8">
        <style>
        $css
        </style>
        <body>
        """)
    end
    println(io, "<table>")
    println(io, """<tr class="header">""")
    for (j, h) in enumerate(header)
        j ∈ include_columns || continue
        println(io, """
        <td style="$(style(h,0,j))">$(format(h, 0, j))</td>""")
    end
    println(io, "</tr>")
    for (i, row) in enumerate(rows)
        print(io, """<tr>""")
        for (j, h) in enumerate(row)
            j ∈ include_columns || continue
            println(io, """
                <td style="$(style(h,i,j))">$(format(h, i, j))</td>""")
        end
        print(io, "</tr>")
    end
    println(io, "</table>")
    if standalone
        println(io, """
        </body>
        </html>
        """)
    end
end

function html_table(io::IO, ts::TableTestSet; kwargs...)
    tab = Tables.rowtable(ts)
    style = function(value, i, j)
        str = ""

        if j == 1
            str *= "text-align:left;"
            str *= "border-right: solid 2px;"
        else
            str *= "text-align:center;"
        end

        # if it's the header, stop here
        if i == 0
            return str
        end

        if j == 2 && tab[i][j] > 0
            str *= "color:green;"
        elseif j ∈ (3,4) && tab[i][j] > 0
            str *= "color:red;"
        elseif j == 6 && tab[i][j] > 0
            str *= "color:blue;"
        end

        return str
    end

    format = function(value, i, j)
        if i > 0 && j == 1
            depth = tab[i][7]
            value = repeat("&nbsp;", 2*depth) * value
        end
        return value
    end

    write_html_table(io::IO, ts; style = style, format = format, include_columns = 1:6, kwargs...)
end
