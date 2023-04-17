include("automorphisms.jl")
include("pairiterator.jl")

import Pkg
Pkg.add("Combinatorics")
Pkg.add("DataStructures")
using Combinatorics
using DataStructures

# macro to turn our wh_reduceN into minimizer functions wh_minimizeN
macro wh_minimize(num)
    fun_name = Symbol("wh_minimize$num")
    red_name = Symbol("wh_reduce$num")
    quote
        function $(esc(fun_name))(w::Word, X::Alphabet)
            while (v = $(esc(red_name))(w, X)) !== nothing
                w = v
            end
            return w
        end
    end
end

@wh_minimize 1
@wh_minimize 2
@wh_minimize 3

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
        for y in X
            y == x && continue
            y == -x && continue

            # x => x·y
            σ = nielsen(x, y, X)
            v = wreduce_circ(σ*w)
            if length(v) < length(w)
                return v
            end
        end
    end
    # Nielsen automorphism x => y·x will be covered by x⁻¹ => x⁻¹·y⁻¹

    # this will test about |X| / 2^|X| automorphisms too much... not a big problem for |X| >> 1
    return wh_reduce1(w, X)
end

"""
First try out all Nielsen automorphism in advantageous order, then try out all Whitehead automorphisms
"""
function wh_reduce3(w::Word, X::Alphabet)
    if length(w) <= 1
        return nothing
    end

    subwords = DefaultDict{Tuple{Letter, Letter}, Integer}(0)

    for (x, y) in pairs(w)
        x == y && continue
        x == -y && continue
        
        # Axiom of Choice is not computable, so don't have a way to order x and y in general :)
        subwords[(x, y)] += 1
        subwords[(-y, -x)] += 1
    end

    for ((x, y), n) in sort(collect(subwords), by=x -> x[2])
        # subword x·y in w
        #  -> map x => x·y⁻¹
        #  -> map y => x⁻¹·y  <- but this is handled by the equivalently-ranked subword y⁻¹·x⁻¹
        σ = nielsen(x, -y, X)
        v = wreduce_circ(σ*w)
        if length(v) < length(w)
            return v
        end
    end

    # this will test about |X| / 2^|X| automorphisms too much... not a big problem for |X| >> 1
    return wh_reduce1(w, X)
end
