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

Base.getindex(σ::Automorphism{T}, x::T) where {T} = σ[Letter(x)]
Base.setindex!(σ::Automorphism{T}, w::Word{T}, x::T) where {T} = σ[Letter(x)] = w

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
function nielsen(x::Letter{T}, y::Letter{T}, X::Alphabet{T}, prepend::Bool = false) where {T}
    σ = Automorphism(X)
    σ[x] = prepend ? Word([y, x]) : Word([x, y])
    return σ
end

"""
Whitehead automorphism mapping every `x` in `A` to `x·a`  
If `x` and `x⁻¹` are in `A`, maps `x` to `a⁻¹·x·a`
"""
function whitehead(A, a::Letter{T}, X::Alphabet{T}) where {T}
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
