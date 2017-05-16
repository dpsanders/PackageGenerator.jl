using PackageGenerator

user = read(PackageGenerator.User)
package_was_created = false

try
    configure(user.github_token, user.appveyor_token;
        ssh_keygen_file = user.ssh_keygen_file)

    package = "TestPackage" |> Package |> generate
    package_was_created = true

    # should error
    @test_throws ErrorException package |> PackageGenerator.AppVeyor |> PackageGenerator.check

    fake_travis = package |> PackageGenerator.Travis
    fake_travis.repo_name = "fake"
    # should error reasonably
    @test_throws ErrorException PackageGenerator.set_repo_code!(fake_travis)

finally
    if package_was_created
        PackageGenerator.delete(package)
    end
    write(user)
end
