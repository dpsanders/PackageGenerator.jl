readme(user, package, repo_name) =
    """
    # $package

    [![travis badge][travis_badge]][travis_url]
    [![codecov badge][codecov_badge]][codecov_url]

    ## Documentation

    - [**STABLE**][documenter_stable] &mdash; **most recently tagged version of the documentation.**
    - [**LATEST**][documenter_latest] &mdash; *in-development version of the documentation.*

    [travis_badge]: https://travis-ci.org/$user/$repo_name.svg?branch=master
    [travis_url]: https://travis-ci.org/$user/$repo_name

    [codecov_badge]: http://codecov.io/github/$user/$repo_name/coverage.svg?branch=master
    [codecov_url]: http://codecov.io/github/$user/$repo_name?branch=master

    [documenter_stable]: https://$user.github.io/$repo_name/stable
    [documenter_latest]: https://$user.github.io/$repo_name/latest
    """

tests(package, repo_name, authors) = begin
    """
    using $package
    using Base.Test

    import Documenter
    Documenter.makedocs(
        modules = [$package],
        format = :html,
        sitename = "$repo_name",
        root = joinpath(dirname(dirname(@__FILE__)), "docs"),
        pages = Any["Home" => "index.md"],
        strict = true,
        linkcheck = true,
        authors = "$authors"
    )

    # write your own tests here
    @test 1 == 1
    """
end

travis(package) =
    """
    # Documentation: http://docs.travis-ci.com/user/languages/julia/
    language: julia
    os:
      - linux
    julia:
      - release
      - nightly
    notifications:
      email: false
    after_success:
    # push coverage results to Codecov
      - julia -e 'cd(Pkg.dir("$package")); Pkg.add("Coverage"); using Coverage; Codecov.submit(Codecov.process_folder())'
    # build documentation
      - julia -e 'cd(Pkg.dir("$package")); Pkg.add("Documenter"); include(joinpath("docs", "make.jl"))'
    """

make(user, repo_name) =
    """
    import Documenter

    Documenter.deploydocs(
        repo = "github.com/$user/$repo_name.git",
        target = "build",
        deps = nothing,
        make = nothing
    )
    """

index(package) =
    """
    # $package.jl

    Documentation for $package.jl

    ```@index
    ```

    ```@autodocs
    Modules = [$package]
    ```
    """

docs_gitignore() =
    """
    build/
    site/
    """

docs_require() =
    """
    Documenter
    """

entrypoint(package) =
    """
    module $package

    ""\"
        test_function()

    Return 1

    ```jldoctest
    julia> import $package

    julia> $package.test_function()
    1
    ```
    ""\"
    test_function() = 1

    end
    """
