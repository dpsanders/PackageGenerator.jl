url(g::GitHub) = "github.com/$(g.user_name)/$(g.repo_name).git"

activate(g::GitHub) = begin
    info("Creating github repository")
    repo_name = g.repo_name

    talk_to(
        g, "/user/repos",
        body = Dict("name" => repo_name) )
end

add_key(g::GitHub, key; name = ".documenter", read_only = false) = begin
    info("Creating github deploy key $name")
    user_name = g.user_name
    repo_name = g.repo_name

    talk_to(
        g, "/repos/$user_name/$repo_name/keys",
        body = Dict("title" => name,
            "key" => key,
            "read_only" => read_only) )
end

delete(g::GitHub) = begin
    info("Deleting github repository")
    user_name = g.user_name
    repo_name = g.repo_name

    talk_to(
        g, "/repos/$user_name/$repo_name",
        request = HTTP.delete)
end
