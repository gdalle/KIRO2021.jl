using KIRO2021
using Test

@testset verbose = true "KIRO2021.jl" begin
    @testset verbose = true "Tiny instance" begin
        tiny_instance = read_instance(joinpath("..", "instances", "KIRO-tiny.json"))
        tiny_solution0 = read_solution(
            joinpath("..", "solutions", "KIRO-tiny-sol0.json"), tiny_instance
        )
        tiny_solution1 = read_solution(
            joinpath("..", "solutions", "KIRO-tiny-sol1.json"), tiny_instance
        )
        @test is_feasible(tiny_solution0, tiny_instance)[1]
        @test is_feasible(tiny_solution1, tiny_instance)[1]
        @test cost(tiny_solution0, tiny_instance) ≈ 7.9303232e6
        @test cost(tiny_solution1, tiny_instance) ≈ 7.7956339e6
    end
end
