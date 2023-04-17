include("words.jl")

struct Automorphism{T}
    maps::Dict{Letter{T}, Word{T}}

    Automorphism(maps::AbstractDict{Letter{T}, Word{T}}) where {T} = new{T}(maps)

    Automorphism(A::Alphabet{T}) where {T} = new{T}(Dict(x => Word([x]) for x in A))
end

Base.copy(σ::Automorphism) = Automorphism(copy(σ.maps))

Base.getindex(σ::Automorphism, x::Letter) = σ.maps[x]
function Base.setindex!(σ::Automorphism, w::Word, x::Letter)
    σ.maps[x] = w
    σ.maps[-x] = -w
end

Base.show(io::IO, σ::Automorphism) = print(io, "$(typeof(σ))(" * join(("$l => $w" for (l,w) in σ.maps), ", ") * ")")
Base.show(io::IO, m::MIME"text/plain", σ::Automorphism) = show(io, σ)

"""
`σ` applied to word `w`, the result will be freely (but not circularly) reduced
"""
function Base.:*(σ::Automorphism, w::Word)
    result = one(w)
    for x in w
        append!(result, σ[x])
    end
    return wreduce(result)
end

"""
`f , g -> λx.f(g(x))`

`(f*g)*w == f*(g*w)`
"""
function Base.:*(f::Automorphism, g::Automorphism)
    fg = copy(g)
    for (x, w) in fg.maps
        if !x.inv # only once for each letter
            fg[x] = f*w
        end
    end
    return fg
end

"""
Nielsen automorphism mapping `x => x·y`.  
If `prepend` is `true`, maps `x => y·x`.
"""
function nielsen(x::Letter, y::Letter, X::Alphabet, prepend::Bool = false)
    σ = Automorphism(X)
    σ[x] = prepend ? Word([y, x]) : Word([x, y])
    return σ
end

"""
Whitehead automorphism mapping every `x` in `A` to `x·a`  
If `x` and `x⁻¹` are in `A`, maps `x` to `a⁻¹·x·a`
"""
function whitehead(A, a::Letter, X::Alphabet)
    # slightly restrictive, but then we don't ever have to do wreduce
    @assert !in(a, A) "Element cannot be in set"
    @assert !in(-a, A) "Element cannot be in set"
    σ = Automorphism(X)
    for x in A
        # it would be nice if you could overload *=, so σ[x] *= Word([a]) would modify σ[x] in-place
        # push!(σ[x], a) does not work, as it will not modify σ[-x]
        σ[x] *= Word([a])
    end
    return σ
end

"""
Automorphism that circularly reduces the given (preferably reduced) word
"""
function reduction(w::Word, X::Alphabet)
    σ = Automorphism(X)

    first = firstindex(w)
    last = lastindex(w)
    
    # as long as the first and last symbol of the word cancel
    while last > first && -w[first] == w[last]
        y = w[first]

        # x -> x1·x2·...·xk
        # turn into -y·x1·x2·...·xk·y if x (or x⁻¹) is in (current sub)word and any xi != y
        letters = Set(@view w[first:last])
        for x in X
            # for generator x, can do this for x or for -x; here, we choose x
            # maybe it's better to construct letters accordingly and iterate over that? hm.
            if !x.inv && (x ∈ letters || -x ∈ letters)
                map = σ[x]
                if any(a -> a != y && a != -y, map)
                    # conjugate mapping
                    # no redundant conjugations will occur if the original word is reduced
                    σ[x] = Word([-y]) * map * Word([y])
                end
            end
        end

        first += 1
        last -= 1
    end

    return σ
end
