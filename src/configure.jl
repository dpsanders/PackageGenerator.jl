Base.read(::Type{User}; file = Pkg.Dir.path(".package_generator.json") ) =
    if ispath(file)
        dict = JSON.parsefile(file, use_mmap = false)
        missings = setdiff(string.(fieldnames(User) ), keys(dict) )
        if isempty(missings)
            parts_in_order = map( fieldnames(User) ) do field
                dict[string(field)]
            end
            User(parts_in_order...)
        else
            error("Missing user configuration settings $missings. Please run `configure`")
        end
    else
        error("User settings configuration not found at $file. Please run `configure`")
    end

Base.write(u::User; file = Pkg.Dir.path(".package_generator.json") ) = begin
    dict = Dict()
    for name in fieldnames(u)
        dict[name] = getfield(u, name)
    end
    open(file, "w") do io
        JSON.print(io, dict)
    end
end

export configure
"""
    configure(github_token, appveyor_token)

Write out a user configuration file (`".package_generator.json"` in your package directory).

Requires a `github_token`, which can be generated
[here](https://github.com/settings/tokens/new). Make sure to check the
`"public_repo"` and `"delete_repo"` scopes (if you want to be able to delete
half-created repositories in case `PackageGenerator` hits an error).

Also requires an `appveyor_token`, which can be found
[here](https://ci.appveyor.com/api-token)

Includes various defaults that can be overwritten with keyword arguments.

    ssh_keygen_file = "ssh-keygen"

The path to `ssh-keygen`. `ssh-keygen` makes a pair of keys that allows Travis
to communicate with Github. For Linux users with git installed, the default file
should be fine. For Windows users with git installed, try
`ssh_keygen_file = "C:/Program Files/Git/usr/bin/ssh-keygen"`.

    travis_token = get_travis_token(github_token)

A travis token can be generated automatically from your github token

    package_directory = Pkg.Dir.path()

Where to put your new packages

    authors = LibGit2.getconfig("user.name", "YOUR_NAME")

Who are the authors of your packages?

    user_name = LibGit2.getconfig("github.user", "YOUR_GITHUB_USER_NAME")

What is your github username?

    sync_time = 60

How many seconds to wait for API calls to complete.
"""
configure(args...; kwargs...) = User(args...; kwargs...) |> write

export update_configuration
"""
    update_configuration(; kwargs...)

Update any of the user configurations discussed in [`configure`](@ref).
"""
update_configuration(; kwargs...) = begin
    user = read(User)
    for (key, value) in kwargs
        setfield!(user, key, value)
    end
    write(user)
end
