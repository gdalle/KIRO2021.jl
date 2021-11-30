function dumb_solver(instance::Instance)
    I, S = nbclients(instance), nbsites(instance)
    is_production_center = vcat(true, fill(false, S - 1))
    is_automated = fill(false, S)
    is_distribution_center = fill(false, S)
    distribution_parents = fill(0, S)
    client_parents = fill(1, I)
    solution = Solution(;
        is_production_center=is_production_center,
        is_automated=is_automated,
        is_distribution_center=is_distribution_center,
        distribution_parents=distribution_parents,
        client_parents=client_parents,
    )
    return solution
end

"""
    prepare_submission(solver, instances_folder, solutions_folder, group)

Read instances from the `instance_folder`, use `solver` to generate solutions, and then write these solutions in the `solutions_folder` with the right `group` number.
"""
function prepare_submission(;
    solver::Function=dumb_solver,
    instances_folder::String="instances",
    solutions_folder::String="solutions",
    group::Int=42,
)
    names = ["tiny", "small", "medium", "large"]
    total_cost = 0.0
    for name in names
        @info "Solving $name instance"
        instance = read_instance(joinpath(instances_folder, "KIRO-$name.json"))
        sol = solver(instance)
        feasible, message = is_feasible(sol, instance)
        if feasible
            write_solution(sol, joinpath(solutions_folder, "KIRO-$name-sol_$group.json"))
            total_cost += cost(sol, instance)
        else
            @warn message
            total_cost += Inf
        end
    end
    @info "Total cost: $total_cost"
    return true
end
