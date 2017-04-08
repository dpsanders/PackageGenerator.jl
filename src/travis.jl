TRAVIS_URL = "https://api.travis-ci.org"

get_travis_token(github_token) = begin
    result = HTTP_wrapper(TRAVIS_URL, "/auth/github",
        request = HTTP.post,
        headers = Dict("User-Agent" => "Travis/1.0"),
        JSON_body = Dict("github_token" => github_token),
        activity = "Getting travis token")
    result["access_token"]
end

sync_travis_to_github(user, token, repo_name) =
    HTTP_wrapper(TRAVIS_URL, "/users/sync",
        request = HTTP.post,
        token = token,
        activity = "Syncing travis to github",
        status_exceptions = [409] )

get_travis_repo_info(user, token, repo_name) =
    HTTP_wrapper(TRAVIS_URL, "/repos/$user/$repo_name",
        token = token,
        activity = "Getting travis repo info")

turn_on_travis_repo(token, repository_id) =
    HTTP_wrapper(TRAVIS_URL, "/hooks/$repository_id",
        request = HTTP.put,
        token = token,
        JSON_body = Dict("hook" => Dict("active" => true) ),
        activity = "Turning travis repository on")

create_travis_env_var(token, repository_id, name, value; public = false) =
    HTTP_wrapper(TRAVIS_URL, "/settings/env_vars?repository_id=$repository_id",
        request = HTTP.post,
        token = token,
        JSON_body = Dict("env_var" => Dict(
            "name" => name,
            "value" => value,
            "public" => public)),
        activity = "Submitting key to travis")
