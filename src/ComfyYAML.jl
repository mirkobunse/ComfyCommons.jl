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
export load_file, write_file


# add kwargs to load_file from YAML
function load_file(filename::AbstractString, more_constructors::YAML._constructor=nothing;
                   kwargs...)
    config = YAML.load_file(filename, more_constructors)
    for (k, v) in kwargs
        config[string(k)] = v
    end
    return config
end


"""
    expand(config, property)

TODO
"""
function expand(config::Dict{Any,Any}, property::AbstractArray)
    [ error("Not yet implemented") for v in config[property...] ]
end

expand(config::Dict{Any,Any}, property::Any) =
    [ Dict(config..., property => v) for v in config[property] ]

@inline @inbounds Base.getindex(val::Dict, keys::Any...) = val[keys[1]][keys[2:end]...]
@inline @inbounds Base.getindex(arr::AbstractArray, keys::Any...) =
    [ try val[keys...] end for val in arr ]

@inline @inbounds Base.setindex!(val::Dict, value::Any, keys::Any...) = 
    val[keys[1]][keys[2:end]...] = value
@inline @inbounds Base.setindex!(arr::AbstractArray, value::Any, keys::Any...) =
    [ try val[keys...] = value end for val in arr ]

# write YAML files (may contribute to https://github.com/dcjones/YAML.jl/issues/29)
function write_file(filename::AbstractString, config::Dict{Any,Any})
    if (!endswith(filename, ".yml"))
        warn("The provided filename $filename does not end on '.yml'. Still writing...")
    end
    file = open(filename, "w")
    write(file, config)
    close(file)
end

# generic writing
function write(io::IO, config::Dict{Any,Any}, level::Int=0, ignorelevel::Bool=false)
    for (i, tup) in enumerate(config)
        write(io, tup, level, ignorelevel ? i == 1 : false)
    end
end

# pairs are printed in 'key: value' form, where value may spend several lines
function write(io::IO, config::Pair{Any,Any}, level::Int=0, ignorelevel::Bool=false)
    print(io, indent(config[1] * ":", level, ignorelevel)) # print key
    if (typeof(config[2]) <: Dict || typeof(config[2]) <: AbstractArray)
        print(io, "\n")
    else
        print(io, " ")
    end
    write(io, config[2], level + 1)             # print value, first item not indented
end

# elements in arrays are written in their own lines, preceded by '-'
function write(io::IO, config::AbstractArray, level::Int=0, ignorelevel::Bool=false)
    for (i, elem) in enumerate(config)
        print(io, indent("- ", level))   # print sequence element character '-'
        write(io, elem, level + 1, true) # print value, ignore first indent
    end
end

# other values
write(io::IO, config::Any, level::Int=0, ignorelevel::Bool=false) =
    print(io, string(config) * "\n") # no indent ever required

indent(str::AbstractString, level::Int, ignorelevel::Bool=false) =
    repeat("  ", ignorelevel ? 0 : level) * str


end # module
