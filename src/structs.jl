Base.@kwdef struct BuildingCosts
    P::Float64
    A::Float64
    D::Float64
end

Base.@kwdef struct ProductionCosts
    P::Float64
    A::Float64
    D::Float64
end

Base.@kwdef struct RoutingCosts
    primary::Float64
    secondary::Float64
end

Base.@kwdef struct Capacities
    P::Int
    A::Int
end

Base.@kwdef struct Instance
    building_costs::BuildingCosts
    production_costs::ProductionCosts
    routing_costs::RoutingCosts
    capacity_cost::Float64
    capacities::Capacities
    client_demands::Vector{Int}
    client_coordinates::Vector{Tuple{Float64,Float64}}
    site_coordinates::Vector{Tuple{Float64,Float64}}
    site_site_distances::Matrix{Float64}
    site_client_distances::Matrix{Float64}
end

Base.@kwdef struct Solution
    is_production_center::Vector{Bool}
    is_automated::Vector{Bool}
    is_distribution_center::Vector{Bool}
    distribution_parents::Vector{Int}
    client_parents::Vector{Int}
end

nbclients(instance::Instance) = length(instance.client_coordinates)
nbclients(sol::Solution) = length(sol.client_parents)

nbsites(instance::Instance) = length(instance.site_coordinates)
nbsites(sol::Solution) = length(sol.is_production_center)

function path_exists(s::Int, i::Int, sol::Solution)
    sᵢ = sol.client_parents[i]
    return sᵢ == s || sol.distribution_parents[sᵢ] == s
end
