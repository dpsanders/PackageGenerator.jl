var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#PackageGenerator.Package",
    "page": "Home",
    "title": "PackageGenerator.Package",
    "category": "Type",
    "text": "Package(package_name)\n\nGenerate a default package based on a package name. To customize your package, you can edit any of its fields before generateing it. The package will include all the fields discussed in configure, package_name, as well as the following defaults (override with keyword arguments).\n\nrepo_name = string(package_name, \".jl\")\n\nThe name of your repository on github.\n\nyear = string(Dates.year(Dates.today()))\n\nThe copyright year. Defaults to the current year.\n\n\n\n"
},

{
    "location": "index.html#PackageGenerator.configure-Tuple",
    "page": "Home",
    "title": "PackageGenerator.configure",
    "category": "Method",
    "text": "configure(github_token, appveyor_token)\n\nWrite out a user configuration file (\".package_generator.json\" in your package directory).\n\nRequires a github_token, which can be generated here. Make sure to check the \"public_repo\" and \"delete_repo\" scopes (if you want to be able to delete half-created repositories in case PackageGenerator hits an error).\n\nAlso requires an appveyor_token, which can be found here\n\nIncludes various defaults that can be overwritten with keyword arguments.\n\nssh_keygen_file = \"ssh-keygen\"\n\nThe path to ssh-keygen. ssh-keygen makes a pair of keys that allows Travis to communicate with Github. For Linux users with git installed, the default file should be fine. For Windows users with git installed, try ssh_keygen_file = \"C:/Program Files/Git/usr/bin/ssh-keygen\".\n\ntravis_token = get_travis_token(github_token)\n\nA travis token can be generated automatically from your github token\n\npackage_directory = Pkg.Dir.path()\n\nWhere to put your new packages\n\nauthors = LibGit2.getconfig(\"user.name\", \"\")\n\nWho are the authors of your packages?\n\nuser_name = LibGit2.getconfig(\"github.user\", \"\")\n\nWhat is your github username?\n\nsync_time = 60\n\nHow many seconds to wait for API calls to complete.\n\n\n\n"
},

{
    "location": "index.html#PackageGenerator.generate-Tuple{PackageGenerator.Package}",
    "page": "Home",
    "title": "PackageGenerator.generate",
    "category": "Method",
    "text": "generate(package::Package)\n\nGenerate a Package with some nice bells and whistles. These include:\n\na matching github repository\ntesting with travis\ntesting with appveyor\ngenerated documentation that\nautomatically syncs to changes on github\nincludes doctests as part of your package testing suite\n\nOf course, this means you need github, travis, and appveyor accounts.\n\nIf you haven't set up an ssh key for git, follow the instructions here.\n\nThe license will be the MIT license. To change, use PkgDev.Generate.license\n\n\n\n"
},

{
    "location": "index.html#PackageGenerator.update_configuration-Tuple{}",
    "page": "Home",
    "title": "PackageGenerator.update_configuration",
    "category": "Method",
    "text": "update_configuration(; kwargs...)\n\nUpdate any of the user configurations discussed in configure.\n\n\n\n"
},

{
    "location": "index.html#PackageGenerator.jl-1",
    "page": "Home",
    "title": "PackageGenerator.jl",
    "category": "section",
    "text": "Modules = [PackageGenerator]If you would like to run tests locally, first configure then try running tests/local_tests.jl (and report any errors!). This will test parts of the package that are not tested through CI."
},

]}
