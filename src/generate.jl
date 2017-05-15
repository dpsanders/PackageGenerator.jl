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

Generate a package named `package` with some nice bells and whistles.
These include:

- a matching github repository
- an activated repository on travis (and optionally, an activated appveyor
    project)
- generated documentation that
  - automatically syncs to changes on github
  - includes doctests as part of your package testing suite

Of course, this means you need both a github and a travis account. If you
haven't set up an ssh key for git, follow the instructions
[here](https://help.github.com/articles/connecting-to-github-with-ssh/).

You must include a [`Package`](@ref)
"""
generate(package::Package) = begin
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

        path = package.path

        if ispath(path)
            error("$path already exists. Please remove and try again")
        else
            mkdir(path)
            push!(created, "local repository")
        end

        info("Initializing git repository")
        repo = LibGit2.init(path)
        LibGit2.set_remote_url(repo, url(github))
        LibGit2.commit(repo, "Initial empty commit")
        LibGit2.branch!(repo, "gh-pages")
        LibGit2.branch!(repo, "master")

        texts = Dict(
            "README.md" => readme(package),
            "test/REQUIRE" => docs_require(),
            "test/runtests.jl" => tests(package),
            ".travis.yml" => travis_yaml(package),
            "docs/make.jl" => make(package),
            "docs/src/index.md" => index(package),
            "docs/.gitignore" => docs_gitignore(),
            "src/$(package.package_name).jl" => entrypoint(package)
        )

        for (file, text) in texts
            full_path = joinpath(path, file)
            info("Generating $file")
            mkpath(dirname(full_path))
            write(full_path, text)
        end

        original_files = [
            gitignore(package),
            license(package),
            require(package),
            codecov(package),
            appveyor_yaml(package)
        ]

        files = ( keys(texts)..., original_files... )

        info("Committing changes")
        LibGit2.add!(repo, files...)
        LibGit2.commit(repo, "Generated files")
        LibGit2.push(repo, refspecs=["refs/heads/master", "refs/heads/gh-pages"])

        package
    catch x
        info("Ran into an error; cleaning up")
        delete(package)
        rethrow(x)
    end
end
