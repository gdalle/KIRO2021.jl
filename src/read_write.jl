function read_instance(path::String)
    @assert endswith(path, ".json")
    file = JSON.parsefile(path)

    params = file["parameters"]

    params_bc = params["buildingCosts"]
    building_costs = BuildingCosts(;
        P=params_bc["productionCenter"],
        A=params_bc["automationPenalty"],
        D=params_bc["distributionCenter"],
    )

    params_pc = params["productionCosts"]
    production_costs = ProductionCosts(;
        P=params_pc["productionCenter"],
        A=params_pc["automationBonus"],
        D=params_pc["distributionCenter"],
    )

    params_rc = params["routingCosts"]
    routing_costs = RoutingCosts(;
        primary=params_rc["primary"], secondary=params_rc["secondary"]
    )

    capacity_cost = params["capacityCost"]

    params_c = params["capacities"]
    capacities = Capacities(; P=params_c["productionCenter"], A=params_c["automationBonus"])

    I = length(file["clients"])
    client_demands = fill(typemax(Int), I)
    client_coordinates = fill((Inf, Inf), I)
    for client in file["clients"]
        i, d, coords = client["id"], client["demand"], client["coordinates"]
        client_demands[i] = d
        client_coordinates[i] = Tuple(coords)
    end

    S = length(file["sites"])
    site_coordinates = fill((Inf, Inf), S)
    for site in file["sites"]
        s, coords = site["id"], site["coordinates"]
        site_coordinates[s] = Tuple(coords)
    end

    ssd = file["siteSiteDistances"]
    site_site_distances = collect(ssd[s1][s2] for s1 in 1:S, s2 in 1:S)
    scd = file["siteClientDistances"]
    site_client_distances = collect(scd[s][i] for s in 1:S, i in 1:I)

    instance = Instance(;
        building_costs=building_costs,
        production_costs=production_costs,
        routing_costs=routing_costs,
        capacity_cost=capacity_cost,
        capacities=capacities,
        client_demands=client_demands,
        client_coordinates=client_coordinates,
        site_coordinates=site_coordinates,
        site_site_distances=site_site_distances,
        site_client_distances=site_client_distances,
    )
    return instance
end

function read_solution(path::String, instance::Instance)
    @assert endswith(path, ".json")
    file = JSON.parsefile(path)

    I, S = nbclients(instance), nbsites(instance)

    is_production_center = fill(false, S)
    is_automated = fill(false, S)
    is_distribution_center = fill(false, S)
    distribution_parents = fill(0, S)
    client_parents = fill(0, I)

    unique_prod_ids = Set{Int}(
        prod_center["id"] for prod_center in file["productionCenters"]
    )
    @assert length(unique_prod_ids) == length(file["productionCenters"])
    for prod_center in file["productionCenters"]
        s, a = prod_center["id"], prod_center["automation"]
        is_production_center[s] = true
        is_automated[s] = a
    end

    unique_dist_ids = Set{Int}(
        dist_center["id"] for dist_center in file["distributionCenters"]
    )
    @assert length(unique_dist_ids) == length(file["distributionCenters"])
    for dist_center in file["distributionCenters"]
        s, p = dist_center["id"], dist_center["parent"]
        is_distribution_center[s] = true
        distribution_parents[s] = p
    end

    unique_client_ids = Set{Int}(client["id"] for client in file["clients"])
    @assert length(unique_client_ids) == length(file["clients"])
    for client in file["clients"]
        i, s = client["id"], client["parent"]
        client_parents[i] = s
    end

    sol = Solution(;
        is_production_center=is_production_center,
        is_automated=is_automated,
        is_distribution_center=is_distribution_center,
        distribution_parents=distribution_parents,
        client_parents=client_parents,
    )
    return sol
end

function write_solution(sol::Solution, path::String)
    @assert endswith(path, ".json")

    I, S = nbclients(sol), nbsites(sol)
    soldict = Dict("productionCenters" => [], "distributionCenters" => [], "clients" => [])

    for s in 1:S
        if sol.is_production_center[s]
            push!(
                soldict["productionCenters"],
                Dict("id" => s, "automation" => Int(sol.is_automated[s])),
            )
        elseif sol.is_distribution_center[s]
            push!(
                soldict["distributionCenters"],
                Dict("id" => s, "parent" => sol.distribution_parents[s]),
            )
        end
    end

    for i in 1:I
        push!(soldict["clients"], Dict("id" => i, "parent" => sol.client_parents[i]))
    end

    open(path, "w") do file
        JSON.print(file, soldict)
    end
end
