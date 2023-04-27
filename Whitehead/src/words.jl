struct Word{T} <: AbstractVector{Letter{T}}
    letters::Vector{Letter{T}}

    Word(letters::AbstractVector{Letter{T}}) where {T} = new{T}(letters)
    
    Word(letters::AbstractVector{T}) where {T} = new{T}(map(x -> Letter(x), letters))
end

word(letters::AbstractVector{Letter{T}}) where {T} = wreduce(Word(letters))

# Base.IndexStyle(::Type{<:AbstractWord}) = IndexLinear()

# things to do with unity
Base.one(::Type{Word{T}}) where {T} = Word(Vector{T}())
Base.one(w::Word) = one(typeof(w))
Base.isone(w::Word) = length(w) == 0

# word operations
Base.:*(u::Word, v::Word) = append!(one(u), u, v)
Base.:^(w::Word, n::Integer) = repeat(w, n)
Base.:-(w::Word) = Word(map(l -> -l, reverse(w.letters)))
Base.inv(w::Word) = -w

# cutting operations
Base.popfirst!(w::Word) = popfirst!(w.letters)
Base.pop!(w::Word) = pop!(w.letters)
Base.resize!(w::Word, n) = resize!(w.letters, n)

# appending operations
Base.append!(u::Word, v::Word) = append!(u, v.letters)
Base.prepend!(u::Word, v::Word) = prepend!(u.letters, v)
Base.push!(w::Word, x::Letter) = push!(w.letters, x)

# miscellaneous
Base.size(w::Word) = size(w.letters)
Base.length(w::Word) = length(w.letters)
Base.@propagate_inbounds Base.getindex(w::Word, i::Int) = w.letters[i]
Base.@propagate_inbounds function Base.setindex!(w::Word, letter, idx::Int)
    return w.letters[idx] = letter
end
# this is needed for repeat() to work
function Base.similar(w::Word, ::Type, dims::Base.Dims{1})
    sim = one(w)
    resize!(sim, first(dims)) # note: resize! returns Vector, CANNOT return this
    return sim
end

to_string(w::Word) = isone(w) ? "ε" : join(w.letters, "·")

Base.show(io::IO, w::Word) = print(io, to_string(w))
Base.show(io::IO, m::MIME"text/plain", w::Word) = show(io, w)

function wreduce(w::Word)
    red = one(w)
    if isone(w)
        return red
    end
    for letter in w
        if !isone(red) && -red[end] == letter
            resize!(red, length(red) - 1)
        else
            push!(red, letter)
        end
    end
    return red
end

function wreduce_circ(w::Word)
    v = one(w) * w
    while -v[begin] == v[end]
        popfirst!(v)
        pop!(v)
    end
    return v
end
