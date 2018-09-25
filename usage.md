---
layout: default_toc
---



## Installation

Get into the package administration mode of the Julia REPL (v0.7 and higher) by typing `]`
(a closing square bracket). Add the package from the git repository:

      (v0.7) pkg> add https://github.com/mirkobunse/ComfyCommons.jl.git



## Project-specific Initialization

ComfyCommons can import all modules contained in a directory. This is helpful in projects
which consist of multiple, loosely coupled modules. You may paste the following code into
the `_init.jl` file of your project:

```julia
import ComfyCommons

# include all modules from the project's source folder
ComfyCommons.Imports.importdir("src")
```
      
You can also tell `importdir` to work recursively, or to include only specified modules.



## Git Utilities

*TODO* (see the [documentation](#documentation) below)

## YAML Utilities

*TODO* (see the [documentation](#documentation) below)

## PGFPlots Utilities

*TODO* (see the [documentation](#documentation) below)



## Documentation

The documentation of all provided functions is accessible from the Julia REPL.
Type a question mark to get into the help mode. Then type any function name:

    julia> using ComfyCommons
    help?> ComfyCommons.importdir



