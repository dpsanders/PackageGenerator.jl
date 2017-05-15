abstract Remote

type GitHub <: Remote
    user_name
    user_code
    repo_name
    url
end

GitHub(p::Package) = GitHub(p.user_name, p.github_token, p.repo_name,
    "https://api.github.com")

type Travis <: Remote
    user_name
    user_code
    repo_name
    repo_code
    url
end

Travis() = Travis("", "", "", "", "https://api.travis-ci.org")
Travis(p::Package) = Travis(p.user_name, p.travis_token, p.repo_name, "",
    "https://api.travis-ci.org")

type AppVeyor <: Remote
    user_name
    user_code
    repo_name
    repo_code
    url
end

AppVeyor(p::Package) = AppVeyor(p.user_name, p.appveyor_token, p.repo_name, p.appveyor_slug,
    "https://ci.appveyor.com/")
