# PackageGenerator

[![travis badge][travis_badge]][travis_url]
[![codecov badge][codecov_badge]][codecov_url]

## Documentation [here][documenter_latest]

[travis_badge]: https://travis-ci.org/bramtayl/PackageGenerator.jl.svg?branch=master
[travis_url]: https://travis-ci.org/bramtayl/PackageGenerator.jl

[codecov_badge]: http://codecov.io/github/bramtayl/PackageGenerator.jl/coverage.svg?branch=master
[codecov_url]: http://codecov.io/github/bramtayl/PackageGenerator.jl?branch=master

[documenter_stable]: https://bramtayl.github.io/PackageGenerator.jl/stable
[documenter_latest]: https://bramtayl.github.io/PackageGenerator.jl/latest

## Basic usage instructions   

- Get GitHub and Appveyor tokens (see instructions [here](https://bramtayl.github.io/PackageGenerator.jl/latest/index.html#PackageGenerator.configure-Tuple))
- `PackageGenerator.configure(github_token, appveyor_token)`
- `p = Package("my_package_name")`
- `PackageGenerator.generate(p)`
