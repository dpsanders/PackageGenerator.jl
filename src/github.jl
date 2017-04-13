GITHUB_URL = "https://api.github.com"

create_github_repo(token, repo_name) =
    HTTP_wrapper(
        GITHUB_URL, "/user/repos",
        request = HTTP.post,
        token = token,
        JSON_body = Dict("name" => repo_name),
        activity = "Creating github repository"
    )

create_github_deploy_key(user, token, repo_name, title, key; read_only = false) =
    HTTP_wrapper(
        GITHUB_URL, "/repos/$user/$repo_name/keys",
        request = HTTP.post,
        token = token,
        JSON_body = Dict("title" => title,
            "key" => key,
            "read_only" => read_only),
        activity = "Creating github deploy key"
    )

delete_github_repo(user, token, repo_name) =
    try
        result = HTTP_wrapper(
            GITHUB_URL, "/repos/$user/$repo_name",
            request = HTTP.delete,
            token = token,
            activity = "Deleting github repository",
            status_exceptions = [403, 404]
        )
        if isa(result, HTTP.Response)
            if HTTP.statustext(result) == "Forbidden"
                info("Your github token (likely) does not have admin privileges. Cannot delete repository (possibly during error cleanup)")
            elseif HTTP.statustext(result) == "Not Found"
                info("GitHub repo not found for deletion")
            end
        end
        result
    catch x
        rethrow()
    end
