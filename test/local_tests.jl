using PackageGenerator
using Base.Test

package = "TestPackage" |> Package

try
    package.github_token |> PackageGenerator.get_travis_token

    generate(package)

    @test_throws ErrorException package |> PackageGenerator.AppVeyor |> PackageGenerator.check

    fake_travis = package |> PackageGenerator.Travis
    fake_travis.repo_name = "fake"
    @test_throws ErrorException PackageGenerator.set_repo_code!(fake_travis)
finally
    PackageGenerator.delete(package)
end
