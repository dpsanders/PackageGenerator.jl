check(a::AppVeyor) = begin
    info("Getting AppVeyor info")

    projects = talk_to(a, "/api/projects",
        request = HTTP.get) |> http_json

    user_name = a.user_name
    repo_name = a.repo_name

    if any(projects) do project
        project["repositoryName"] == "$user_name/$repo_name"
    end
        error("AppVeyor project $repo_name already exists for this repository")
    end

end

activate!(a::AppVeyor) = begin
    info("Turning on AppVeyor repo")

    user_name = a.user_name
    repo_name = a.repo_name

    repo_info = talk_to(a, "/api/projects",
        body = Dict(
            "repositoryProvider" => "gitHub",
            "repositoryName" => "$user_name/$repo_name") ) |> http_json

    a.repo_code = repo_info["slug"]
end

delete(a::AppVeyor) = begin
    info("Deleting appveyor repository")
    user_name = a.user_name
    repo_code = a.repo_code
    talk_to(a, "/api/projects/$user_name/$repo_code",
        request = HTTP.delete)
end
