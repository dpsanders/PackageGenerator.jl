import PackageGenerator
import PkgDev

using Base.Test

keyfile = "C:/Users/brandon_taylor/keys.txt"
lines = map(chomp, readlines(keyfile))
user = lines[2]
ssh_keygen_file = lines[4]
github_token = lines[6]
appveyor_token = lines[8]

travis_token =
    PackageGenerator.get_travis_token(github_token)

package = "NewTestPackage"
repo_name = package * ".jl"
fake_name = "blah"

@test_throws ErrorException PackageGenerator.generate(package * ".jl", travis_token = travis_token)
@test_throws ErrorException PackageGenerator.get_travis_repo_info(user, travis_token, fake_name)
@test_throws ErrorException PackageGenerator.ssh_keygen(fake_name)

PackageGenerator.try_to_delete_github_repo(user, github_token, fake_name)
PackageGenerator.try_to_delete_appveyor_project(user, appveyor_token, fake_name)

PackageGenerator.generate(package,
    ssh_keygen_file = ssh_keygen_file,
    github_token = github_token,
    appveyor_token = appveyor_token
)

@test_throws ErrorException PackageGenerator.create_github_repo(github_token, repo_name)
@test_throws ErrorException PackageGenerator.turn_on_appveyor_repo(user, appveyor_token, repo_name)
@test_throws ErrorException PackageGenerator.generate_offline(package)

# warns
PackageGenerator.try_to_delete_github_repo(user, PkgDev.GitHub.token(), repo_name)

PackageGenerator.clean_up_failure(package,
    github_token = github_token,
    appveyor_token = appveyor_token)

# try again without appveyor token
PackageGenerator.generate(package,
    ssh_keygen_file = ssh_keygen_file,
    github_token = github_token)

PackageGenerator.clean_up_failure(package,
    github_token = github_token)
