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

export Imports, Logging, Git, Yaml, Pgfplots, confirm_exit

# sub-modules
include("imports.jl")
include("logging.jl")
include("git.jl")
include("yaml.jl")
include("pgfplots.jl")

"""
    confirm_exit()

Ask the user to confirm that he would like to exit the current session. Add the following
snippet to your `~/.julia/config/startup.jl` file to hide `Base.exit`:

    exit() = ComfyCommons.confirm_exit()
"""
function confirm_exit()
    print("ComfyCommons: Do you really want to exit? ([Y]/n): ")
    if !startswith(readline(stdin), "n")
        Base.exit()
    end
end

end # module
