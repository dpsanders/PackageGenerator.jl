"""
    PackageGenerator.generate_offline(package, license = "MIT")

Only the offline components of [`generate`](@ref) (see for more documentation)

Create a local git repository containing package files.

```jldoctest
julia> import PackageGenerator

julia> package = "TestRepo";

julia> path = joinpath(tempdir(), package);

julia> PackageGenerator.generate_offline(package,
          path = path, authors = "blah", user = "blah");

julia> all([
           ".codecov.yml",
           ".git",
           ".gitignore",
           ".travis.yml",
           "appveyor.yml",
           "docs",
           "LICENSE.md",
           "README.md",
           "REQUIRE",
           "src/\$package.jl",
           "test/REQUIRE",
           "test/runtests.jl",
           "docs/.gitignore",
           "docs/make.jl",
           "docs/src/index.md"
       ]) do file
           joinpath(path, file) |> ispath
       end
true
```
"""
generate_offline(package;
    path = joinpath(Pkg.Dir.path(), package),
    license = "MIT",
    authors = LibGit2.getconfig("user.name", ""),
    years = PkgDev.Generate.copyright_year(),
    user = PkgDev.GitHub.user(),
    repo_name = string(package, ".jl")
) = begin

    if ispath(path)
        error("$path already exists. Please remove and try again")
    end

    texts = Dict(
        "README.md" => readme(user, package, repo_name),
        "test/REQUIRE" => docs_require(),
        "test/runtests.jl" => tests(package, repo_name, authors),
        ".travis.yml" => travis(package),
        "docs/make.jl" => make(user, repo_name),
        "docs/src/index.md" => index(package),
        "docs/.gitignore" => docs_gitignore(),
        "src/$package.jl" => entrypoint(package)
    )

    info("Initializing git repository")
    repo = LibGit2.init(path)
    LibGit2.set_remote_url(repo, "https://github.com/$user/$repo_name.git")
    LibGit2.commit(repo, "Initial empty commit")
    LibGit2.branch!(repo, "gh-pages")
    LibGit2.branch!(repo, "master")

    for (file, text) in texts
        full_path = joinpath(path, file)
        info("Generating $file")
        mkpath(dirname(full_path))
        write(full_path, text)
    end

    original_files = [
        PkgDev.Generate.gitignore(path),
        PkgDev.Generate.license(path, license, years, authors),
        PkgDev.Generate.require(path),
        PkgDev.Generate.codecov(path),
        PkgDev.Generate.appveyor(path)
    ]

    info("Committing changes")
    LibGit2.add!(repo, keys(texts)..., original_files...)
    LibGit2.commit(repo, "Generated files")

    repo
end

"""
    PackageGenerator.generate_online(repo_name; ssh_keygen_file = "ssh-keygen")

Only the online components of [`generate`](@ref) (see for more
documentation)

Set up a linked github and travis account for a certain repository.
"""
generate_online(repo_name;
    user = PkgDev.GitHub.user(),
    github_token = PkgDev.GitHub.token(),
    travis_token = get_travis_token(github_token),
    ssh_keygen_file = "ssh-keygen",
    travis_sync_time = 20
) = begin

    create_github_repo(github_token, repo_name)
    sync_travis_to_github(user, travis_token, repo_name)
    info("Waiting $travis_sync_time seconds for travis to sync")
    sleep(travis_sync_time)
    repository_id = get_travis_repo_info(user, travis_token, repo_name)["id"]
    turn_on_travis_repo(travis_token, repository_id)

    public_key, private_key = ssh_keygen(ssh_keygen_file)
    create_github_deploy_key(user, github_token, repo_name, "documenter", public_key)
    create_travis_env_var(travis_token, repository_id, "DOCUMENTER_KEY", private_key)

    nothing
end

"""
    PackageGenerator.generate(package; license = "MIT", ssh_keygen_file = "ssh-keygen")

Generate a package named `package` with some nice bells and whistles.
These include:

- a matching github repository
- an activated repository on travis
- generated documentation that
  - automatically syncs to changes on github
  - includes doctests as part of your package testing suite

The package defaults to the "MIT" `license`. See `PkgDev` for other options.

`ssh-keygen` makes a pair of keys that allows travis to
communicate with github. For Linux users with git installed, the default should
be fine. For Windows users with git installed, try
`ssh_keygen_path = "C:/Program Files/Git/usr/bin/ssh-keygen"`.

For `LibGit2.push` to work,
follow the instructions [here](https://help.github.com/articles/connecting-to-github-with-ssh/)
"""
generate(package;
    path = joinpath(Pkg.Dir.path(), package),
    license = "MIT",
    authors = LibGit2.getconfig("user.name", ""),
    years = PkgDev.Generate.copyright_year(),
    user = PkgDev.GitHub.user(),
    repo_name = string(package, ".jl"),
    github_token = PkgDev.GitHub.token(),
    travis_token = get_travis_token(github_token),
    ssh_keygen_file = "ssh-keygen",
    travis_sync_time = 20
) = begin

    if endswith(package, ".jl")
        error("Please provide package name without .jl")
    end

    try
        repo = generate_offline(package;
            path = path,
            license = license,
            authors = authors,
            years = years,
            user = user,
            repo_name = repo_name
        )

        generate_online(repo_name;
            user = user,
            github_token = github_token,
            travis_token = travis_token,
            ssh_keygen_file = ssh_keygen_file,
            travis_sync_time = travis_sync_time
        )

        info("Pushing changes")
        LibGit2.push(repo, refspecs=["refs/heads/master", "refs/heads/gh-pages"])
    catch
        rm(path, recursive = true)
        delete_github_repo(user, github_token, repo_name)
        rethrow()
    end
end
