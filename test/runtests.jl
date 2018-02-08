using Base.Test, ComfyUtil

# expand the properties 'array' and 'complexarray' in the test configuration
c = Yaml.load_file("test.yml") # load the test file
@test typeof(c["array"]) <: Array
@test eltype(c["array"]) <: Int
@test typeof(c["complexarray"]) <: Array
@test eltype(c["complexarray"]) <: Dict

function testexpansion(c::Dict{Any,Any}, expand::String, remain::String)
    if (!(typeof(c[expand]) <: Array)) error("Only array properties can be tested!") end
    ce = Yaml.expand(c, expand)
    @test typeof(ce) <: Array             # expansion was performed
    @test length(ce) == length(c[expand]) # length of expansion is correct
    for cei in ce
        # individual values of expanded property are stored as property values
        @test typeof(cei[expand]) == eltype(c[expand])
        # remaining config is untouched
        @test cei[remain] == c[remain]
    end
end
testexpansion(c, "array", "complexarray")
testexpansion(c, "complexarray", "array")

# test kwargs runtime configuration
c = Yaml.load_file("test.yml", a=3, b="5", c=[1, 2, 3]) # load with additional properties
@test c["a"] == 3
@test c["b"] == "5"
@test c["c"] == [1, 2, 3]

# test writing to files by parsing the output back again
c = Yaml.load_file("test.yml")
filename = tempname() * ".yml"
Yaml.write_file(filename, c) # write to temporary file
parsed = Yaml.load_file(filename)
rm(filename) # cleanup
@test parsed == c

# test writing to files with prefix
c = Yaml.load_file("test.yml")
filename = tempname() * ".yml"
prfx = """
# this is a multiline
# comment prefix
"""
Yaml.write_file(filename, c, prfx)
for (i, l) in enumerate(eachline(filename))
    if i == 1
        @test chomp(l) == "# this is a multiline"
    elseif i == 2
        @test chomp(l) == "# comment prefix"
    else
        break
    end
end
parsed = Yaml.load_file(filename)
rm(filename) # cleanup
@test parsed == c

# test sub-expansion
c = Yaml.load_file("test.yml")
ce = Yaml.expand(c, ["subexpand", "y"])
@test typeof(ce) <: Array
@test length(ce) == length(c["subexpand"]["y"])
for cei in ce
    @test typeof(cei["subexpand"]["y"]) == eltype(c["subexpand"]["y"])
end

c = Yaml.load_file("test.yml")
ce = Yaml.expand(c, ["subexpandlist", "y"])
@test typeof(ce) <: Array
@test length(ce) == length(c["subexpandlist"][1]["y"]) + 1 # +1 because 'nothing' in item 2
for cei in ce
    @test typeof(cei["subexpandlist"][1]["y"]) <: Union{eltype(c["subexpandlist"][1]["y"]), Void}
end

# test property interpolation
c = Yaml.load_file("test.yml")
@test Yaml.interpolate(c, "inter") == "blaw-blaw"
@test Yaml.interpolate(c, "multi") == "blaw-blaw-blaw"
@test_throws ErrorException Yaml.interpolate(c, "kwarg") # argument missing
@test Yaml.interpolate(c, "kwarg", arg="X") == "blaw-X"

