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

    branch = info.get("branch")
    if not branch:
        raise ValueError("Project branch is required")

    reference = info.get("reference")

    if not os.path.isdir(project_path):
        run([f"git clone {url} {project_path}"])
    else:
        # Always update origin URL on existing repositories as it may be overwritten locally
        run([f"git -C {project_path} remote set-url origin {url} || \
               git -C {project_path} remote add origin {url}"])

    run([f"git -C {project_path} fetch --tags --prune origin"])

    if reference:
        run([f"git -C {project_path} checkout {reference}"])
    else:
        run([f"git -C {project_path} checkout origin/{branch} -B {branch}"])

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
    parser.add_argument("-u", "--core-url", action="store_true",
                        help="Print git URL of the core (em-build).")
    parser.add_argument("-r", "--core-ref", action="store_true",
                        help="Print git reference of the core (em-build).")
    args = parser.parse_args()

    if args.core_url is True:
        get_url = config_data.get("projects", {}).get("yocto/em-build", {}).get("url", "")
        print(get_url)

    elif args.core_ref is True:
        get_reference = config_data.get("projects").get("yocto/em-build").get("reference")
        if get_reference is not None:
            print(get_reference)
        else:
            get_branch = config_data.get("projects").get("yocto/em-build").get("branch")
            print(get_branch)

    else:
        os.makedirs(BUILD_DIR, exist_ok=True)

        for project_name, project_info in config_data["projects"].items():
            update_git_repo(project_name, project_info)
