module PackageGenerator

import PkgDev
import JSON
import HTTP
import FileIO

include("utilities.jl")
include("github.jl")
include("travis.jl")
include("appveyor.jl")
include("texts.jl")
include("generate.jl")

end
