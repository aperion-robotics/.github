#!/usr/bin/env python3
"""Print the names of the ROS packages in a repository, space-separated.

Hidden directories (.aperion-ci, .aperion-upstream, .git, ...) and the
action-ros-ci workspace (ros_ws) are skipped, as are trees marked with
COLCON_IGNORE. Like colcon, packages are not searched inside packages.
"""

import os
import re
import sys

root = sys.argv[1] if len(sys.argv) > 1 else "."
names = set()

for path, dirs, files in os.walk(root):
    if "COLCON_IGNORE" in files:
        dirs[:] = []
        continue
    if "package.xml" in files:
        with open(os.path.join(path, "package.xml")) as manifest:
            match = re.search(r"<name>\s*([^<\s]+)\s*</name>", manifest.read())
        if match:
            names.add(match.group(1))
        dirs[:] = []
        continue
    dirs[:] = [
        d for d in dirs
        if not d.startswith(".") and not (path == root and d == "ros_ws")
    ]

if not names:
    sys.exit("No ROS packages (package.xml) found in " + root)

print(" ".join(sorted(names)))
