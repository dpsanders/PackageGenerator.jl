"""
    generate(package; license = "MIT", path_to_ssh_keygen = "")

Generate a package named `package` with some nice bells and whistles.
These include:

- a matching github repository
- an activated repository on travis
- generated documentation that
  - automatically syncs to changes on github
  - includes doctests as part of your package testing suite

The package defaults to the "MIT" `license`. See `PkgDev` for other options.

`ssh-keygen` is required. If it is not on your path, make sure to include
a path to it. `ssh-keygen` is sometimes packaged with `git`. If you are on
Windows, `PackageGenerator` will automatically check
`"C:/Program Files/Git/usr/bin"` for it. If you are on Ubuntu, and don't
yet have it installed, try `sudo apt-get install openssh-client`. Then you
won't need to include a path.

For `LibGit2.push` to work,
follow the instructions [here](https://help.github.com/articles/connecting-to-github-with-ssh/)
"""
generate(package;
    license = "MIT",
    path_to_ssh_keygen = "",
    travis_sync_time = 20,
    path = joinpath(Pkg.Dir.path(), package),
    authors = LibGit2.getconfig("user.name", ""),
    years = PkgDev.Generate.copyright_year(),
    user = PkgDev.GitHub.user(),
    repo_name = string(package, ".jl")
) = begin

    if endswith(package, ".jl")
        error("Please provide package name without .jl")
    end

    if ispath(path)
        error("$path already exists. Please remove and try again")
    end

    set_up_linked_github_and_travis_accounts(user, repo_name;
        path_to_ssh_keygen = path_to_ssh_keygen,
        travis_sync_time = travis_sync_time)

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

    try
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
            PkgDev.Generate.codecov(path)
        ]

        info("Committing changes")
        LibGit2.add!(repo, keys(texts)..., original_files...)
        LibGit2.commit(repo, "Generated files")
        info("Pushing changes")
        LibGit2.push(repo, refspecs=["refs/heads/master", "refs/heads/gh-pages"])
    catch
        rm(path, recursive=true)
        rethrow()
    end
    return
end

function set_up_linked_github_and_travis_accounts(user, repo_name;
    path_to_ssh_keygen = "",
    travis_sync_time = 20)

    info("Getting github token")
    github_token = PkgDev.GitHub.token()
    create_github_repo(github_token, repo_name)

    travis_token = get_travis_token(github_token)
    sync_travis_to_github(user, travis_token, repo_name)
    info("Waiting $travis_sync_time seconds for travis to sync")
    sleep(travis_sync_time)
    repository_id = get_travis_repo_info(user, travis_token, repo_name)["id"]
    turn_on_travis_repo(travis_token, repository_id)

    public_key, private_key = withenv(ssh_keygen, add_to_path(path_to_ssh_keygen) )
    create_github_deploy_key(user, github_token, repo_name, "documenter", public_key)
    create_travis_env_var(travis_token, repository_id, "DOCUMENTER_KEY", private_key)
end
