#!/usr/bin/env python3
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the app sdk project.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany.
# All rights reserved.
#
# Author: Christoph Krutz

''' Handle the projects.yml file. '''

import argparse
import os
import subprocess
# pylint: disable=E0401
# TBD: Remove this pylint-disable if the missing module is installed in the test image
import yaml
# pylint: enable=E0401

CONFIG = "projects.yaml"
BUILD_DIR = "build"

LOCAL_CONFIG = os.path.join("local", CONFIG)

def run(cmd):
    ''' Run a command and check the return value '''
    subprocess.run(cmd, shell=True, check=True)

def update_git_repo(name, info):
    ''' Update a git repository '''

    if not name:
        raise ValueError("Project name is required")
    print(f"Updating {name} project...")

    project_path = os.path.join(BUILD_DIR, name)

    url = info.get("url")
    if not url:
        raise ValueError("Project URL is required")

    reference = info.get("ref")
    if not reference:
        raise ValueError("Project reference is required")

    if not os.path.isdir(project_path):
        run([f"git clone {url} {project_path}"])
    else:
        # Always update origin URL on existing repositories as it may be overwritten locally
        run([f"git -C {project_path} remote set-url origin {url}"])

    run([f"git -C {project_path} fetch --tags --prune origin"])
    run([f"git -C {project_path} checkout {reference}"])

# Load config(s)
if not os.path.isfile(CONFIG):
    os.error(f"Cannot find {CONFIG} file")

with open(CONFIG, mode="r", encoding="utf-8") as f:
    config_data = yaml.safe_load(f)

# Add local config if existent
if os.path.isfile(LOCAL_CONFIG):
    with open(LOCAL_CONFIG, mode="r", encoding="utf-8") as f:
        config_data = yaml.safe_load(f)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process the projects.yml file.")
    parser.add_argument("-u", "--url", type=str,
                        help="Print git URL.")
    parser.add_argument("-r", "--ref", type=str,
                        help="Print git reference.")
    args = parser.parse_args()

    if args.url:
        get_url = config_data.get("projects").get(args.url).get("url", "")
        print(get_url)
        os.sys.exit(0)

    if args.ref:
        get_reference = config_data.get("projects").get(args.ref).get("ref")
        if get_reference is not None:
            print(get_reference)
        os.sys.exit(0)

    os.makedirs(BUILD_DIR, exist_ok=True)
    for project_name, project_info in config_data["projects"].items():
        update_git_repo(project_name, project_info)
