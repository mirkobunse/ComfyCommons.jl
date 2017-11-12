# 
# ComfyYAML
# Copyright 2017 Mirko Bunse
# 
# 
# Comfortable utilities for dealing with YAML configuration files.
# 
# 
# ComfyYAML is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with ComfyYAML.  If not, see <http://www.gnu.org/licenses/>.
# 

module ComfyYAML


import YAML
export load_file, write_file, deepcopy, expand


"""
    load_file(filename, more_constrictors=nothing; kwargs...)

See `YAML.load_file`, which is extended here by keyword arguments.

You can specify additional configurations with the keyword arguments. For example, if you
run `load_file("bla.yml", more = "stuff")`, you read the `bla.yml` file and set the `more`
property to `stuff`. 
"""
function load_file(filename::AbstractString, more_constructors::YAML._constructor=nothing;
                   kwargs...)
    config = YAML.load_file(filename, more_constructors)
    for (k, v) in kwargs
        config[string(k)] = v
    end
    return config
end


#
# YAML file writing (may contribute to https://github.com/dcjones/YAML.jl/issues/29)
# 
"""
    write_file(filename, config)

Write the given configuration to a YAML file.
"""
function write_file(filename::AbstractString, config::Dict{Any,Any})
    if (!endswith(filename, ".yml"))
        warn("The provided filename $filename does not end on '.yml'. Still writing...")
    end
    file = open(filename, "w")
    write(file, config)
    close(file)
end

function write(io::IO, config::Dict{Any,Any}, level::Int=0, ignorelevel::Bool=false)
    for (i, tup) in enumerate(config)
        write(io, tup, level, ignorelevel ? i == 1 : false)
    end
end

function write(io::IO, config::Pair{Any,Any}, level::Int=0, ignorelevel::Bool=false)
    print(io, indent(string(config[1]) * ":", level, ignorelevel)) # print key
    if (typeof(config[2]) <: Dict || typeof(config[2]) <: AbstractArray)
        print(io, "\n")
    else
        print(io, " ")
    end
    write(io, config[2], level + 1) # print value
end

function write(io::IO, config::AbstractArray, level::Int=0, ignorelevel::Bool=false)
    for (i, elem) in enumerate(config)
        print(io, indent("- ", level))   # print sequence element character '-'
        write(io, elem, level + 1, true) # print value, ignore first indent
    end
end

write(io::IO, config::Any, level::Int=0, ignorelevel::Bool=false) =
    print(io, string(config) * "\n") # no indent required

indent(str::AbstractString, level::Int, ignorelevel::Bool=false) =
    repeat("  ", ignorelevel ? 0 : level) * str
# 
# end of file writing
# 


"""
    deepcopy(config)

Create a deep copy of the given `Dict` object.
"""
function deepcopy(config::Dict{Any,Any})
    buf = IOBuffer()
    write(buf, config)            # serialize
    YAML.load(String(take!(buf))) # deserialize
end


"""
    expand(config, property)

Expand the values of the given configuration with the content of the given property.

Expansion means that if `property` is an array with multiple elements, each element is
isolated and stored in the property in a dedicated copy of the configuration.
The `property` argument can be an array specifying a root-to-leaf path in the configuration
tree.
"""
expand(config::Dict{Any,Any}, property::Any) =
    [ Dict(config..., property => v) for v in _getindex(config, property) ]

# deeper in the configuration tree, it gets slightly more complex
function expand(config::Dict{Any,Any}, property::AbstractArray)
    [ begin
        c = deepcopy(config)
        _setindex!(c, v, property...)
        c
    end for v in vcat(_getindex(config, property...)...) ]
end

# functions that complement the usual indexing with varargs
# (does not override Base functions because that would screw up some Base functionality)
@inline @inbounds _getindex(val::Dict, keys::Any...) =
    if length(keys) > 1
        _getindex(val[keys[1]], keys[2:end]...)
    else
        val[keys[1]]
    end
@inline @inbounds _getindex(arr::AbstractArray, keys::Any...) =
    [ try _getindex(val, keys...) end for val in arr ]
@inline @inbounds _setindex!(val::Dict, value::Any, keys::Any...) = 
    if length(keys) > 1
        _setindex!(val[keys[1]], value, keys[2:end]...)
    elseif haskey(val, keys[1])
        val[keys[1]] = value
    end
@inline @inbounds _setindex!(arr::AbstractArray, value::Any, keys::Any...) =
    [ try _setindex!(val, value, keys...) end for val in arr ]


end # module
