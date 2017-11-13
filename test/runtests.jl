using Base.Test, ComfyYAML

# expand the properties 'array' and 'complexarray' in the test configuration
c = ComfyYAML.load_file("test.yml") # load the test file
@test typeof(c["array"]) <: Array
@test eltype(c["array"]) <: Int
@test typeof(c["complexarray"]) <: Array
@test eltype(c["complexarray"]) <: Dict

function testexpansion(c::Dict{Any,Any}, expand::String, remain::String)
    if (!(typeof(c[expand]) <: Array)) error("Only array properties can be tested!") end
    ce = ComfyYAML.expand(c, expand)
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
c = ComfyYAML.load_file("test.yml", a=3, b="5", c=[1, 2, 3]) # load with additional properties
@test c["a"] == 3
@test c["b"] == "5"
@test c["c"] == [1, 2, 3]

# test writing to files by parsing the output back again
c = ComfyYAML.load_file("test.yml")
filename = tempname() * ".yml"
ComfyYAML.write_file(filename, c) # write to temporary file
parsed = ComfyYAML.load_file(filename)
rm(filename) # cleanup
@test parsed == c

# test sub-expansion
c = ComfyYAML.load_file("test.yml")
ce = ComfyYAML.expand(c, ["subexpand", "y"])
@test typeof(ce) <: Array
@test length(ce) == length(c["subexpand"]["y"])
for cei in ce
    @test typeof(cei["subexpand"]["y"]) == eltype(c["subexpand"]["y"])
end

c = ComfyYAML.load_file("test.yml")
ce = ComfyYAML.expand(c, ["subexpandlist", "y"])
@test typeof(ce) <: Array
@test length(ce) == length(c["subexpandlist"][1]["y"]) + 1 # +1 because 'nothing' in item 2
for cei in ce
    @test typeof(cei["subexpandlist"][1]["y"]) <: Union{eltype(c["subexpandlist"][1]["y"]), Void}
end

# test property interpolation
c = ComfyYAML.load_file("test.yml")
@test ComfyYAML.interpolate(c, "inter") == "blaw-blaw"
@test ComfyYAML.interpolate(c, "multi") == "blaw-blaw-blaw"
@test_throws ErrorException ComfyYAML.interpolate(c, "kwarg") # argument missing
@test ComfyYAML.interpolate(c, "kwarg", arg="X") == "blaw-X"

