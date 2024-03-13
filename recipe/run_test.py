#!/usr/bin/env python3

import difflib
import subprocess
import sys

print("Running " + sys.argv[0] + " ...\n")


def run(cmd, input, print_debug=False):
    print(f"echo {input} | {cmd}")
    args = cmd.split()
    env = {"PROJ_DEBUG": "3"}
    p = subprocess.run(args, input=input, text=True, capture_output=True, env=env)
    if print_debug:
        print("PROJ DEBUG output:")
        print(p.stderr)
    print(p.stdout)
    return p


# should be the first CLI test to ensure cs2cs results don't change
# See https://github.com/conda-forge/proj.4-feedstock/pull/139
r1 = run("cs2cs EPSG:26915 +to EPSG:26715", "569704.57 4269024.67")
r2 = run("cs2cs EPSG:26915 +to EPSG:26715", "569704.57 4269024.67")
if r1.stdout != r2.stdout:
    print("Different results! Here is the difference with PROJ_DEBUG=3:")
    d = difflib.Differ()
    e1 = r1.stderr.splitlines(keepends=True)
    e2 = r2.stderr.splitlines(keepends=True)
    sys.stdout.writelines(list(d.compare(e1, e2)))
    print()

_ = run("proj +proj=utm +zone=13 +ellps=WGS84", "-105 40")
_ = run("cs2cs +proj=latlong +datum=NAD27 +to +proj=latlong +datum=NAD83", "-117 30")
_ = run("cs2cs +init=epsg:4326 +to +init=epsg:2975", "-105 40")

print("done")
