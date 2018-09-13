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
module Logging # sub-module of ComfyCommons

import Dates, Distributed, Printf
import Base.CoreLogging.global_logger
import Logging: ConsoleLogger, default_metafmt

export GlobalConsoleLogger, set_global_logger

"""
    set_global_logger()

Replace the global `ConsoleLogger` with the `ComfyCommons.Logging.GlobalConsoleLogger`.
"""
set_global_logger() = global_logger(GlobalConsoleLogger())

"""
    GlobalConsoleLogger()

Creates a copy of the global `ConsoleLogger`, prepending the date-time and the process ID to
all messages.

You can make this logger the default by calling:

    ComfyCommons.Logging.set_global_logger()
"""
function GlobalConsoleLogger()
    gl = global_logger()
    return ConsoleLogger(gl.stream, gl.min_level, _metafmt, gl.show_limited,
                         gl.right_justify, gl.message_limits)
end

# prepend the process ID and the date-time to the default prefix
function _metafmt(level, _module, group, id, file, line)
    color, prefix, suffix = default_metafmt(level, _module, group, id, file, line) # default format
    prefix = join([ "($(Printf.@sprintf "%2d" Distributed.myid()))",
                    Dates.format(Dates.now(), "yy-mm-dd HH:MM:SS"),
                    prefix ], " ")
    return color, prefix, suffix
end

end
