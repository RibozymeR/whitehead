using Test
using Whitehead

@testset "words" begin
    X = Alphabet([:x, :y, :z])
    x = Word([:x])
    @test -x == Word([Letter(:x, true)])
end