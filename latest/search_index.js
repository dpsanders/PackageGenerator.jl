var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#PackageGenerator.generate-Tuple{Any}",
    "page": "Home",
    "title": "PackageGenerator.generate",
    "category": "Method",
    "text": "generate(package)\n\nGenerate a package named package with some nice bells and whistles. These include:\n\na matching github repository\nan activated repository on travis (and optionally, an activated appveyor   project)\ngenerated documentation that\nautomatically syncs to changes on github\nincludes doctests as part of your package testing suite\n\nOf course, this means you need both a github and a travis account. If you haven't set up an ssh key for git, follow the instructions here.\n\nRun in the REPL for best results. By default, tests will fail. Documentation will not build until tests pass.\n\nSeveral optional keywords exist: the most important ones are discussed below.\n\nlicense = \"MIT\"\n\nThe package defaults to the \"MIT\" license. See PkgDev for other options.\n\nssh_keygen_file = \"ssh-keygen\"\n\nssh-keygen makes a pair of keys that allows Travis to communicate with Github. For Linux users with git installed, the default file should be fine. For Windows users with git installed, try ssh_keygen_file = \"C:/Program Files/Git/usr/bin/ssh-keygen\".\n\nappveyor_token = \"\"\n\nYour appveyor_token is available here. Include the token in order to automatically make an appveyor project for your repo.\n\nSee documentation for more keyword options.\n\n\n\n"
},

{
    "location": "index.html#PackageGenerator.generate_offline-Tuple{Any}",
    "page": "Home",
    "title": "PackageGenerator.generate_offline",
    "category": "Method",
    "text": "generate_offline(package, license = \"MIT\")\n\nOnly the offline components of generate (see for more documentation)\n\nCreate a local git repository containing package files.\n\n\n\n"
},

{
    "location": "index.html#PackageGenerator.generate_online-Tuple{Any}",
    "page": "Home",
    "title": "PackageGenerator.generate_online",
    "category": "Method",
    "text": "generate_online(repo_name; ssh_keygen_file = \"ssh-keygen\", appveyor_token = \"\")\n\nOnly the online components of generate (see for more documentation)\n\nSet up a linked github and travis account for a certain repository.\n\n\n\n"
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
