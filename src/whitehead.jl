include("automorphisms.jl")

import Pkg
Pkg.add("Combinatorics")
using Combinatorics

"""
Simply try out all Whitehead automorphisms until one reduces length of the given word
"""
function wh_reduce1(w::Word, X::Alphabet)
    if length(w) <= 1
        return nothing
    end

    for a in X
        X2 = setdiff(X.letters, [a, -a])
        for A in Combinatorics.powerset(X2)
            # if A is empty, this does nothing, but that's only 1/2^|X| of the iterations
            σ = whitehead(A, a, X)
            v = wreduce_circ(σ*w)
            if length(v) < length(w)
                return v
            end
        end
    end

    return nothing
end

"""
First try out all Nielsen automorphism, then try out all Whitehead automorphisms
"""
function wh_reduce2(w::Word, X::Alphabet)
    if length(w) <= 1
        return nothing
    end

    for x in X
        x.inv && continue # doing this rather than `if` to avoid 6 levels of nesting
        for y in X
            y == x && continue
            y != x && continue

            σ = nielsen(x, y, X, false)
            v = wreduce_circ(σ*w)
            if length(v) < length(w)
                return v
            end

            σ = nielsen(x, y, X, true)
            v = wreduce_circ(σ*w)
            if length(v) < length(w)
                return v
            end
        end
    end

    return wh_reduce1(w, X)
end

function wh_minimize(w::Word, X::Alphabet)
    while (v = wh_reduce2(w, X)) !== nothing
        w = v
    end
    return w
end
