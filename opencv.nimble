version       = "0.1.0"
author        = "Dominik Picheta"
description   = "OpenCV 3 wrapper"
license       = "MIT"

skipDirs = @["tests"]

requires "nim >= 0.9.3"

requires "nimgen >= 0.1.4"

import distros

task gen, "gen bindings":
    exec "nimgen -f opencv.cfg"
    exec "nim c -c opencv/core.nim"
    # exec "nim c opencv/types.nim"

task test, "Run tests":
    withDir("tests"):
        exec "nim c -r sshtest"
