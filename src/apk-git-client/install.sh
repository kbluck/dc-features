#!/bin/sh

# Exit on any untrapped error result.
set -e

# Check for minimal system requirements and return error if not met.
if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root.'
    exit 1
fi
if ! type apk > /dev/null 2>&1; then
    echo 'APK package manager must be available.'
    exit 1
fi

# Set default values for unset feature parameters.
WITH_DOCS=${WITH_DOCS:-true}
WITH_GIT_LFS=${WITH_GIT_LFS:-true}
WITH_GIT_PROMPT=${WITH_GIT_PROMPT:-true}
WITH_GIT_SCALAR=${WITH_GIT_SCALAR:-false}
WITH_GIT_SIZER=${WITH_GIT_SIZER:-false}
WITH_GIT_SUBTREE=${WITH_GIT_SUBTREE:-false}

# Select the git package and its init templates.
APK_PACKAGE_LIST="git git-init-template"

# Optionally select Git documentation. Selected by default.
if [ "${WITH_DOCS}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} git-doc"
fi

# Optionally select git-lfs plugin. Selected by default.
if [ "${WITH_GIT_LFS}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} git-lfs"
fi

# Optionally select git-prompt plugin. Selected by default.
if [ "${WITH_GIT_PROMPT}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} git-prompt"
fi

# Optionally select git-scalar plugin. Unselected by default.
if [ "${WITH_GIT_SCALAR}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} git-scalar"
fi

# Optionally select git-sizer utility. Unselected by default.
if [ "${WITH_GIT_SIZER}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} git-sizer"
fi

# Optionally select git-subtree plugin. Unselected by default.
# Add git-subtree documentation if WITH_DOCS is true.
if [ "${WITH_GIT_SUBTREE}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} git-subtree"
    if [ "${WITH_DOCS}" = "true" ]; then
        APK_PACKAGE_LIST="${APK_PACKAGE_LIST} git-subtree-doc"
    fi
fi

# Update the APK package index and install the requested packages. Install
# the latest version of each package, upgrading dependencies if needed.
apk update --quiet
apk add --quiet --no-interactive --latest --upgrade ${APK_PACKAGE_LIST}

# Clean up APK cache.
apk cache --quiet --purge clean
rm -rf /var/cache/apk/*
