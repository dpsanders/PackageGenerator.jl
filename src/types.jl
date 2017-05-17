type User
    package_directory
    authors
    user_name
    github_token
    travis_token
    appveyor_token
    sync_time
    ssh_keygen_file
end

User(github_token, appveyor_token;
    ssh_keygen_file = "ssh-keygen",
    travis_token = get_travis_token(github_token),
    package_directory = Pkg.Dir.path(),
    authors = LibGit2.getconfig("user.name", "YOUR_NAME"),
    user_name = LibGit2.getconfig("github.user", "YOUR_GITHUB_USER_NAME"),
    sync_time = 60
) = begin

    User(
        package_directory,
        authors,
        user_name,
        github_token,
        travis_token,
        appveyor_token,
        sync_time,
        ssh_keygen_file
    )
end

export Package
type Package
    package_name
    repo_name
    path
    authors
    year
    user_name
    github_token
    travis_token
    appveyor_token
    sync_time
    ssh_keygen_file
    appveyor_slug
    created
end

"""
    Package(package_name)

Generate a default package based on a package name. To customize your package,
you can edit any of its fields before [`generate`](@ref)ing it. The package will include
all the fields discussed in [`configure`](@ref), `package_name`, as well as the
following defaults (override with keyword arguments).

    repo_name = package_name * ".jl"

The name of your repository on github.

    year = Dates.today() |> Dates.year

The copyright year. Defaults to the current year.
"""
Package(package_name,
    repo_name = package_name * ".jl",
    year = Dates.today() |> Dates.year
) = begin

    if endswith(package_name, ".jl")
        error("Please provide package name $package_name without .jl")
    end

    user = read(User)

    path = joinpath(user.package_directory, package_name)
    appveyor_slug = replace(repo_name, ".",  "-")
    created = []

    Package(
        package_name,
        repo_name,
        path,
        user.authors,
        year,
        user.user_name,
        user.github_token,
        user.travis_token,
        user.appveyor_token,
        user.sync_time,
        user.ssh_keygen_file,
        appveyor_slug,
        created
    )
end
