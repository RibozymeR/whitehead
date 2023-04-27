include("../automorphisms.jl")
include("../whitehead.jl")

using Random
using Test
using BenchmarkTools

function random_aut(X::Alphabet)
    a = rand(X.letters)

    X2 = setdiff(X.letters, [a, -a])
    A = X2[bitrand(length(X2))]

    return whitehead(A, a, X)
end

"""
Just a vector of random letters of length `len`, freely reduced
"""
basic_random(X::Alphabet, len::Integer) = word(rand(X.letters, len))

"""
Random word obtained by applying automorphisms to base word, guaranteed to be primitive  
`len` will only be approximate length
"""
function prim_random(X::Alphabet, len::Integer)
    w = Word(rand(X.letters, 1))

    while length(w) < len / 2
        σ = random_aut(X)
        v = wreduce_circ(σ*w)
        if length(v) > length(w)
            w = v
        end
    end

    return w
end

"""
Random word obtained by applying automorphisms to base word, guaranteed to be imprimitive and automorphic to a word of length 2  
`len` will only be approximate length
"""
function imprim_random(X::Alphabet, len::Integer)
    a = rand(X.letters)
    w = Word([a, a])

    while length(w) < len / 2
        σ = random_aut(X)
        v = wreduce_circ(σ*w)
        if length(v) > length(w)
            w = v
        end
    end

    return w
end

X = Alphabet([:a, :b, :c, :d, :e])
@test length(wh_minimize1(prim_random(X, 1000), X)) == 1
@test length(wh_minimize1(imprim_random(X, 1000), X)) == 2

@show @benchmark wh_minimize1(prim_random(X, 1000), X)

@show @benchmark wh_minimize2(prim_random(X, 1000), X)

@show @benchmark wh_minimize3(prim_random(X, 1000), X)

@show @benchmark wh_minimize1(imprim_random(X, 1000), X)

@show @benchmark wh_minimize2(imprim_random(X, 1000), X)

@show @benchmark wh_minimize3(imprim_random(X, 1000), X)