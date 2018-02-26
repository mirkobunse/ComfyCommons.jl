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
module Pgfplots # sub-module of ComfyCommons


using TikzPictures, PGFPlots

export setpgftemplate, resetpgftemplate, TEMPLATE_PLOT_PLACEHOLDER

# export members of PGFPlots
export LaTeXString, @L_str, @L_mstr
export plot, ErrorBars, Axis, Axes, PolarAxis, GroupPlot, Plots, ColorMaps, save, define_color
export pushPGFPlotsOptions, popPGFPlotsOptions, resetPGFPlotsOptions, pgfplotsoptions
export pushPGFPlotsPreamble, popPGFPlotsPreamble, resetPGFPlotsPreamble, pgfplotspreamble
export pushPGFPlots, popPGFPlots


# templating
TEMPLATE_PLOT_PLACEHOLDER = "{PLOT}"
_template = AbstractString[TEMPLATE_PLOT_PLACEHOLDER]

function setpgftemplate(template::AbstractString)
    if !contains(template, TEMPLATE_PLOT_PLACEHOLDER)
        warn("Template does not contain the plot placeholder $TEMPLATE_PLOT_PLACEHOLDER")
    end
    
    pop!(_template)
    push!(_template, template)
end

resetpgftemplate() = setpgftemplate(TEMPLATE_PLOT_PLACEHOLDER)


# 
# The remainder of this file overrides methods of PGFPlots and TikzPictures to improve the
# format of generated .tex files. Most of this is syntactic sugar like line breaks and 
# indentation.
# 
# The severe changes are:
#   1) no tikzpicture environment is added to the .tex file
#   2) a template string can be provided (see above)
# 
function PGFPlots.plot(axis::PGFPlots.Axis)
    o = IOBuffer()
    print(o, "\\begin{$(axis.axisKeyword)}")
    PGFPlots.plotHelper(o, axis)
    print(o, "\n\\end{$(axis.axisKeyword)}")
    TikzPicture(String(take!(o)), options=pgfplotsoptions(), preamble=pgfplotspreamble())
end

function PGFPlots.plotHelper(o::IOBuffer, p::PGFPlots.Linear)
    print(o, "\n\\addplot+")
    if p.errorBars == nothing
        PGFPlots.optionHelper(o, PGFPlots.linearMap, p, brackets=true)
        println(o, "coordinates {")
        for i = 1:size(p.data,2)
            println(o, "  ($(p.data[1,i]), $(p.data[2,i]))")
        end
        println(o, "};")
    else
        PGFPlots.plotHelperErrorBars(o, p)
    end
    PGFPlots.plotLegend(o, p.legendentry)
end

PGFPlots.plotHelper(o::IOBuffer, p::PGFPlots.Command) = println(o, "\n" * p.cmd * ";")

function PGFPlots.optionHelper(o::IOBuffer, m, object; brackets=false, otherOptions=Dict{AbstractString,AbstractString}[], otherText=nothing)
    first = true
    for (sym, str) in m
        if getfield(object,sym) != nothing
            if first
                if brackets
                    print(o, "[")
                end
            else
                println(o, ",")
            end
            if length(str) > 0
                print(o, "$str = {")
            end
            if first
                first = false
            else
                print(o, "  ")
            end
            PGFPlots.printObject(o, getfield(object,sym))
            if length(str) > 0
                print(o, "}")
            end
        end
    end
    for (k, v) in otherOptions
        if first
            first = false
            if brackets
                print(o, "[")
            end
        else
            println(o, ",")
        end
        print(o, "  $k = $v")
    end
    if otherText != nothing
        for t in otherText
            if t != nothing
                if first
                    first = false
                    if brackets
                        println(o, "[")
                    end
                else
                    println(o, ",")
                end
                print(o, "  $t")
            end
        end
    end
    if !first && brackets
        println(o, "]")
    end
end

function PGFPlots.printObject(o::IOBuffer, object)
    if length(string(object)) > 0
        print(o, "\n  ")
    end
    print(o, join(map(strip, split(string(object), ",")), ",\n  "))
    if length(string(object)) > 0
        println(o, "")
    end
end

function TikzPictures.save(f::Union{TikzPictures.TEX,TikzPictures.TIKZ}, tp::TikzPictures.TikzPicture)
    filename = f.filename
    ext = TikzPictures.extension(f)
    tex = open("$(filename).$(ext)", "w")
    if f.include_preamble
        if TikzPictures.standaloneWorkaround()
            println(tex, "\\RequirePackage{luatex85}")
        end
        println(tex, "\\documentclass[tikz]{standalone}")
        println(tex, tp.preamble)
        println(tex, "\\begin{document}")
        print(tex, "\\begin{tikzpicture}[")
        print(tex, tp.options)
        println(tex, "]")
    end
    println(tex, replace(_template[1], TEMPLATE_PLOT_PLACEHOLDER, tp.data))
    if f.include_preamble
        println(tex, "\\end{tikzpicture}")
        println(tex, "\\end{document}")
    end
    close(tex)
end


end

