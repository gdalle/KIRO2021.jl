# KIRO2021.jl

This repository contains Julia code for the 2021 edition of the [KIRO](https://kiro.enpc.org/index.php).

## Getting started

First, you need to install Julia. A complete tutorial can be found on [this page](https://gdalle.github.io/IntroJulia/). Then, to import the `KIRO2021` package, open a Julia REPL and run the following code:

```julia
julia> using Pkg

julia> Pkg.add("https://github.com/gdalle/KIRO2021.jl")

julia> using KIRO2021
```

The function `prepare_submission` provides an example workflow to generate solutions. Type `?prepare_submission` in the REPL to know how to use it.

Note that the JSON files defining the instances have to be downloaded separately.