---
layout: default_toc
---



### Getting Started

To get started with ComfyCommons, simply paste the provided code directly into your Julia REPL (for installation),
into your `~/.julia/config/startup.jl` file (for general kernel initialization), and into your project-specific
`_init.jl` files.

---



## Installation

To install the current version of ComfyCommons, get into the package administration mode of the Julia REPL (v0.7 and higher)
by typing `]`.

      (v0.7) pkg> add https://github.com/mirkobunse/ComfyCommons.jl.git



## Project-specific Initialization

Inside `pwd/_init.jl`, you can initialize the kernel specifically for your
project:

      # pwd/_init.jl, as included when julia is started from pwd
      
      import ComfyCommons
      
      # include all modules from the project's source folder pwd/src
      ComfyCommons.Imports.importdir("src")
      
You can tell `importdir` to work recursively for all sub-directories of the specified directory.



## Git Utilities

TODO

## YAML Utilities

TODO

## PGFPlots Utilities

TODO



## Documentation

All of the provided functions are documented. To view the documentation, type a question mark followed by
the function name into your Julia REPL:

```julia
julia> using ComfyCommons
julia> ?ComfyCommons.importdir
```



