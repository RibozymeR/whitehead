module Whitehead

# basic dependencies
include("alphabets.jl")
include("words.jl")
include("automorphisms.jl")

# three files for the actual algorithm
include("whitehead_minimization.jl")
include("whiteheadaut.jl")
include("whiteheadmulti.jl")

# just for testing
wh_name() = "Whitehead"

end # module Whitehead
