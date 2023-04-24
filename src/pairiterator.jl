struct PairIterator
    iter
end

pairs(iter) = PairIterator(iter)

# pair iteration state contains:
#  - iteration state of base iterator
#  - first element
# TODO: deduplication

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
        elem2 = elem
    else
        (elem2, _) = i2
    end

    # element is (first, second)
    # state is (first state, first elem)
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

    # element is (this one, next one)
    # state is (next state, first elem)
    return ((elem, elem2), (nextstate, first))
end

Base.IteratorSize(::PairIterator) = Base.HasLength()
Base.length(p::PairIterator) = length(p.iter)

Base.IteratorEltype(::PairIterator) = Base.HasEltype()
Base.eltype(p::PairIterator) = eltype(p.iter)
