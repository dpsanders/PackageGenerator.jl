write_texts(package) = begin
    path = package.path

    texts = Dict(
        "LICENSE.md" => license(package),
        "REQUIRE" => require(),
        "README.md" => readme(package),

        "src/$(package.package_name).jl" => entrypoint(package),

        "test/REQUIRE" => docs_require(),
        "test/runtests.jl" => tests(package),

        "docs/make.jl" => make(package),
        "docs/src/index.md" => index(package),
        "docs/.gitignore" => docs_gitignore(),

        ".travis.yml" => travis_yaml(package),
        "appveyor.yml" => appveyor_yaml(package),
        ".codecov" => codecov(),
        ".gitignore" => gitignore()
    )

    info("Initializing git repository")
    repo = LibGit2.init(path)
    LibGit2.set_remote_url(repo, package |> GitHub |> url)
    LibGit2.commit(repo, "Initial empty commit")
    LibGit2.branch!(repo, "gh-pages")
    LibGit2.branch!(repo, "master")

    for (file, text) in texts
        full_path = joinpath(path, file)
        info("Generating $file")
        mkpath(dirname(full_path))
        write(full_path, text)
    end

    info("Committing changes")
    LibGit2.add!(repo, keys(texts)...)
    LibGit2.commit(repo, "Generated files")

    repo
end

delete(package) = begin
    created = package.created
    if "local repository" in created
        info("Deleting local repository")
        rm(package.path, recursive = true, force = true)
    end
    if "github repository" in created
        package |> GitHub |> delete
    end
    if "appveyor project" in created
        package |> AppVeyor |> delete
    end
end

export generate
"""
    generate(package::Package)

Generate a [`Package`](@ref)` with some nice bells and whistles.
These include:

- a matching github repository
- testing with travis
- testing with appveyor
- generated documentation that
  - automatically syncs to changes on github
  - includes doctests as part of your package testing suite

Of course, this means you need both a github, travis, and appveyor account.

If you haven't set up an ssh key for git, follow the instructions
[here](https://help.github.com/articles/connecting-to-github-with-ssh/).

The license will be the MIT license. To change, use `PkgDev.Generate.license`
"""
generate(package::Package) = begin
    path = package.path
    if ispath(path)
        error("$path already exists. Please remove and try again")
    end
    try
        sync_time = package.sync_time
        created = package.created

        github = package |> GitHub
        activate(github)
        push!(created, "github repository")
        info("Waiting $sync_time seconds to for github repo creation to finish")
        sleep(sync_time)

        travis = Travis(package)
        sync(travis)
        info("Waiting $sync_time seconds to finish syncing travis to github")
        sleep(sync_time)
        set_repo_code!(travis)
        activate(travis)

        public_key, private_key = ssh_keygen(package.ssh_keygen_file)
        add_key(github, public_key)
        add_key(travis, private_key)

        appveyor = AppVeyor(package)
        check(appveyor)
        activate!(appveyor)
        push!(created, "appveyor project")
        package.appveyor_slug = appveyor.repo_code

        mkdir(path)
        push!(created, "local repository")

        repo = write_texts(package)

        LibGit2.push(repo, refspecs=["refs/heads/master", "refs/heads/gh-pages"])

        package
    catch x
        info("Ran into an error; cleaning up")
        delete(package)
        rethrow(x)
    end
end
