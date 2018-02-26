# 
# ComfyCommons.jl
# Copyright 2017, 2018 Mirko Bunse
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
module ComfyCommons


export Git, Yaml, Pgfplots, info


# sub-modules
include("git.jl")
include("yaml.jl")
include("pgfplots.jl")


"""
    info(msg...)

Print a log message to the console, prefixed by the current process ID and a date time string.
"""
info(msg...) =
    Base.info(msg..., prefix="[$(myid())] $(Dates.format(now(), "yy-mm-dd HH:MM:SS")): ")


end # module
