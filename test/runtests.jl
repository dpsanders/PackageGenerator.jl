using PackageGenerator

import Documenter
Documenter.makedocs(
    modules = [PackageGenerator],
    format = :html,
    sitename = "PackageGenerator.jl",
    root = joinpath(dirname(dirname(@__FILE__)), "docs"),
    pages = Any["Home" => "index.md"],
    strict = true,
    authors = "Brandon Taylor"
)

using Base.Test

configure("", "", travis_token = "")
update_configuration(sync_time = 50)
package = "test_package" |> Package
@test package.sync_time == 50
path = package.path
mkpath(package.path)
PackageGenerator.write_texts(package)
texts = (
    "LICENSE.md",
    "REQUIRE.md",
    "README",
    "src/$(package.package_name).jl",

    "test/REQUIRE",
    "test/runtests.jl",

    "docs/make.jl",
    "docs/src/index.md",
    "docs/.gitignore",

    ".travis.yml",
    "appveyor.yml",
    ".codecov",
    ".gitignore",
)

@test all(texts) do file
    joinpath(path, file) |> ispath
end

@test_throws ErrorException Package("blah.jl")
@test_throws ErrorException PackageGenerator.ssh_keygen("blah")

rm(path, recursive = true)
