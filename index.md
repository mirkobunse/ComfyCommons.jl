---
layout: default_toc
---



### The Comfy Workflow Manifesto

...or let's call it *Julia Workflow Considerations*. Yeah, I like that one.

This article is meant to discuss one proven way of interacting with the Julia language
and its kernel. It proclaims some paradigms that can help newcomers to avoid some
pitfalls and may be interesting for well-tried Julia developers, as well.
If you are totally new to the Julia language you should start with the basics, as presented
in [the Julia Getting-Started guide](https://docs.julialang.org/en/stable/manual/getting-started/)
and the tutorials linked by that article.

The workflow suggested in this article can be followed conveniently using the
[the ComfyBase.jl package](package).
Please share your thoughts about the manifesto's paradigms and the package in
[the issues](https://github.com/mirkobunse/ComfyBase.jl/issues) of the ComfyBase GitHub project.

---

&nbsp;



# Julia Workflow Considerations

[The Julia language](https://julialang.org/) has one of its greatest strengths in
enabling programmers to explore their data conveniently.
Powerful and easy-to-write aggregations can be carried out using
[the popular DataFrames package](https://dataframesjl.readthedocs.io/en/latest/).
Aggregated values can be plotted with [Gadfly](http://gadflyjl.org/stable/) or some
other plotting library.
Usually, the exploratory part of programming is done directly in the Julia REPL
or in an [IJulia](https://github.com/JuliaLang/IJulia.jl) notebook.

When some exploratory code matures, it should be transformed into a Julia module that
can be reused across projects. Julia provides a number of concepts that can
be used to optimize code for runtime efficiency, including parallelization, optionally
fixed parameter types and precompilation.



## The role of JIT compilation

Julias just-in-time (JIT) compilation only translates your program code into something
your machine can execute when this is required, i.e., when a function is called the
first time.
This is inevitably causing long execution times for every first function call.
Subsequent calls to a compiled function will be super fast, though.

For the exploration of data, JIT compilation imposes the following paradigm:

<p style="margin-left: 6%"><big>Keep your kernel alive</big></p>

Do not call `julia myscript.jl` from the command line repeatedly to execute some
script that you develop currently.
Doing so will result in the kernel shutting down immediately after each call. You
will not benefit from the JIT compilation because on every call of `julia myscript.jl`
the kernel will have to compile everything.

If you would like to run that same script repeatedly, start `julia` (without arguments)
to open the REPL. The script can be executed by including it from the living kernel:

```julia
julia> include("myscript.jl")
```

Try this multiple times!
The second run is fast, huh? You can even modify the script before each inclusion.
You will still be benefiting from the JIT compilation speedup, because all compiled
dependencies are kept in the active kernel.

By the way, IJulia notebooks keep their kernel alive all the time. Modifying cells
and executing them repeatedly is a great way to work with Julia, especially if you
do not like to use the REPL.



## Module development

Julia modules provide a way to encapsule functionality that can be reused on multiple
occasions.
Having explored your data, it is often useful to mature your explorations (selection,
aggregation, plotting,...) into a module. When your data changes, you will be able to
re-run the module's functions with the new data, giving you the latest insights.
Some things like common low-level aggregations for multiple data sources or setting
your preferred defaults for plots can even be reused across projects.

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

You can do this easily:

```julia
julia> import MyModule
julia> MyModule.dostuff()

# ... modify the MyModule.dostuff function ...

julia> reload("MyModule")
julia> MyModule.dostuff() # changes are applied
```

You may have noticed that this example uses the `ìmport` statement instead of the more common
`using`. This is due to the fact that a module loaded with `using` can not be reloaded this way.



## Kernel initialization

On every start of the Julia kernel, a hidden file in your home directory named `~/.juliarc.jl` is executed.
Since this file is a Julia script, you can type in any Julia code that you consider useful for kernel
initialization. This may include `import` and `using` statements and function definitions.
Each time you start Julia, these imports and functions become available.

Initializing the kernel with the `~/.juliarc.jl` is a convenient way to

<p style="margin-left: 6%"><big>Tailor the kernel's initialization to your needs</big></p>

Take a minute and think about which modules you use (almost) every time. For me, this is
[the DataFrames package](https://dataframesjl.readthedocs.io/en/latest/).
Having the statement `using DataFrames` inside my `~/.juliarc.jl` prevents me from typing
this every time I start Julia. Similar statements for your usually used modules
will make your kernel ready for work on every start.

You may want to have kernel initialization that is specific to some project, like the import
of the project's modules or project-related function definitions.
Such initialization should always take place for the project in question, but definitely
not every time Julia starts.
Being more specific about the previous paradigm:

<p style="margin-left: 6%"><big>Base the kernel's initialization on your project</big></p>

You can realize such behavior by telling `~/.juliarc.jl` to automatically include an initialization file
in the current working directory. The working directory can be any project directory then,
based on where you start Julia from.
ComfyBase provides a method `loadrc` to support such workspace-specific kernel initialization
which nicely maps to the paradigms stated above.


