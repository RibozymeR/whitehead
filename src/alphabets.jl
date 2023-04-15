struct Letter{T}
    elem::T
    inv::Bool

    Letter(elem::T) where {T} = new{T}(elem, false)

    Letter(elem::T, inv::Bool) where {T} = new{T}(elem, inv)
end

Base.:-(l::Letter) = Letter(l.elem, !l.inv)

Base.show(io::IO, l::Letter) = print(io, l.elem, l.inv ? "⁻¹" : "")

struct Alphabet{T}
    letters::Vector{Letter{T}}

    Alphabet(letters::AbstractVector{Letter{T}}) where {T} = new{T}(letters)

    Alphabet(generators::AbstractVector{T}) where {T} = new{T}([map(x -> Letter(x, false), generators);map(x -> Letter(x, true), generators)])
end

Base.length(A::Alphabet) = length(A.letters)
Base.iterate(A::Alphabet) = iterate(A.letters)
Base.iterate(A::Alphabet, state) = iterate(A.letters, state)
