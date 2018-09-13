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
module Git # sub-module of ComfyCommons


export commithash, remoteurl, haschanges


_IS_REPO = try chomp(read(`git rev-parse --show-toplevel`, String)) != ""
           catch; false end
if (!_IS_REPO) warn("ComfyCommons.Git is called from $(pwd()), which is not a git repository.") end


"""
    commithash()

Return the hash of the last git commit.
"""
commithash() =
    if _IS_REPO # only run inside git repository
        try chomp(read(`git rev-parse HEAD`, String)) # read hash without newline character
        catch; "" end
    else "" end


"""
    remoteurl(remote="origin")

Return the URL of the given git remote.
"""
remoteurl(remote::String="origin") =
    if _IS_REPO # only run inside git repository
        try chomp(read(`git config --get remote.$remote.url`, String))
        catch; "" end
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
        catch; true end # if something is catched, there are changes
    else false end


end

