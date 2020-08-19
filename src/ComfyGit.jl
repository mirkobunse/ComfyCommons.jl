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
module ComfyGit # sub-module of ComfyCommons

using LibGit2
export commithash, remoteurl, haschanges

"""
    commithash()

Return the hash of the last git commit.
"""
commithash() = string(LibGit2.head_oid(GitRepo(".")))

"""
    remoteurl(remote="origin")

Return the URL of the given git remote.
"""
remoteurl(remote::String="origin") = LibGit2.url(LibGit2.lookup_remote(GitRepo("."), remote))

"""
    haschanges()

Return true iff changes are made in the current working directory (staged or unstaged).
"""
haschanges(path::String...="") = any([LibGit2.isdirty(GitRepo("."), x) for x in path])

end # module
