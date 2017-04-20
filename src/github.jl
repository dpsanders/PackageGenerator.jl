GITHUB_URL = "https://api.github.com"

create_github_repo(token, repo_name) = begin
    info("Creating github repository")
    HTTP_wrapper(
        GITHUB_URL, "/user/repos",
        request = HTTP.post,
        token = token,
        body = Dict("name" => repo_name) )
end

create_github_deploy_key(user, token, repo_name, title, key; read_only = false) = begin
    info("Creating github deploy key")
    HTTP_wrapper(
        GITHUB_URL, "/repos/$user/$repo_name/keys",
        request = HTTP.post,
        token = token,
        body = Dict("title" => title,
            "key" => key,
            "read_only" => read_only) )
end

try_to_delete_github_repo(user, token, repo_name) = begin
    info("Attempting to delete github repository")
    result = HTTP_wrapper(
        GITHUB_URL, "/repos/$user/$repo_name",
        request = HTTP.delete,
        token = token,
        status_exceptions = ("Forbidden", "Not Found") )

    if result == "Forbidden"
        info("Your github token (likely) does not have admin privileges. Cannot delete repository (possibly during error cleanup)")
    elseif result == "Not Found"
        info("GitHub repo not found for deletion (possibly during error cleanup)")
    else
        result
    end
end
