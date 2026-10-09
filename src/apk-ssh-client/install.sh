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
WITH_KEYSIGN=${WITH_KEYSIGN:-true}
WITH_KERBEROS=${WITH_KERBEROS:-false}
WITH_SK_HELPER=${WITH_SK_HELPER:-false}

# Select the SSH client package. Check if Kerberos support is requested since that is mutually exclusive.
# Kerberos is unselected by default.
if [ "${WITH_KERBEROS}" = "true" ]; then
    APK_PACKAGE_LIST="openssh-client-krb5"
else
    APK_PACKAGE_LIST="openssh-client-default"
fi

# Optionally select SSH documentation. Selected by default.
if [ "${WITH_DOCS}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} openssh-doc"
fi

# Optionally select ssh-keysign. Selected by default.
if [ "${WITH_KEYSIGN}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} openssh-keysign"
fi

# Optionally select ssh-sk-helper. Unselected by default.
if [ "${WITH_SK_HELPER}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} openssh-sk-helper"
fi

# Update the APK package index and install the requested packages. Install
# the latest version of each package, upgrading dependencies if needed.
apk update --quiet
apk add --quiet --no-interactive --latest --upgrade ${APK_PACKAGE_LIST}

# Clean up APK cache.
apk cache --quiet --purge clean
rm -rf /var/cache/apk/*
