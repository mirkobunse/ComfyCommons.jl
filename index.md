---
layout: default_toc
---



### The Comfy Workflow Manifesto

...or let's call it *Julia Workflow Recommendations*. Yeah, I like that one.

This article is meant to discuss one proven way of interacting with the
[Julia](https://julialang.org/) language.
It proclaims a few paradigms to help newcomers in avoiding some of the common pitfalls.
If you are totally new to the Julia language you should start with the basics, as presented
in [the Getting-Started guide](https://docs.julialang.org/en/stable/manual/getting-started/).

---

&nbsp;



# Julia Workflow Recommendations

A major strength of Julia is the exploration of data and implementation alternatives.
Usually, the exploratory part of programming is done directly in the Julia REPL
or in an [IJulia](https://github.com/JuliaLang/IJulia.jl) notebook.

When some exploratory code matures, developing it to a Julia module allows for reuse across
projects. Julia provides a number of concepts used in optimizing code for runtime
efficiency, including parallelization, explicit parameter types and pre-compilation.
In fact, the Julia developers wanted to create a language in which prototypes can be
implemented quickly - like in a scripting language - while mature and
lightning-fast code can be written in that same language.
In contrast, Python developers sometimes need to write parts of their code in C/C++ in order
to create efficient software.



## The role of JIT compilation

Julias just-in-time (JIT) compilation translates your Julia functions into something your
machine can execute. However, this translation is only performed when immediately required,
i.e. when a function is called for the first time.
This is inevitably causing long execution times for every first function call.
Subsequent calls to a compiled function will be super fast, though.

For the explorative programming, JIT compilation imposes the following paradigm:

<p style="margin-left: 6%"><big>Keep your kernel alive</big></p>

Do not call `julia myscript.jl` from the command line repeatedly to execute some
script which you develop currently.
Doing so would result in the kernel shutting down immediately after each call. You would
not benefit from the JIT compilation because on every call of `julia myscript.jl`
the kernel will have to re-compile everything.

If you would like to run that same script repeatedly, e.g. for development purposes,
start `julia` (without arguments) to open the REPL. The script can be executed by including
it from the living kernel:

```julia
julia> include("myscript.jl")
```

Try this multiple times!
The second run is fast, huh? You can even modify the script before each inclusion.
You will still be benefiting from the JIT speedup, because all compiled
dependencies are kept in the active kernel.

By the way, IJulia notebooks keep their kernel alive all the time. Modifying cells
and executing them repeatedly is a great way to work with Julia, especially if you
do not like to use the REPL.



## Module development

Julia modules provide a way to encapsule functionality that can be reused on multiple
occasions.
Having explored your data, it is often useful to mature your explorations (selection,
aggregation, plotting,...) into a module for later reuse.

Therefore:

<p style="margin-left: 6%"><big>Mature your code by writing modules</big></p>

Do not rely on scripts or notebook cells alone. In a bigger project, they can
become confusing quite quickly.
Instead, create reusable functions in modules that can be accessed from a more
high-level script or notebook.

To load a custom module, you have to add its path to the julia `LOAD_PATH` before
importing it:

```julia
julia> push!(LOAD_PATH, "/path/to/MyModule.jl")
julia> import MyModule
```

Now, its functions are available:

```julia
julia> MyModule.dostuff()
```


## Modules in the living kernel

Developing a module requires frequent testing of its functions. Keeping in mind the first
paradigm _keep your kernel alive_, one should reload the latest version of the module
from the living kernel instead of restarting julia frequently. Consisely:

<p style="margin-left: 6%"><big>Import your modules and reload on modification</big></p>

You can do this easily, using [the beautiful Revise package](https://github.com/timholy/Revise.jl):

```julia
julia> using Revise
julia> import MyModule
julia> MyModule.dostuff()

# ... modify the MyModule.dostuff function ...

julia> revise() # reload all changes
julia> MyModule.dostuff() # changes are applied
```



## Kernel initialization

On every start of the Julia kernel, a start-up file `~/.julia/config/startup.jl` is executed.
Since this file is a Julia script, you can type in any Julia code that you consider useful for kernel
initialization. This may include `import` and `using` statements and function definitions.
Each time you start Julia, these imports and functions become available.

Initializing the kernel with the start-up file is a convenient way to

<p style="margin-left: 6%"><big>Tailor the kernel's initialization to your needs</big></p>

Take a minute and think about which modules you use (almost) every time. For me, this is
[the DataFrames package](https://dataframesjl.readthedocs.io/en/latest/) and
[Revise](https://github.com/timholy/Revise.jl).
Having the statement `using Revise, DataFrames` inside my start-up file prevents me from
typing this line every time I start Julia.

You may want to have kernel initialization that is specific to some project, like the import
of the project's modules or project-related function definitions.
Such initialization should always take place for the project in question, but definitely
not every time Julia starts.
Being more specific about the previous paradigm:

<p style="margin-left: 6%"><big>Base the kernel's initialization on your project</big></p>

You can realize such behavior by telling the start-up file to automatically include an
initialization file in the current working directory. The working directory can be any
project directory then, based on where you start Julia from.
Simply paste the following line into your start-up file:

```julia
isfile("_init.jl") && include(joinpath(pwd(), "_init.jl"))
```

Now, whenever you start Julia from a directory which contains a file named `_init.jl`,
Julia will execute this file to initialize your kernel.

