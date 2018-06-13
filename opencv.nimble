version       = "0.1.0"
author        = "Dominik Picheta"
description   = "OpenCV 3 wrapper"
license       = "MIT"

skipDirs = @["tests"]

requires "nim >= 0.9.3"

requires "nimgen >= 0.1.4"

import distros

before build:
    exec "nimgen opencv.cfg"

task test, "Run tests":
    withDir("tests"):
        exec "nim c -r sshtest"
