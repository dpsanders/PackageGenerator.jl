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
    "text": "Package(package_name)\n\nGenerate a default package based on a package name. To customize you pacakge, you can edit any of its fields before generateing it. The package will include all the fields discussed in configure, package_name, as well as:\n\nrepo_name = string(package_name, \".jl\")\n\nThe name of your repository on github.\n\nyear = string(Dates.year(Dates.today()))\n\nThe copyright year. Defaults to the current year.\n\n\n\n"
},

{
    "location": "index.html#PackageGenerator.configure-Tuple",
    "page": "Home",
    "title": "PackageGenerator.configure",
    "category": "Method",
    "text": "configure(github_token, appveyor_token)\n\nWrite out a user configuration file.\n\nRequires a github_token, which can be generated here. Make sure to check the \"public_repo\" and \"delete_repo\" scopes (if you want to be able to delete half-created repositories in case PackageGenerator hits an error).\n\nAlso requires an appveyor_token, which can be found here\n\nIncludes various defaults that can be overwritten with keyword arguments.\n\nssh_keygen_file = \"ssh-keygen\"\n\nThe path to ssh-keygen. ssh-keygen makes a pair of keys that allows Travis to communicate with Github. For Linux users with git installed, the default file should be fine. For Windows users with git installed, try ssh_keygen_file = \"C:/Program Files/Git/usr/bin/ssh-keygen\".\n\ntravis_token = get_travis_token(github_token)\n\nA travis token can be generated automatically from your github token\n\npackage_directory = Pkg.Dir.path()\n\nWhere to put your new packages\n\nlicense = \"MIT\"\n\nWhat license to use. See PkgDev.jl for more options.\n\nauthors = LibGit2.getconfig(\"user.name\", \"\")\n\nWho are the authors of your packages?\n\nuser_name = LibGit2.getconfig(\"github.user\", \"\")\n\nWhat is your github username?\n\nsync_time = 60\n\nHow many seconds to wait for API calls to complete. 60 is overly cautious by design.\n\n\n\n"
},

{
    "location": "index.html#PackageGenerator.generate-Tuple{PackageGenerator.Package}",
    "page": "Home",
    "title": "PackageGenerator.generate",
    "category": "Method",
    "text": "generate(package::Package)\n\nGenerate a package named package with some nice bells and whistles. These include:\n\na matching github repository\nan activated repository on travis (and optionally, an activated appveyor   project)\ngenerated documentation that\nautomatically syncs to changes on github\nincludes doctests as part of your package testing suite\n\nOf course, this means you need both a github and a travis account. If you haven't set up an ssh key for git, follow the instructions here.\n\nYou must include a Package\n\n\n\n"
},

{
    "location": "index.html#PackageGenerator.update_configuration-Tuple{}",
    "page": "Home",
    "title": "PackageGenerator.update_configuration",
    "category": "Method",
    "text": "update_configuration(; kwargs)\n\nUpdate any of the user configurations discussed in configure.\n\n\n\n"
},

{
    "location": "index.html#PackageGenerator.jl-1",
    "page": "Home",
    "title": "PackageGenerator.jl",
    "category": "section",
    "text": "Modules = [PackageGenerator]"
},

{
    "location": "index.html#Advanced-usage-1",
    "page": "Home",
    "title": "Advanced usage",
    "category": "section",
    "text": "For advanced users, there are several undocumented keywords for generate. They are listed below, along with their default values.path = joinpath(Pkg.Dir.path(), package)The folder where files will be generatedauthors = LibGit2.getconfig(\"user.name\", \"\")The authors of the package. Interpolated directly into the license.years = PkgDev.Generate.copyright_year()The copyright year. Interpolated directly into the license.user = PkgDev.GitHub.user()Your github usernamerepo_name = string(package, \".jl\")The desired name of the github repositorygithub_token = PkgDev.GitHub.token()Your token to access the GitHub API. The default token does not have permissions to delete repositories, which will cause a hiccup in the case of an error. Make your own with permission to delete repositories heretravis_token = get_travis_token(github_token)Your token to access the Travis APIappveyor_slug = default_appveyor_slug(repo_name)The name of the appveyor project for your repository. If an appveyor token is given, the actual appveyor_slug will be used instead."
},

]}
