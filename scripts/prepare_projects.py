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

import os
import subprocess
import yaml


CONFIG = "projects.yaml"
BUILD_DIR = "build"

LOCAL_CONFIG = os.path.join("local", CONFIG)

def run(cmd):
    ''' Run a command and check the return value '''
    subprocess.run(cmd, shell=True, check=True)

def update_git_repo(project):
    ''' Update a git repository '''

    name = project.get("name")
    if not name:
        raise ValueError("Project name is required")
    project_path = os.path.join(BUILD_DIR, name)

    url = project.get("url")
    if not url:
        raise ValueError("Project URL is required")

    branch = project.get("branch")
    if not branch:
        raise ValueError("Project branch is required")

    reference = project.get("reference")

    if not os.path.isdir(project_path):
        run([f"git clone {url} {project_path}"])
    else:
        # Always update origin URL on existing repositories as it may be overwritten locally
        run([f"git -C {project_path} remote set-url origin {url}"])

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

os.makedirs(BUILD_DIR, exist_ok=True)

# Fetch or update the projects
for git_repo in config_data.get("toolchain", []):
    update_git_repo(git_repo)

for git_repo in config_data.get("demo", []):
    update_git_repo(git_repo)
