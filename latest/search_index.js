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
    "text": "generate(package; license = \"MIT\", path_to_ssh_keygen = \"\")\n\nGenerate a package named package with some nice bells and whistles. These include:\n\na matching github repository\nan activated repository on travis\ngenerated documentation that\nautomatically syncs to changes on github\nincludes doctests as part of your package testing suite\n\nThe package defaults to the \"MIT\" license. See PkgDev for other options.\n\nssh-keygen is required. If it is not on your path, make sure to include a path to it. ssh-keygen is sometimes packaged with git. If you are on Windows, PackageGenerator will automatically check \"C:/Program Files/Git/usr/bin\" for it. If you are on Ubuntu, and don't yet have it installed, try sudo apt-get install openssh-client. Then you won't need to include a path.\n\nFor LibGit2.push to work,  follow the instructions here \n\n\n\n"
},

{
    "location": "index.html#PackageGenerator.jl-1",
    "page": "Home",
    "title": "PackageGenerator.jl",
    "category": "section",
    "text": "Documentation for PackageGenerator.jlModules = [PackageGenerator]"
},

]}
