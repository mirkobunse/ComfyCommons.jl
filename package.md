---
layout: default_toc
---



### The ComfyBase.jl package

ComfyBase helps you follow the paradigms proclaimed by the Comfy Workflow Manifesto.
The following introduction maps the package functionality to these paradigms.
For more information, see the [Getting-Started](getting-started) guide.

---



## Project-specific kernel initialization

Project-specific kernel initialization is performed by including a file named `pwd/juliarc.jl` where `pwd` is the
current working directory. Note that this file is not executed by default, as it is not the `~/.juliarc.jl` file
that was presented for general kernel initialization.

```julia
# include the juliarc.jl in the current working directory.
julia> ComfyBase.loadrc()
```

I prefer to call `ComfyBase.loadrc()` in my global kernel initialization file `~/.juliarc.jl`.
This will make sure that project-specific kernel initialization is always performed based on where I start Julia from.

<p style="padding-left: 3ex; font-size: 80%; font-weight:bold; margin-bottom: 1em">
    Note: Why does the project-specific initialization file have the same name as the global one?
</p>
<p style="padding-left: 3ex; font-size: 80%;">
    First of all: It does not have to. You can provide any other file name by an optional argument of the `loadrc` function.
    The default is motivated by the fact that both files initialize the kernel.
    Moreover, a clear difference between the files already exists by their different directories:
    pwd is not your home directory.
    Also, pwd/juliarc.jl is not hidden, unlike ~/.juliarc.jl.
    This choice to not hide the file was made so that none of your colleagues will miss the pwd/juliarc.jl while ravaging your project directory.
</p>



## Importing and reloading multiple modules

In bigger projects one may like to import whole directories containing multiple module files and reload
them all at once. ComfyBase provides this functionality:

```julia
julia> import ComfyBase

# import all modules in the source directory
julia> ComfyBase.importdir("./src")

# Reload all modules in that directory
julia> ComfyBase.reloaddir("./src")
```


