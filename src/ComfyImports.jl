# 
# ComfyCommons.jl
# Copyright 2017-2020 Mirko Bunse
# 
# 
# Comfortable utility functions.
# 
# 
# ComfyCommons.jl is free software: you can redistribute it and/or modify
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
# along with ComfyCommons.jl.  If not, see <http://www.gnu.org/licenses/>.
# 
module ComfyImports # sub-module of ComfyCommons

"""
    importdir(dir; modulenames=String[], recursive=false, includehidden=false)
    
    Import all modules found in the given directory. Can recursively search the directory and can
    optionally include hidden files and folders.
    
    The optional 'modulenames' argument specifies which modules should be imported. If it is not empty,
    the directory will not be searched for all modules. Instead, only the named modules are imported
    in the given order. This is especially handy if not all modules should be loaded or if modules depend on
    each other (and thus import order is relevant).
"""
function importdir(dir::String; modulenames::Array{String,1}=String[],
                   recursive::Bool=false, includehidden::Bool=false)
                   
    # set up load path
    _importdir_pushpath(dir, recursive, includehidden)
    
    # import all modules (default)
    if length(modulenames) == 0
        _importdir_importall(dir, recursive, includehidden)
    
    # import named modules in order
    else
        for modulename in modulenames
            try
                Main.eval(Meta.parse("import $modulename")) # import module in REPL scope
                println("ComfyCommons: Imported $modulename.")
            catch e
                print_with_color(:red, stderr, "ERROR: Could not import $modulename (see stack trace)\n")
                throw(e)
            end
        end
    end
    
end

# sub-routine of importdir that recursively sets up the load path
function _importdir_pushpath(dir::String, recursive::Bool, includehidden::Bool)
    if isdir(dir) &&
           (includehidden || !startswith(split(dir, "/")[end], ".")) # include or exclude hidden folders
    
        push!(LOAD_PATH, dir) # base directory to LOAD_PATH
        if recursive # recursively add all sub-directories
            for filename in readdir(dir)
                _importdir_pushpath(joinpath(dir, filename), recursive, includehidden)
            end
        end
        
    end
end

# sub-routine of importdir that recursively performs the imports after the load path is set up
function _importdir_importall(dir::String, recursive::Bool, includehidden::Bool)
    if isdir(dir) &&
            (includehidden || !startswith(split(dir, "/")[end], ".")) # include hidden or only work on visible folders
    
        for filename in readdir(dir)
            filepath = joinpath(dir, filename)
            if isfile(filepath) &&
                    endswith(filename, ".jl") &&
                    (includehidden || !startswith(filename, ".")) # include or exclude hidden files
                try
                    modulename = replace(filename, ".jl"=>"")
                    Main.eval(Meta.parse("import $modulename")) # import module in REPL scope
                    println("ComfyCommons: Imported $modulename.")
                catch e
                    @warn "Could not import module in $filepath: $e" # only warn because this may not even be a module
                end
            elseif recursive
                _importdir_importall(filepath, recursive, includehidden)
            end
        end
        
    end
end


end
