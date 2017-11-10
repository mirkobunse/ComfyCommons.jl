using ComfyYAML
using Base.Test

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
