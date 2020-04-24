# Package

version       = "0.1.0"
author        = "Colin Coombs"
description   = "A simple literate-programming tool"
license       = "Unlicence"
srcDir        = "src"
bin           = @["wangle"]


# Dependencies

requires "nim >= 0.19.2"
requires "regex >= 0.12.0"
requires "docopt"
