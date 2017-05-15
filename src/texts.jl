readme(package) = begin
    package_name = package.package_name
    repo_name = package.repo_name
    user_name = package.user_name
    appveyor_slug = package.appveyor_slug
    """
    # $package_name

    [![travis badge][travis_badge]][travis_url]
    [![appveyor badge][appveyor_badge]][appveyor_url]
    [![codecov badge][codecov_badge]][codecov_url]

    ## Documentation [here][documenter_latest]

    Change documentation to link to `documenter_stable` once published!

    [travis_badge]: https://travis-ci.org/$user_name/$repo_name.svg?branch=master
    [travis_url]: https://travis-ci.org/$user_name/$repo_name

    [appveyor_badge]: https://ci.appveyor.com/api/projects/status/github/$user_name/$repo_name?svg=true&branch=master
    [appveyor_url]: https://ci.appveyor.com/project/$user_name/$appveyor_slug

    [codecov_badge]: http://codecov.io/github/$user_name/$repo_name/coverage.svg?branch=master
    [codecov_url]: http://codecov.io/github/$user_name/$repo_name?branch=master

    [documenter_stable]: https://$user_name.github.io/$repo_name/stable
    [documenter_latest]: https://$user_name.github.io/$repo_name/latest
    """
end

tests(package) = begin
    package_name = package.package_name
    repo_name = package.repo_name
    authors = package.authors
    """
    using $package_name

    import Documenter
    Documenter.makedocs(
        modules = [$package_name],
        format = :html,
        sitename = "$repo_name",
        root = joinpath(dirname(dirname(@__FILE__)), "docs"),
        pages = Any["Home" => "index.md"],
        strict = true,
        linkcheck = true,
        checkdocs = :exports,
        authors = "$authors"
    )

    using Base.Test

    # write your own tests here
    @test 1 == 1
    """
end

travis_yaml(package) = begin
    package_name = package.package_name
    """
    # Documentation: http://docs.travis-ci.com/user/languages/julia/
    language: julia
    os:
      - linux
      - osx
    julia:
      - 0.5
      - nightly
    notifications:
      email: false
    after_success:
    # build documentation
      - julia -e 'cd(Pkg.dir("$package_name")); Pkg.add("Documenter"); include(joinpath("docs", "make.jl"))'
    # push coverage results to Codecov
      - julia -e 'cd(Pkg.dir("$package_name")); Pkg.add("Coverage"); using Coverage; Codecov.submit(Codecov.process_folder())'
    """
end

make(package) = begin
    user_name = package.user_name
    repo_name = package.repo_name
    github_url = package |> GitHub |> url
    """
    import Documenter

    Documenter.deploydocs(
        repo = "$github_url",
        target = "build",
        deps = nothing,
        make = nothing
    )
    """
end

index(package) = begin
    package_name = package.package_name
    """
    # $package_name.jl

    ```@index
    ```

    ```@autodocs
    Modules = [$package_name]
    ```
    """
end

docs_gitignore() =
    """
    build/
    site/
    """

docs_require() =
    """
    Documenter
    """

entrypoint(package) = begin
    package_name = package.package_name

    """
    module $package_name

    ""\"
        test_function()

    Return 1

    ```jldoctest
    julia> import $package_name

    julia> $package_name.test_function()
    2
    ```
    ""\"
    test_function() = 1

    end
    """
end

gitignore(package) = PkgDev.Generate.gitignore(package.path)
license(package) = PkgDev.Generate.license(package.path,
    package.license,
    package.year,
    package.authors)
require(package) = PkgDev.Generate.require(package.path)
codecov(package) = PkgDev.Generate.codecov(package.path)
appveyor_yaml(package) = PkgDev.Generate.appveyor(package.path)
