Code conventions
================

For all participating projects there are the following code conventions:

#. Ubuntu is the supported Linux distribution

    The code is only tested with the Ubuntu Linux distribution. The code may run on other
    distributions, but we cannot guarantee this.

#. Locally executable Make targets

    The App SDK's interface for developers consists of Make targets, which are executed on the
    Linux command line. These can be executed with the default setup, meaning no environment
    variables need to be adjusted.

#. Every Make target is automatically tested

    The automated tests represent realistic scenarios and thus increase project maintainability.

#. Detailed documentation in the projects

    In addition to the documentation here, further documentation will be available in `README.md`
    files within the respective projects. Each subfolder also contains a `README.md` to make it
    easier to get started with the projects.

#. Naming variables

    Variables have meaningful names and are formulated in a consistent and descriptive manner, e.g.
    `JSON_CONFIG_FILE` is easier to speak than `FILE_JSON_CONFIG`. Unless the programming language
    specifies otherwise, local variables have only lowercase letters, and global variables have
    only uppercase letters.

#. Naming scripts

    Scripts have meaningful names. Shell scripts have the `.sh` suffix and are named in kebab-case,
    e.g. `foo-bar.sh`. Python scripts have the `.py` suffix and are named in snake_case,
    e.g. `foo_bar.py`.

#. No predefined Gitlab CI/CD variables

    The Make targets and dependent scripts do not handle Gitlab CI/CD variables. These are handled
    exclusively in the CI code, e.g., in the .gitlab-ci.yml file.

#. Environment variables have a `TQEM_` prefix

    The projects use the `TQEM_` prefix for their environment variables. This prevents conflicts
    and creates transparency, as the environment can be easily filtered by the prefix.

#. No hardcoded paths

    The projects use relative paths or environment variables to ensure portability across different
    environments.

#. No secrets, no credentials

    Credentials or secrets are not stored in the codebase. Instead, they are provided through
    environment variables or configuration files that are not included in the codebase.
