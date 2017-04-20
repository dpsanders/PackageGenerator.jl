export generate_online
"""
    generate_online(repo_name; ssh_keygen_file = "ssh-keygen")

Only the online components of [`generate`](@ref) (see for more
documentation)

Set up a linked github and travis account for a certain repository.
"""
generate_online(repo_name;
    user = PkgDev.GitHub.user(),
    github_token = PkgDev.GitHub.token(),
    travis_token = get_travis_token(github_token),
    appveyor_token = "",
    sync_time = 60,
    ssh_keygen_file = "ssh-keygen"
) = begin

    create_github_repo(github_token, repo_name)
    info("Waiting $sync_time seconds to for github repo creation to finish")
    sleep(sync_time)
    sync_travis_to_github(user, travis_token)
    info("Waiting $sync_time seconds to finish syncing travis to github")
    sleep(sync_time)
    repository_id = get_travis_repo_info(user, travis_token, repo_name)["id"]
    turn_on_travis_repo(travis_token, repository_id)

    public_key, private_key = ssh_keygen(ssh_keygen_file)
    create_github_deploy_key(user, github_token, repo_name, "documenter", public_key)
    create_travis_env_var(travis_token, repository_id, "DOCUMENTER_KEY", private_key)

    if appveyor_token == ""
        info("No appveyor token given; not turning on repository; guessing appveyor slug")
        default_appveyor_slug(repo_name)
    else
        turn_on_appveyor_repo(user, appveyor_token, repo_name)
    end
end

export generate_offline
"""
    generate_offline(package, license = "MIT")

Only the offline components of [`generate`](@ref) (see for more documentation)

Create a local git repository containing package files.
"""
generate_offline(package;
    path = joinpath(Pkg.Dir.path(), package),
    license = "MIT",
    authors = LibGit2.getconfig("user.name", ""),
    years = PkgDev.Generate.copyright_year(),
    user = PkgDev.GitHub.user(),
    repo_name = string(package, ".jl"),
    appveyor_slug = default_appveyor_slug(repo_name)
) = begin

    if ispath(path)
        error("$path already exists. Please remove and try again")
    end

    texts = Dict(
        "README.md" => readme(user, package, repo_name, appveyor_slug = appveyor_slug),
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

clean_up_failure(package;
    path = joinpath(Pkg.Dir.path(), package),
    user = PkgDev.GitHub.user(),
    repo_name = string(package, ".jl"),
    github_token = PkgDev.GitHub.token(),
    appveyor_token = "",
    appveyor_slug = default_appveyor_slug(repo_name)
) = begin
    info("Removing local repository")
    rm(path, recursive = true, force = true)
    info("Removing github repository")
    try_to_delete_github_repo(user, github_token, repo_name)
    if appveyor_token != ""
        try_to_delete_appveyor_project(user, appveyor_token, appveyor_slug)
    end
    nothing
end

export generate
"""
    generate(package;
        license = "MIT",
        ssh_keygen_file = "ssh-keygen",
        appveyor_token = "")

Generate a package named `package` with some nice bells and whistles.
These include:

- a matching github repository
- an activated repository on travis
- generated documentation that
  - automatically syncs to changes on github
  - includes doctests as part of your package testing suite

Of course, this means you need both a github and a travis account.

The package defaults to the `"MIT"` `license`. See `PkgDev` for other options.

`ssh-keygen` makes a pair of keys that allows Travis to
communicate with Github. For Linux users with git installed, the default file
should be fine. For Windows users with git installed, try
`ssh_keygen_file = "C:/Program Files/Git/usr/bin/ssh-keygen"`.

Your `appveyor_token` is available [here](https://ci.appveyor.com/api-token).
Include the token in order to automatically turn on the appveyor for your repo.

For `LibGit2.push` to work,
follow the instructions [here](https://help.github.com/articles/connecting-to-github-with-ssh/)

By default, tests will fail. Documentation will not build until tests
pass.
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
    appveyor_token = "",
    appveyor_slug = default_appveyor_slug(repo_name),
    ssh_keygen_file = "ssh-keygen",
    sync_time = 60
) = begin

    if endswith(package, ".jl")
        error("Please provide package name without .jl")
    end

    if ispath(path)
        error("$path already exists. Remove and try again")
    end

    try
        appveyor_slug = generate_online(repo_name;
            user = user,
            github_token = github_token,
            travis_token = travis_token,
            appveyor_token = appveyor_token,
            ssh_keygen_file = ssh_keygen_file,
            sync_time = sync_time
        )

        repo = generate_offline(package;
            path = path,
            license = license,
            authors = authors,
            years = years,
            user = user,
            repo_name = repo_name,
            appveyor_slug = appveyor_slug
        )

        info("Pushing repo to github")
        LibGit2.push(repo, refspecs=["refs/heads/master", "refs/heads/gh-pages"])
    catch x
        info("Ran into an error; cleaning up")
        clean_up_failure(package;
            path = path,
            user = user,
            repo_name = repo_name,
            github_token = github_token,
            appveyor_token = appveyor_token,
            appveyor_slug = appveyor_slug
        )
        rethrow(x)
    end
end
