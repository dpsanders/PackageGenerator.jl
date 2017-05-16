get_travis_token(github_token) = begin
    info("Getting travis token")
    result = talk_to(Travis(), "/auth/github",
        headers = Dict("User-Agent" => "Travis/1.0"),
        body = Dict("github_token" => github_token) ) |> http_json
    result["access_token"]
end

sync(t::Travis) = begin
    info("Syncing travis to github")
    talk_to(t, "/users/sync")
end

set_repo_code!(t::Travis) = begin
    info("Getting travis repo info")

    user_name = t.user_name
    repo_name = t.repo_name
    answer = talk_to(t, "/repos/$user_name/$repo_name",
        request = HTTP.get)
    if answer.headers["Content-Type"] == "image/png"
        error("Travis repository does not exist for $repo_name, perhaps due to incomplete syncing. Try raising `sync_time` with `update_configuration`")
    else
        t.repo_code = http_json(answer)["id"]
    end
end

activate(t::Travis) = begin
    info("Turning travis repository on")
    repo_code = t.repo_code

    talk_to(t, "/hooks/$repo_code",
        request = HTTP.put,
        body = Dict("hook" => Dict("active" => true) ) )
end


add_key(t::Travis, key; name = "DOCUMENTER_KEY", public = false) = begin
    info("Submitting key to travis")
    repo_code = t.repo_code

    talk_to(t, "/settings/env_vars?repository_id=$repo_code",
        body = Dict("env_var" => Dict(
            "name" => name,
            "value" => key,
            "public" => public)) )
end
