#!/usr/bin/env python3

import difflib
import os
import platform
import shutil
import subprocess
import sys

exit_code = 0


def print_env(name):
    if name in os.environ:
        print(f"{name} -> {os.environ[name]}")
    else:
        print(f"{name} is not set")


def run(cmd, input=None, print_inout=True, print_debug=False):
    if print_inout:
        if input:
            print(f"echo {input} | {cmd}")
        else:
            print(cmd)
    p = subprocess.run(cmd.split(), input=input, text=True, capture_output=True)
    if print_debug:
        print("PROJ DEBUG output:")
        print(p.stderr)
    if print_inout:
        print(p.stdout.strip())
    if p.returncode != 0:
        global exit_code
        exit_code += 1
        if not print_debug and p.stderr:
            print(p.stderr)
    return p


def run_twice(cmd, input):
    r1 = run(cmd, input)
    r2 = run(cmd, input, print_inout=False)
    if r1.stdout != r2.stdout:
        global exit_code
        exit_code += 1
        print(r2.stdout)
        print("Different results! Here are the differences with PROJ_DEBUG=2:")
        d = difflib.Differ()
        e1 = r1.stderr.splitlines(keepends=True)
        e2 = r2.stderr.splitlines(keepends=True)
        sys.stdout.writelines(list(d.compare(e1, e2)))
        print()
    else:
        print("(ran twice with the same output)")


print("PROJ test diagnostics ...\n")

print(f"platform.machine() -> {platform.machine()}")
os.environ["PROJ_DEBUG"] = "2"
print_env("PROJ_DEBUG")
print_env("PROJ_DATA")
print_env("PROJ_NETWORK")
print(f"which proj -> {shutil.which('proj')}")
print(f"which cs2cs -> {shutil.which('cs2cs')}")
if shutil.which("proj"):
    print(subprocess.run("proj", text=True, capture_output=True).stderr.splitlines()[0])
print()


# should be the first CLI test to ensure cs2cs results don't change
# See https://github.com/conda-forge/proj.4-feedstock/pull/139
run("projsync --file us_noaa_nadcon5_nad27_nad83_1986_conus.tif")
print()
run_twice("cs2cs EPSG:26915 +to EPSG:26715", "569704.57 4269024.67")
print()

run("proj +proj=utm +zone=13 +ellps=WGS84", "-105 40")
print()

run("cs2cs +proj=latlong +datum=NAD27 +to +proj=latlong +datum=NAD83", "-117 30")
print()

run("cs2cs +init=epsg:4326 +to +init=epsg:2975", "-105 40")
print()

print(f"Done {sys.argv[0]} with exit code {exit_code}")
sys.exit(exit_code)
