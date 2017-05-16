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

# set up LibGit2
cfg = LibGit2.GitConfig(LibGit2.Consts.CONFIG_LEVEL_GLOBAL)
old_name = LibGit2.getconfig("user.name", "")
old_email = LibGit2.getconfig("user.email", "")
LibGit2.set!(cfg, "user.name", "blah")
LibGit2.set!(cfg, "user.email", "blah")

if Pkg.Dir.path(".package_generator.json") |> ispath
    old_configuration = read(PackageGenerator.User)
    need_to_restore_configuration = true
else
    need_to_restore_configuration = false
end

configure("", "", travis_token = "")
update_configuration(sync_time = 50)

package = "test_package" |> Package
@test package.sync_time == 50
@test_throws ErrorException Package("blah.jl")

@test PackageGenerator.GitHub(package).url == "https://api.github.com"
@test PackageGenerator.Travis(package).url == "https://api.travis-ci.org"
@test PackageGenerator.Travis().url == "https://api.travis-ci.org"
@test PackageGenerator.AppVeyor(package).url == "https://ci.appveyor.com/"

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

@test_throws ErrorException generate(package)
@test_throws ErrorException PackageGenerator.ssh_keygen("blah")

rm(path, recursive = true)

LibGit2.set!(cfg, "user.name", old_name)
LibGit2.set!(cfg, "user.email", old_email)

if need_to_restore_configuration
    write(old_configuration)
end
