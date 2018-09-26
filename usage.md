---
layout: default_toc
---



## Installation

Get into the package administration mode of the Julia REPL (v0.7 and higher) by typing a
closing square bracket `]`. Add the package from the Git repository:

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



## Logging

By default, Julia does not log time stamps and process IDs, which is relevant information
particularly in distributed applications.

ComfyCommons provides a custom logger type which prints these informations in the message
headers. Make this logger the default:

```julia
ComfyCommons.Logging.set_global_logger()
```



## Git

The sub-module `ComfyCommons.Git` retrieves basic information about Git repositories inside
any current working directory.

- `isrepo()` returns true if the current working directory `pwd()` is a Git repository.
- `commithash()` returns the ID of the last commit.
- `remoteurl(remote="origin")` returns the URL of a remote repository.
- `haschanges(path...=".")` returns true if any of the given paths contains staged or
  un-staged changes which are not yet committed.

You should store this information in generated files (experimental results, plots, ...) to
keep track of how they have been generated.



## YAML

`ComfyCommons.Yaml` is used to manipulate YAML configuration files.

- `load_file(filename; kwargs...)` works like the original function from the
  [YAML](https://github.com/BioJulia/YAML.jl) package,
  but is extended by arbitrary keyword arguments which become part of the returned
  configuration.
- `write_file(filename, config)` stores a formatted YAML configuration at the given file path.
- `interpolate(config, property; kwargs...)` interpolates the value of the given property, e.g.
  `user: $firstname-$lastname`, with the values referenced therein (e.g. `firstname`).
  Keyword arguments supply additional values to be interpolated. For instance, if `lastname`
  is not contained in the configuration, specifying `lastname="Meier"` as a keyword
  argument will interpolate this value into the `user` property.
- `expand(config, property)` expands a list stored in the given property into multiple
  configurations. Use this function to perform meta-configuration, generating a set of
  configurations from a single file of higher abstraction.



## PGFPlots

`ComfyCommons.Pgfplots` enhances LaTeX plot exports by overriding some internals of the
[PGFPlots](https://github.com/JuliaTeX/PGFPlots.jl) package.

- You can provide a template string, in which the placeholder sub-string `{PLOT}` is replaced
  by the generated TeX code. The template is set with `setpgftemplate(template)`.
- In contrast to [PGFPlots](https://github.com/JuliaTeX/PGFPlots.jl), no `tikzpicture`
  environment surrounds the generated code. If you like to have this environment, please set
  the template accordingly.
- Last but not least, the format of the generated Tex code is improved.



## Further Documentation

The documentation of all functions is accessible from the Julia REPL.
Type a question mark to get into the help mode, followed by a function name:

    julia> using ComfyCommons
    help?> ComfyCommons.Imports.importdir



