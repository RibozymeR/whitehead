struct Powerset
    A
end

"""
The powerset of the collection `A`. Though this will actually be a vector, and `A` has to be indexable.
"""
powerset(A) = Powerset(A)

# iteration state contains:
#  - length(a) booleans
#  - one more for end detection
# TODO: special case for length(A) small -> use integer counting (can convert UInt to BitVector)

"""
WARNING: this will mutate iterator state
"""
function Base.iterate(p::Powerset, state = falses(length(p.A) + 1))
    if state[length(p.A) + 1]
        return nothing
    end

    # learned today: you can do Vector[BitArray] to get subset!
    elem = [p.A[i] for i in (1:length(p.A))[@view state[begin:end-1]]]

    i = 1
    while i <= length(state) && state[i]
        state[i] = false
        i += 1
    end
    state[i] = true

    return (elem, state)
end

Base.IteratorSize(::Powerset) = Base.HasLength()
Base.length(p::Powerset) = 2 ^ length(p.A)

Base.IteratorEltype(::Powerset) = Base.HasEltype()
Base.eltype(p::Powerset) = Vector{eltype(p.A)}
