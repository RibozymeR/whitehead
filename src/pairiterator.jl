struct PairIterator{T}
    iter::T
end

pairs(iter) = PairIterator(iter)

# the pair iteration state contains:
#  - iteration state
#  - first element

function Base.iterate(pairs::PairIterator)
    i = iterate(pairs.iter)
    # if iterator is empty, no pairs
    if i === nothing
        return nothing
    end
    (elem, state) = i

    i2 = iterate(pairs.iter, state)
    # if iterator has 1 element, no pairs
    if i2 === nothing
        return ((elem, elem), (state, elem))
    end
    (elem2, _) = i2

    # our element is (first, second)
    # state is (first state, elem)
    return ((elem, elem2), (state, elem))
end

function Base.iterate(pairs::PairIterator, state)
    (substate, first) = state

    i = iterate(pairs.iter, substate)
    # no more pairs
    if i === nothing
        return nothing
    end
    (elem, nextstate) = i

    i2 = iterate(pairs.iter, nextstate)
    # `i` was at last element
    if i2 === nothing
        elem2 = first
    else
        (elem2, _) = i2
    end

    return ((elem, elem2), (nextstate, first))
end

Base.IteratorSize(::PairIterator) = Base.HasLength()
Base.length(p::PairIterator) = length(p.iter)

Base.IteratorEltype(::PairIterator) = Base.HasEltype()
Base.eltype(p::PairIterator) = eltype(p.iter)
