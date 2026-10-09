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
WITH_DOCS="${WITH_DOCS:-true}"
WITH_COMPLETION="${WITH_COMPLETION:-true}"
SET_AS_BIN_SH="${SET_AS_BIN_SH:-false}"

# Select the git package and its init templates.
APK_PACKAGE_LIST="bash"

# Optionally select Bash documentation. Selected by default.
if [ "${WITH_DOCS}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} bash-doc"
fi

# Optionally select Bash completion. Selected by default.
# Also add Bash completion documentation if WITH_DOCS is true.
if [ "${WITH_COMPLETION}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} bash-completion"
    if [ "${WITH_DOCS}" = "true" ]; then
        APK_PACKAGE_LIST="${APK_PACKAGE_LIST} bash-completion-doc"
    fi
fi

# Update the APK package index and install the requested packages. Install
# the latest version of each package, upgrading dependencies if needed.
apk update --quiet
apk add --quiet --no-interactive --latest --upgrade ${APK_PACKAGE_LIST}

# Optionally set Bash as /bin/sh. Unselected by default.
if [ "${SET_AS_BIN_SH}" = "true" ]; then
#    # Workaround for Alpine Linux, which does not provide this package quite yet.
#    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} bash-binsh"
    ln -sfn $(which bash) $(which sh)
fi

# Clean up APK cache.
apk cache --quiet --purge clean
rm -rf /var/cache/apk/*
