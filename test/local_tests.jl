using PackageGenerator

user = read(PackageGenerator.User)
configure(user.github_token, user.appveyor_token)
update_configuration(ssh_keygen_file = "C:/Program Files/Git/usr/bin/ssh-keygen")

package = "NewTestPackage10" |> Package |> generate

# should error
package |> PackageGenerator.AppVeyor |> PackageGenerator.check

fake_travis = package |> PackageGenerator.Travis
fake_travis.repo_name = "fake"
# should error reasonably
PackageGenerator.set_repo_code!(fake_travis)

PackageGenerator.delete(package)
