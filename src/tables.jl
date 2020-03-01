Tables.istable(::Type{TableTestSet}) = true
Tables.rowaccess(::Type{TableTestSet}) = true

function Tables.rows(ts::TableTestSet)
    table = Vector{NamedTuple{(:testset, :pass, :fail, :error, :broken, :total, :depth), Tuple{String, Int, Int, Int, Int, Int, Int}}}()
    populate_table!(table, ts, 0)
    table
end

# Recursive function that prints out the results at each level of
# the tree of test sets
function populate_table!(table, ts::TableTestSet, depth)
    # Count results by each type at this level, and recursively
    # through any child test sets
    passes, fails, errors, broken, c_passes, c_fails, c_errors, c_broken = get_test_counts(ts)
    subtotal = passes + fails + errors + broken + c_passes + c_fails + c_errors + c_broken
    np = passes + c_passes
    nf = fails + c_fails
    ne = errors + c_errors
    nb = broken + c_broken
    push!(table, (testset=ts.description, pass=np, fail=nf, error=ne, broken=nb, total=subtotal, depth=depth))
    # Only print results at lower levels if we had failures
    if np + nb != subtotal
        for t in ts.results
            if isa(t, TableTestSet)
                populate_table!(table, t, depth + 1)
            end
        end
    end
end
