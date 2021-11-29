function is_feasible(sol::Solution, instance::Instance)::Tuple{Bool,String}
    I, S = nbclients(instance), nbsites(instance)

    isprod = sol.is_production_center
    isauto = sol.is_automated
    isdist = sol.is_distribution_center
    distpar = sol.distribution_parents
    clientpar = sol.client_parents

    for s in 1:S
        if isprod[s]
            if isdist[s]
                return false, "Center with 2 types"
            elseif distpar[s] != 0
                return false, "Production center with a parent"
            end
        elseif isdist[s]
            if isauto[s]
                return false, "Automated distribution center"
            elseif !(1 <= distpar[s] <= S)
                return false, "Distribution center without a valid parent"
            elseif !isprod[distpar[s]]
                return false, "Distribution center whose parent is not a production center"
            end
        else
            if isauto[s]
                return false, "Automated empty site"
            elseif distpar[s] != 0
                return false, "Empty site with a parent"
            end
        end
    end

    for i in 1:I
        if !(1 <= clientpar[i] <= S)
            return false, "Client without a valid parent"
        elseif !isprod[clientpar[i]] && !isdist[clientpar[i]]
            return false, "Client whose parent is an empty site"
        end
    end

    return true, "The solution is feasible"
end

function building_cost(s::Int, sol::Solution, instance::Instance)
    s == 0 && return 0.
    cᵇ = instance.building_costs
    if sol.is_production_center[s]
        aₛ = sol.is_automated[s]
        return cᵇ.P + aₛ * cᵇ.A
    elseif sol.is_distribution_center[s]
        return cᵇ.D
    else
        return 0.0
    end
end

function production_cost(i::Int, sol::Solution, instance::Instance)
    i == 0 && return 0.
    cᵖ = instance.production_costs
    dᵢ = instance.client_demands[i]
    sᵢ = sol.client_parents[i]
    if sol.is_production_center[sᵢ]
        aₛ = sol.is_automated[sᵢ]
        return dᵢ * (cᵖ.P - aₛ * cᵖ.A)
    elseif sol.is_distribution_center[sᵢ]
        pₛ = sol.distribution_parents[sᵢ]
        aₚ = sol.is_automated[pₛ]
        return dᵢ * (cᵖ.P - aₚ * cᵖ.A + cᵖ.D)
    else
        return Inf
    end
end

function routing_cost(i::Int, sol::Solution, instance::Instance)
    i == 0 && return 0.
    cʳ = instance.routing_costs
    Δₛₛ = instance.site_site_distances
    Δₛᵢ = instance.site_client_distances
    dᵢ = instance.client_demands[i]
    sᵢ = sol.client_parents[i]
    if sol.is_production_center[sᵢ]
        return dᵢ * cʳ.secondary * Δₛᵢ[sᵢ, i]
    elseif sol.is_distribution_center[sᵢ]
        pₛ = sol.distribution_parents[sᵢ]
        return dᵢ * (cʳ.primary * Δₛₛ[pₛ, sᵢ] + cʳ.secondary * Δₛᵢ[sᵢ, i])
    else
        return Inf
    end
end

function capacity_cost(s::Int, sol::Solution, instance::Instance)
    s == 0 && return 0.
    cᵘ = instance.capacity_cost
    u = instance.capacities
    if sol.is_production_center[s]
        aₛ = sol.is_automated[s]
        sumD = 0
        for i = 1:nbclients(instance)
            dᵢ = instance.client_demands[i]
            if path_exists(s, i, sol)
                sumD += dᵢ
            end
        end
        return cᵘ * max(0, sumD - (u.P + aₛ * u.A))
    elseif sol.is_distribution_center[s]
        return 0.0
    else
        return 0.0
    end
end

function building_cost(sol::Solution, instance::Instance)
    return sum(building_cost(s, sol, instance) for s in 1:nbsites(instance))
end

function production_cost(sol::Solution, instance::Instance)
    return sum(production_cost(i, sol, instance) for i in 1:nbclients(instance))
end

function routing_cost(sol::Solution, instance::Instance)
    return sum(routing_cost(i, sol, instance) for i in 1:nbclients(instance))
end

function capacity_cost(sol::Solution, instance::Instance)
    return sum(capacity_cost(s, sol, instance) for s in 1:nbsites(instance))
end

function cost(sol::Solution, instance::Instance; verbose::Bool=false)
    bc = building_cost(sol, instance)
    cc = capacity_cost(sol, instance)
    pc = production_cost(sol, instance)
    rc = routing_cost(sol, instance)
    total_cost = bc + cc + pc + rc
    if verbose
        println("Building cost: $bc")
        println("Capacity cost: $cc")
        println("Production cost: $pc")
        println("Routing cost: $rc")
        println("Total cost: $total_cost")
    end
    return total_cost
end
