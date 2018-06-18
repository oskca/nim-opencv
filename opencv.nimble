version       = "0.1.0"
author        = "Dominik Picheta"
description   = "OpenCV 3 wrapper"
license       = "MIT"

skipDirs = @["tests"]

requires "nim >= 0.9.3"

requires "nimgen >= 0.1.4"

import distros

import ospaths, strutils

proc patch(libName: string): string =
  let
    simpleLibPath = "include" / libName
    libPath = "/usr/local/include/opencv2" / libName
    patchPath = "c2nim" / "patch_" & libName
    outPath = "headers" / libName
    libContent =
      if fileExists(simpleLibPath): readFile(simpleLibPath)
      else: readFile(libPath).replace(" + FileStorage::MEMORY", "")
    patchContent = readFile(patchPath)
  writeFile(outPath, patchContent & libContent)
  return outPath

proc process(libName: string) =
  let
    headerName = libName.addFileExt("h")
    outPath = "opencv" / libName.addFileExt("nim")
    headerPath = patch(headerName)
  exec("c2nim --debug --cpp " & headerPath & " -o:" & outPath)

proc compile(libName: string) =
  let libPath = "opencv" / libName.addFileExt("nim")
  exec("nim c -c " & libPath)

let libs = [
  "core.hpp",
]

proc processAll() =
  exec("mkdir -p opencv")
  exec("mkdir -p headers")
  for lib in libs:
    process(lib)
  exec("rm headers/*")

proc compileAll() =
  compile("opencv")
  for lib in libs:
    compile(lib)

task headers, "generate bindings from headers":
  processAll()

task check, "check that generated bindings do compile":
  compileAll()

task docs, "generate documentation":
  exec("nim doc2 --project opencv/opencv.nim")

proc exampleConfig() =
  --hints: off
  --linedir: on
  --stacktrace: on
  --linetrace: on
  --debuginfo
  --cincludes: "/usr/local/cuda/include"
  --clibdir: "/usr/local/cuda/lib64"
  --path: "."
  --run

task pagerank, "run pagerank example":
  exampleConfig()
  setCommand "c", "examples/pagerank.nim"

task gen, "gen bindings":
    exec "nimgen -f opencv.cfg"
    exec "nim c -c opencv/core.nim"
    # exec "nim c opencv/types.nim"

task test, "Run tests":
    withDir("tests"):
        exec "nim c -r sshtest"
