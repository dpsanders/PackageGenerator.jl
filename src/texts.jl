VERSION = "0.5"

license(package) = begin
    package_name = package.package_name
    year = package.year
    authors = package.authors

    """
    The $package_name.jl package is licensed under the MIT "Expat" License:


    > Copyright (c) $year: $authors.
    >
    >
    > Permission is hereby granted, free of charge, to any person obtaining a copy
    >
    > of this software and associated documentation files (the "Software"), to deal
    >
    > in the Software without restriction, including without limitation the rights
    >
    > to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    >
    > copies of the Software, and to permit persons to whom the Software is
    >
    > furnished to do so, subject to the following conditions:
    >
    >
    >
    > The above copyright notice and this permission notice shall be included in all
    >
    > copies or substantial portions of the Software.
    >
    >
    >
    > THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    >
    > IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    >
    > FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    >
    > AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    >
    > LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    >
    > OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    >
    > SOFTWARE.
    >
    >
    """
end

require() = "julia $VERSION"

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

docs_require() = "Documenter"

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

travis_yaml(package) = begin
    package_name = package.package_name
    """
    # Documentation: http://docs.travis-ci.com/user/languages/julia/
    language: julia
    os:
      - linux
      - osx
    julia:
      - $VERSION
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

appveyor_yaml(package) = begin
    package_name = package.package_name
    """
    environment:
      matrix:
      - JULIAVERSION: "julialang/bin/winnt/x86/$VERSION/julia-$VERSION-latest-win32.exe"
      - JULIAVERSION: "julialang/bin/winnt/x64/$VERSION/julia-$VERSION-latest-win64.exe"
      - JULIAVERSION: "julianightlies/bin/winnt/x86/julia-latest-win32.exe"
      - JULIAVERSION: "julianightlies/bin/winnt/x64/julia-latest-win64.exe"
    branches:
      only:
        - master
        - /release-.*/
    notifications:
      - provider: Email
        on_build_success: false
        on_build_failure: false
        on_build_status_changed: false
    install:
      - ps: (new-object net.webclient).DownloadFile(
            \$("http://s3.amazonaws.com/"+\$env:JULIAVERSION),
            "C:\\projects\\julia-binary.exe")
      - C:\\projects\\julia-binary.exe /S /D=C:\\projects\\julia
    build_script:
      - IF EXIST .git\\shallow (git fetch --unshallow)
      - C:\\projects\\julia\\bin\\julia -e "versioninfo();
          Pkg.clone(pwd(), \\"$package_name\\"); Pkg.build(\\"$package_name\\")"
    test_script:
      - C:\\projects\\julia\\bin\\julia -e "Pkg.test(\\"$package_name\\")"
    """
end

codecov() = "comment: false"

gitignore() = """
*.jl.cov
*.jl.*.cov
*.jl.mem
"""
