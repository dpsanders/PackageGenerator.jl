type User
    package_directory
    license
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
    license = "MIT",
    authors = LibGit2.getconfig("user.name", ""),
    user_name = LibGit2.getconfig("github.user", ""),
    sync_time = 60
) = begin

    User(
        package_directory,
        license,
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
    license
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

Generate a default package based on a package name. To customize you pacakge,
you can edit any of its fields before `generate`ing it. The package will include
all the fields discussed in [`configure`](@ref), `package_name`, as well as:

    repo_name = string(package_name, ".jl")

The name of your repository on github.

    year = string(Dates.year(Dates.today()))

The copyright year. Defaults to the current year.
"""
Package(package_name,
    repo_name = string(package_name, ".jl"),
    year = string(Dates.year(Dates.today())),
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
        user.license,
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
