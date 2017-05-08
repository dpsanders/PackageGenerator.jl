TRAVIS_URL = "https://api.travis-ci.org"

get_travis_token(github_token) = begin
    info("Getting travis token")
    result = HTTP_wrapper(TRAVIS_URL, "/auth/github",
        request = HTTP.post,
        headers = Dict("User-Agent" => "Travis/1.0"),
        body = Dict("github_token" => github_token) )
    result["access_token"]
end

sync_travis_to_github(user, token) = begin
    info("Syncing travis to github")
    HTTP_wrapper(TRAVIS_URL, "/users/sync",
        request = HTTP.post,
        token = token)
end

get_travis_repo_info(user, token, repo_name) = begin
    info("Getting travis repo info")
    result = HTTP_wrapper(TRAVIS_URL, "/repos/$user/$repo_name",
        token = token)
    if isa(result, HTTP.FIFOBuffer)
        error("Cannot find travis repository $repo_name, perhaps due to incomplete syncing with GitHub. Try raising the `sync_time`")
    else
        result
    end
end

turn_on_travis_repo(token, repository_id) = begin
    info("Turning travis repository on")
    HTTP_wrapper(TRAVIS_URL, "/hooks/$repository_id",
        request = HTTP.put,
        token = token,
        body = Dict("hook" => Dict("active" => true) ) )
end

create_travis_env_var(token, repository_id, name, value; public = false) = begin
    info("Submitting key to travis")
    HTTP_wrapper(TRAVIS_URL, "/settings/env_vars?repository_id=$repository_id",
        request = HTTP.post,
        token = token,
        body = Dict("env_var" => Dict(
            "name" => name,
            "value" => value,
            "public" => public)) )
end
