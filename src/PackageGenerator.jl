module PackageGenerator

import PkgDev
import JSON
import HTTP

include("types.jl")
include("api.jl")
include("talk_to.jl")
include("ssh_keygen.jl")
include("github.jl")
include("travis.jl")
include("appveyor.jl")
include("texts.jl")
include("generate.jl")
include("configure.jl")

end
