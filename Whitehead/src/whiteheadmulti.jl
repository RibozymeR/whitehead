include("automorphisms.jl")
include("pairiterator.jl")
include("powerset.jl")

using DataStructures

# macro to turn our wh_reduceN into minimizer functions wh_minimizeN
macro wh_minimize_multi(num)
    fun_name = Symbol("wh_minimize_multi$num")
    red_name = Symbol("wh_reduce_multi$num")
    quote
        function $(esc(fun_name))(ws::Vector{Word{T}}, X::Alphabet{T}) where {T}
            while (vs = $(esc(red_name))(ws, X)[1]) !== nothing
                ws = vs
            end
            return ws
        end
    end
end

@wh_minimize_multi 1
@wh_minimize_multi 2

"""
Simply try out all Whitehead automorphisms until one reduces length of the given word
"""
function wh_reduce_multi1(ws::Vector{Word{T}}, X::Alphabet{T}) where {T}
    total = sum(length(w) for w in ws)

    if total <= length(ws)
        return nothing, nothing
    end

    for a in X
        X2 = setdiff(X.letters, [a, -a])
        for A in powerset(X2)
            # if A is empty, this does nothing, but that's only 1/2^|X| of the iterations
            σ = whitehead(A, a, X)
            vs = [σ(w) for w in ws]
            len = sum(length(v) for v in vs)
            if len < total
                return vs, σ
            end
        end
    end

    return nothing, nothing
end

"""
First try out all Nielsen automorphism in advantageous order, then try out all Whitehead automorphisms
"""
function wh_reduce_multi2(ws::Vector{Word{T}}, X::Alphabet{T}) where {T}
    total = sum(length(w) for w in ws)

    if total <= length(ws)
        return nothing, nothing
    end

    subwords = DefaultDict{Tuple{Letter, Letter}, Integer}(0)

    for w in ws
        for (x, y) in pairs(w)
            x == y && continue
            x == -y && continue
            
            subwords[(x, y)] += 1
            subwords[(-y, -x)] += 1
        end
    end

    for ((x, y), n) in sort(collect(subwords), by=x -> x[2])
        # subword x·y in w
        #  -> map x => x·y⁻¹
        #  -> map y => x⁻¹·y  <- but this is handled by the equivalently-ranked subword y⁻¹·x⁻¹
        σ = nielsen(x, -y, X)
        vs = [σ(w) for w in ws]
        len = sum(length(v) for v in vs)
        if len < total
            return vs, σ
        end
    end

    # this will test about |X| / 2^|X| automorphisms too much... not a big problem for |X| >> 1
    return wh_reduce_multi1(w, X)
end
