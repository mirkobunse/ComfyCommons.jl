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
module Logging # sub-module of ComfyCommons

import Dates, Distributed, Printf
import Base.CoreLogging.global_logger
import Logging: ConsoleLogger, default_metafmt

export GlobalConsoleLogger, set_global_logger

"""
    set_global_logger(; date=false, seconds=false)

Replace the global `ConsoleLogger` with the `ComfyCommons.Logging.GlobalConsoleLogger`.
"""
set_global_logger(; kwargs...) = global_logger(GlobalConsoleLogger(; kwargs...))

"""
    GlobalConsoleLogger(; date=false, seconds=false)

Creates a copy of the global `ConsoleLogger` which prepends the date-time and the process
ID to all messages.

You can make this logger the default by calling:

    ComfyCommons.Logging.set_global_logger(; kwargs...)
"""
function GlobalConsoleLogger(; date=false, seconds=false)
    time_format = "HH:MM"
    if seconds
        time_format = "$time_format:SS" # append the seconds
    end
    if date
        time_format = "yy-mm-dd $time_format" # prepend the date
    end
    
    # prepend the process ID and the date-time to the default prefix
    _metafmt(level, _module, group, id, file, line) = begin
        color, prefix, suffix = default_metafmt(level, _module, group, id, file, line) # default format
        prefix = join([ "$(Printf.@sprintf "%2d" Distributed.myid())]",
                        Dates.format(Dates.now(), time_format),
                        prefix ], " ")
        color, prefix, suffix
    end
    
    gl = global_logger()
    return ConsoleLogger(gl.stream, gl.min_level, _metafmt, gl.show_limited,
                         gl.right_justify, gl.message_limits)
end

end
