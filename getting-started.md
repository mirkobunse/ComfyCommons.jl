---
layout: default_toc
---



### Getting Started

To get started with ComfyBase, simply paste the provided code directly into your Julia REPL (for installation),
into your home directory `~/.juliarc.jl` (for general kernel initialization), and into your project-specific
`juliarc.jl` files.

---



## Installation

To install the current version of ComfyBase, type into your Julia REPL (v0.5):

      Pkg.clone("git://github.com/mirkobunse/ComfyBase.jl.git")

You can update your installation any time like this:

      Pkg.checkout("git://github.com/mirkobunse/ComfyBase.jl.git")



## Usage

ComfyBase is best used inside your `~/.juliarc.jl`, which specifies Julia code that is run
any time you start a Julia kernel.

You can use `ComfyBase.loadrc` to load project-specific `juliarc.jl` files that reside in
your project's base directories.
To do so every time Julia is started, add the following lines to your home directory `~/.juliarc.jl`:

      # ~/.juliarc.jl
      
      using ComfyBase
      ComfyBase.loadrc() # include the juliarc.jl in the current working directory
      
When you start Julia now from some directory `pwd` (e.g., some project's base directory), this
will include the file at `pwd/juliarc.jl` on startup.

Inside `pwd/juliarc.jl`, you can initialize the kernel specifically for your
project:

      # pwd/juliarc.jl, as included by ~/.juliarc.jl when julia is started from pwd
      
      using ComfyBase
      
      # include all modules from the project's source folder pwd/src
      ComfyBase.importdir("./src")
      
      # overload Base.reload with no arguments to reload all modules
      Base.reload() = ComfyBase.reloaddir("./src")
      
You can tell `ComfyBase.importdir` and `ComfyBase.reloaddir` to import/reload only specific
modules in a certain order (to capture dependencies between) and to work recursively for all
subdirectories of the specified directory.



## Documentation

All of the provided functions are documented. To view the documentation, type a question mark followed by
the function name into your Julia REPL:

```julia
julia> using ComfyBase
julia> ?ComfyBase.loadrc
```



