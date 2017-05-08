APPVEYOR_URL = "https://ci.appveyor.com/"

appveyor_token_header(token) = Dict("Authorization" => "Bearer $token")

get_appveyor_info(token) = begin
    info("Getting Appveyor info")
    HTTP_wrapper(APPVEYOR_URL, "/api/projects",
        request = HTTP.get,
        headers = appveyor_token_header(token))
end

turn_on_appveyor_repo(user, token, repo_name) = begin
    appveyor_info = get_appveyor_info(token)

    if any(appveyor_info) do project
        project["repositoryName"] == "$user/$repo_name"
    end
        error("Appveyor project $repo_name already exists for this repository")
    end

    info("Turning on AppVeyor repo")
    repo_info = HTTP_wrapper(APPVEYOR_URL, "/api/projects",
        request = HTTP.post,
        headers = appveyor_token_header(token),
        body = Dict(
            "repositoryProvider" => "gitHub",
            "repositoryName" => "$user/$repo_name") )

    repo_info["slug"]
end

try_to_delete_appveyor_project(user, token, slug) = begin
    info("Attempting to delete appveyor repository")
    result = HTTP_wrapper(APPVEYOR_URL, "/api/projects/$user/$slug",
        request = HTTP.delete,
        headers = appveyor_token_header(token) )
    if result == """{"message":"Project not found or access denied."}"""
        info("AppVeyor project $slug not found (perhaps during error cleanup)")
    end
end
