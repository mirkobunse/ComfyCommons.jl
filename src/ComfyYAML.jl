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
export load_file


# add kwargs to load_file from YAML
function load_file(filename::AbstractString, more_constructors::YAML._constructor=nothing;
                   kwargs...)
    config = YAML.load_file(filename, more_constructors)
    for (k, v) in kwargs
        config[string(k)] = v
    end
    return config
end


expand(config::Dict{Any,Any}, property::Any) =
    [ Dict(config..., property => v) for v in config[property] ]


# TODO write YAML files (may contribute to https://github.com/dcjones/YAML.jl/issues/29)


end # module
