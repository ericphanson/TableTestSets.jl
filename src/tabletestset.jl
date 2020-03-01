
"""
    TableTestSet
If using the TableTestSet, the test results will be recorded. If there are any
`Fail`s or `Error`s, an exception will be thrown only at the end, if `throw_exception`
is set to `true`, along with a summary of the test results.
"""
mutable struct TableTestSet <: AbstractTestSet
    description::AbstractString
    results::Vector
    n_passed::Int
    anynonpass::Bool
    throw_exception::Bool
end
TableTestSet(desc; throw_exception = false) = TableTestSet(desc, [], 0, false, throw_exception)

# For a broken result, simply store the result
Test.record(ts::TableTestSet, t::Broken) = (push!(ts.results, t); t)
# For a passed result, do not store the result since it uses a lot of memory
Test.record(ts::TableTestSet, t::Pass) = (ts.n_passed += 1; t)

# For the other result types, immediately print the error message
# but do not terminate. Print a backtrace.
function Test.record(ts::TableTestSet, t::Union{Fail, Error})
    if myid() == 1
        printstyled(ts.description, ": ", color=:white)
        # don't print for interrupted tests
        if !(t isa Error) || t.test_type !== :test_interrupted
            print(t)
            # don't print the backtrace for Errors because it gets printed in the show
            # method
            if !isa(t, Error)
                Base.show_backtrace(stdout, scrub_backtrace(backtrace()))
            end
            println()
        end
    end
    push!(ts.results, t)
    t, isa(t, Error) || backtrace()
end

# When a TableTestSet finishes, it records itself to its parent
# testset, if there is one. This allows for recursive printing of
# the results at the end of the tests
Test.record(ts::TableTestSet, t::AbstractTestSet) = push!(ts.results, t)

function print_test_errors(io::IO, ts::TableTestSet)
    for t in ts.results
        if (isa(t, Error) || isa(t, Fail)) && myid() == 1
            println(io, "Error in testset $(ts.description):")
            Base.show(io, MIME"text/plain"(), t)
            println(io)
            println(io)
        elseif isa(t, TableTestSet)
            print_test_errors(io, t)
        end
    end
end

function print_test_results(io::IO, ts::TableTestSet, depth_pad=0)
    # Calculate the overall number for each type so each of
    # the test result types are aligned
    passes, fails, errors, broken, c_passes, c_fails, c_errors, c_broken = get_test_counts(ts)
    total_pass   = passes + c_passes
    total_fail   = fails  + c_fails
    total_error  = errors + c_errors
    total_broken = broken + c_broken
    dig_pass   = total_pass   > 0 ? ndigits(total_pass)   : 0
    dig_fail   = total_fail   > 0 ? ndigits(total_fail)   : 0
    dig_error  = total_error  > 0 ? ndigits(total_error)  : 0
    dig_broken = total_broken > 0 ? ndigits(total_broken) : 0
    total = total_pass + total_fail + total_error + total_broken
    dig_total = total > 0 ? ndigits(total) : 0
    # For each category, take max of digits and header width if there are
    # tests of that type
    pass_width   = dig_pass   > 0 ? max(length("Pass"),   dig_pass)   : 0
    fail_width   = dig_fail   > 0 ? max(length("Fail"),   dig_fail)   : 0
    error_width  = dig_error  > 0 ? max(length("Error"),  dig_error)  : 0
    broken_width = dig_broken > 0 ? max(length("Broken"), dig_broken) : 0
    total_width  = dig_total  > 0 ? max(length("Total"),  dig_total)  : 0
    # Calculate the alignment of the test result counts by
    # recursively walking the tree of test sets
    align = max(get_alignment(ts, 0), length("Test Summary:"))
    # Print the outer test set header once
    pad = total == 0 ? "" : " "
    printstyled(io, rpad("Test Summary:", align, " "), " |", pad; bold=true, color=:white)
    if pass_width > 0
        printstyled(io, lpad("Pass", pass_width, " "), "  "; bold=true, color=:green)
    end
    if fail_width > 0
        printstyled(io, lpad("Fail", fail_width, " "), "  "; bold=true, color=Base.error_color())
    end
    if error_width > 0
        printstyled(io, lpad("Error", error_width, " "), "  "; bold=true, color=Base.error_color())
    end
    if broken_width > 0
        printstyled(io, lpad("Broken", broken_width, " "), "  "; bold=true, color=Base.warn_color())
    end
    if total_width > 0
        printstyled(io, lpad("Total", total_width, " "); bold=true, color=Base.info_color())
    end
    println(io)
    # Recursively print a summary at every level
    print_counts(io, ts, depth_pad, align, pass_width, fail_width, error_width, broken_width, total_width)
end


const TESTSET_PRINT_ENABLE = Ref(true)

# Called at the end of a @testset, behaviour depends on whether
# this is a child of another testset, or the "root" testset
function Test.finish(ts::TableTestSet)
    # If we are a nested test set, do not print a full summary
    # now - let the parent test set do the printing
    if get_testset_depth() != 0
        # Attach this test set to the parent test set
        parent_ts = get_testset()
        record(parent_ts, ts)
        return ts
    end
    passes, fails, errors, broken, c_passes, c_fails, c_errors, c_broken = get_test_counts(ts)
    total_pass   = passes + c_passes
    total_fail   = fails  + c_fails
    total_error  = errors + c_errors
    total_broken = broken + c_broken
    total = total_pass + total_fail + total_error + total_broken

    if TESTSET_PRINT_ENABLE[]
        print_test_results(stdout, ts)
    end

    # Finally throw an error as we are the outermost test set
    if (total != total_pass + total_broken) && ts.throw_exception
        # Get all the error/failures and bring them along for the ride
        efs = filter_errors(ts)
        throw(TestSetException(total_pass,total_fail,total_error, total_broken, efs))
    end

    # return the testset so it is returned from the @testset macro
    ts
end

# Recursive function that finds the column that the result counts
# can begin at by taking into account the width of the descriptions
# and the amount of indentation. If a test set had no failures, and
# no failures in child test sets, there is no need to include those
# in calculating the alignment
function get_alignment(ts::TableTestSet, depth::Int)
    # The minimum width at this depth is
    ts_width = 2*depth + length(ts.description)
    # If all passing, no need to look at children
    !ts.anynonpass && return ts_width
    # Return the maximum of this width and the minimum width
    # for all children (if they exist)
    isempty(ts.results) && return ts_width
    child_widths = map(t->get_alignment(t, depth+1), ts.results)
    return max(ts_width, maximum(child_widths))
end
get_alignment(ts, depth::Int) = 0

# Recursive function that fetches backtraces for any and all errors
# or failures the testset and its children encountered
function filter_errors(ts::TableTestSet)
    efs = []
    for t in ts.results
        if isa(t, TableTestSet)
            append!(efs, filter_errors(t))
        elseif isa(t, Union{Fail, Error})
            append!(efs, [t])
        end
    end
    efs
end

# Recursive function that counts the number of test results of each
# type directly in the testset, and totals across the child testsets
function get_test_counts(ts::TableTestSet)
    passes, fails, errors, broken = ts.n_passed, 0, 0, 0
    c_passes, c_fails, c_errors, c_broken = 0, 0, 0, 0
    for t in ts.results
        isa(t, Fail)   && (fails  += 1)
        isa(t, Error)  && (errors += 1)
        isa(t, Broken) && (broken += 1)
        if isa(t, TableTestSet)
            np, nf, ne, nb, ncp, ncf, nce , ncb = get_test_counts(t)
            c_passes += np + ncp
            c_fails  += nf + ncf
            c_errors += ne + nce
            c_broken += nb + ncb
        end
    end
    ts.anynonpass = (fails + errors + c_fails + c_errors > 0)
    return passes, fails, errors, broken, c_passes, c_fails, c_errors, c_broken
end

# Recursive function that prints out the results at each level of
# the tree of test sets
function print_counts(io::IO, ts::TableTestSet, depth, align,
                      pass_width, fail_width, error_width, broken_width, total_width)
    # Count results by each type at this level, and recursively
    # through any child test sets
    passes, fails, errors, broken, c_passes, c_fails, c_errors, c_broken = get_test_counts(ts)
    subtotal = passes + fails + errors + broken + c_passes + c_fails + c_errors + c_broken
    # Print test set header, with an alignment that ensures all
    # the test results appear above each other
    print(io, rpad(string("  "^depth, ts.description), align, " "), " | ")

    np = passes + c_passes
    if np > 0
        printstyled(io, lpad(string(np), pass_width, " "), "  ", color=:green)
    elseif pass_width > 0
        # No passes at this level, but some at another level
        print(io, lpad(" ", pass_width), "  ")
    end

    nf = fails + c_fails
    if nf > 0
        printstyled(io, lpad(string(nf), fail_width, " "), "  ", color=Base.error_color())
    elseif fail_width > 0
        # No fails at this level, but some at another level
        print(io, lpad(" ", fail_width), "  ")
    end

    ne = errors + c_errors
    if ne > 0
        printstyled(io, lpad(string(ne), error_width, " "), "  ", color=Base.error_color())
    elseif error_width > 0
        # No errors at this level, but some at another level
        print(io, lpad(" ", error_width), "  ")
    end

    nb = broken + c_broken
    if nb > 0
        printstyled(io, lpad(string(nb), broken_width, " "), "  ", color=Base.warn_color())
    elseif broken_width > 0
        # None broken at this level, but some at another level
        print(io, lpad(" ", broken_width), "  ")
    end

    if np == 0 && nf == 0 && ne == 0 && nb == 0
        printstyled(io, "No tests", color=Base.info_color())
    else
        printstyled(io, lpad(string(subtotal), total_width, " "), color=Base.info_color())
    end
    println(io)

    # Only print results at lower levels if we had failures
    if np + nb != subtotal
        for t in ts.results
            if isa(t, TableTestSet)
                print_counts(io, t, depth + 1, align,
                    pass_width, fail_width, error_width, broken_width, total_width)
            end
        end
    end
end
