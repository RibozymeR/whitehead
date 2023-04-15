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

function Base.:*(σ::Automorphism, w::Word)
    result = one(w)
    for x in w
        append!(result, σ[x])
    end
    return result
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
