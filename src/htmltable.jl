function html_table(io::IO, ts::TableTestSet)
    tab = Tables.columntable(ts)

    hl_red = HTMLHighlighter(
        (data, i, j) -> (j ∈ (3, 4)) && data[i, j] > 0,
        HTMLDecoration(color = "red"),
    )
    hl_green = HTMLHighlighter(
        (data, i, j) -> (j == 2) && data[i, j] > 0,
        HTMLDecoration(color = "green"),
    )
    hl_blue = HTMLHighlighter(
        (data, i, j) -> (j == 5) && data[i, j] > 0,
        HTMLDecoration(color = "blue"),
    )
    CA = Dict(
        (i, j) => j == 1 ? :l : :c for i = 1:Tables.rowcount(tab) for j = 1:length(tab)
    )

    depth_formatter =
        Dict{Number,Function}(1 => (value, row) -> repeat("&nbsp;", tab[7][row]) * value)
    tf = HTMLTableFormat(css = """
                         table, td, th {
                             border-collapse: collapse;
                             font-family: sans-serif;
                         }

                         tr.headerLastRow th:first-child {
                             text-align:left !important;
                             border-right: solid 2px;
                         }

                         tr td:first-child {
                             border-right: solid 2px;
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
                         tr.subheader {
                             background: #fff !important;
                             color: dimgray;
                         }
                         tr.headerLastRow {
                             border-bottom: 2px solid black;
                         }
                         th.rowNumber, td.rowNumber {
                             text-align: right;
                         }
                         """)
    buffer = IOBuffer()
    pretty_table(
        buffer,
        tab;
        formatter = depth_formatter,
        filters_col = ((data, i) -> i <= 6,),
        backend = :html,
        nosubheader = true,
        highlighters = (hl_red, hl_green, hl_blue),
        cell_alignment = CA,
        tf = tf,
    )
    write(io, take!(buffer))
    nothing
end
