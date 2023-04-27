using Test
using Whitehead

WH = Whitehead

@testset "configuration" begin
    @test WH.wh_name() == "Whitehead"
end

@testset "words" begin
    X = WH.Alphabet([:x, :y, :z])
    x = WH.Word([:x])
    @test -x == WH.Word([WH.Letter(:x, true)])
end
