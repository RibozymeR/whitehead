include("automorphisms.jl")
include("pairiterator.jl")
include("powerset.jl")

using DataStructures

# macro to turn our wh_reduceN_aut into minimizer functions wh_minimizeN_aut
macro wh_minimize_aut(num)
    fun_name = Symbol("wh_minimize$(num)_aut")
    red_name = Symbol("wh_reduce$(num)_aut")
    quote
        function $(esc(fun_name))(w::Word, X::Alphabet)
            σ = Automorphism(X)
            while (τ = $(esc(red_name))(w, X)) !== nothing
                σ = τ * σ
                w = τ(w)
            end
            return σ
        end
    end
end

@wh_minimize_aut 1
@wh_minimize_aut 2
@wh_minimize_aut 3

# test whether automorphism reduced given word, if so returns
macro test_aut(expr, w)
    quote
        σ = $(esc(expr))
        # circular reduction automorphisms get rather long, so we only compute it when necessary
        if length(wreduce_circ(σ($(esc(w))))) < length($(esc(w)))
            return reduction(σ($(esc(w))), X) * σ
        end
    end
end

"""
Simply try out all Whitehead automorphisms until one reduces length of the given word  
Returns `nothing` if word cannot be reduced
"""
function wh_reduce1_aut(w::Word, X::Alphabet)
    if length(w) <= 1
        return nothing
    end

    for a in X
        X2 = setdiff(X.letters, [a, -a])
        for A in powerset(X2)
            # if A is empty, this does nothing, but that's only 1/2^|X| of the iterations
            @test_aut whitehead(A, a, X) w
        end
    end

    return nothing
end

"""
First try out all Nielsen automorphism, then try out all Whitehead automorphisms
"""
function wh_reduce2_aut(w::Word, X::Alphabet)
    if length(w) <= 1
        return nothing
    end

    for x in X
        for y in X
            y == x && continue
            y == -x && continue
            # x => x·y
            @test_aut nielsen(x, y, X) w
        end
    end
    # Nielsen automorphism x => y·x will be covered by x⁻¹ => x⁻¹·y⁻¹

    # this will test about |X| / 2^|X| automorphisms too much... not a big problem for |X| >> 1
    return wh_reduce1_aut(w, X)
end

"""
First try out all Nielsen automorphism in advantageous order, then try out all Whitehead automorphisms
"""
function wh_reduce3_aut(w::Word, X::Alphabet)
    if length(w) <= 1
        return nothing
    end

    subwords = DefaultDict{Tuple{Letter, Letter}, Integer}(0)

    for (x, y) in pairs(w)
        x == y && continue
        x == -y && continue
        
        subwords[(x, y)] += 1
        subwords[(-y, -x)] += 1
    end

    for ((x, y), n) in sort(collect(subwords), by=x -> x[2])
        # subword x·y in w
        @test_aut nielsen(x, -y, X) w
    end

    # this will test about |X| / 2^|X| automorphisms too much... not a big problem for |X| >> 1
    return wh_reduce1_aut(w, X)
end
