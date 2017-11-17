# 
# ComfyUtil
# Copyright 2017 Mirko Bunse
# 
# 
# Comfortable utility functions.
# 
# 
# ComfyUtil is free software: you can redistribute it and/or modify
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
# along with ComfyUtil.  If not, see <http://www.gnu.org/licenses/>.
# 

module ComfyUtil


"""
    info(msg...)

Print a log message to the console, prefixed by the current process ID and a date time string.
"""
info(msg...) =
    Base.info(msg..., prefix="[$(myid())] $(Dates.format(now(), "yy-mm-dd HH:MM:SS")): ")



# sub-module
module Git

_IS_REPO = try chomp(readstring(`git rev-parse --show-toplevel`)) != ""
           catch false end
if (!_IS_REPO) warn("ComfyUtil.Git is called from $(pwd()), which is not a git repository.") end

"""
    commithash()

Return the hash of the last git commit.
"""
commithash() =
    if _IS_REPO # only run inside git repository
        try chomp(readstring(`git rev-parse HEAD`)) # read hash without newline character
        catch "" end
    else "" end

"""
    remoteurl(remote="origin")

Return the URL of the given git remote.
"""
remoteurl(remote::String="origin") =
    if _IS_REPO # only run inside git repository
        try chomp(readstring(`git config --get remote.$remote.url`))
        catch "" end
    else "" end

"""
    haschanges()

Return true iff changes are made in the current working directory (staged or unstaged).
"""
haschanges(path::String...=".") =
    if _IS_REPO # only run inside git repository
        try
            run(`git diff --quiet $path`) # throws error if differences are present
            run(`git diff --cached --quiet $path`)
            false
        catch true end # if something is catched, there are changes
    else false end

end # Git


end # module
