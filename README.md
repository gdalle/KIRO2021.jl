# KIRO2021.jl

This repository contains Julia code for the 2021 edition of the [KIRO](https://kiro.enpc.org/index.php).

## Getting started

First, you need to install Julia. A complete tutorial can be found on [this page](https://gdalle.github.io/IntroJulia/). Then, you have two options:

### Simple import

You can import all useful functions by opening a Julia REPL wherever you want and running the following code:

```julia
julia> using Pkg

julia> Pkg.add("https://github.com/gdalle/KIRO2021.jl")

julia> using KIRO2021
```

This does not include the instance files.

### Complete download

You can also download (or fork) the entire repository and use it as a starting point for your own work. To import all useful functions, you will need to activate the package environment first by running the following code *from the root of the downloaded folder*:

```julia
julia> using Pkg

julia> Pkg.activate(".")

julia> using KIRO2021
```

From there, a single line of code can generate dumb solutions to all the instances provided:

```julia
julia> prepare_submission()
```