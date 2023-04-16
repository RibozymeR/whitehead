include("automorphisms.jl")

import Pkg
Pkg.add("Combinatorics")
using Combinatorics

"""
Simply try out all Whitehead automorphisms until one reduces length of the given word
"""
function wh_reduce1(w::Word, X::Alphabet)
    for a in X
        X2 = setdiff(X.letters, [a, -a])
        for A in Combinatorics.powerset(X2)
            σ = whitehead(A, a, X)
            v = wreduce_circ(σ*w)
            if length(v) < length(w)
                return v
            end
        end
    end
    return nothing
end

function wh_minimize(w::Word, X::Alphabet)
    while (v = wh_reduce1(w, X)) !== nothing
        w = v
    end
    return w
end
