# PackageGenerator.jl

```@index
```

```@autodocs
Modules = [PackageGenerator]
```

# Advanced usage

For advanced users, there are several undocumented keywords for
[`generate`](@ref). They are listed below, along with their default values.

```julia
path = joinpath(Pkg.Dir.path(), package)
```
The folder where files will be generated

```
authors = LibGit2.getconfig("user.name", "")
```
The authors of the package. Interpolated directly into the license.

```
years = PkgDev.Generate.copyright_year()
```
The copyright year. Interpolated directly into the license.

```
user = PkgDev.GitHub.user()
```
Your github username

```
repo_name = string(package, ".jl")
```
The desired name of the github repository

```
github_token = PkgDev.GitHub.token()
```
Your token to access the GitHub API

```
travis_token = get_travis_token(github_token)
```
Your token to access the Travis API

```
appveyor_slug = default_appveyor_slug(repo_name)
```
The name of the appveyor project for your repository. If an appveyor token is
given, the actual `appveyor_slug` will be used instead.
