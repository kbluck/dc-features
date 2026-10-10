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
WITH_OH_MY_ZSH="${WITH_OH_MY_ZSH:-true}"
WITH_CALENDAR="${WITH_CALENDAR:-false}"
WITH_EXTRA_COMPLETIONS="${WITH_EXTRA_COMPLETIONS:-false}"
WITH_FAST_SYNTAX_HIGHLIGHTING="${WITH_FAST_SYNTAX_HIGHLIGHTING:-false}"
WITH_FISH_AUTOSUGGESTIONS="${WITH_FISH_AUTOSUGGESTIONS:-false}"
WITH_FISH_HISTORY_SEARCH="${WITH_FISH_HISTORY_SEARCH:-false}"
WITH_FISH_SYNTAX_HIGHLIGHTING="${WITH_FISH_SYNTAX_HIGHLIGHTING:-false}"
WITH_MULTIWORD_HISTORY_SEARCH="${WITH_MULTIWORD_HISTORY_SEARCH:-false}"
WITH_PCRE="${WITH_PCRE:-false}"
WITH_SHIFT_SELECT="${WITH_SHIFT_SELECT:-false}"
WITH_VCS="${WITH_VCS:-false}"
WITH_ZFTP="${WITH_ZFTP:-false}"
SET_AS_BIN_SH="${SET_AS_BIN_SH:-false}"

# Select the git package and its init templates.
APK_PACKAGE_LIST="zsh"

# Optionally select Zsh documentation. Selected by default.
if [ "${WITH_DOCS}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-doc"
fi

if [ "${WITH_OH_MY_ZSH}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} oh-my-zsh"
    if [ "${WITH_DOCS}" = "true" ]; then
        APK_PACKAGE_LIST="${APK_PACKAGE_LIST} oh-my-zsh-doc"
    fi
fi

# Optionally select calendar function system. Unselected by default.
if [ "${WITH_CALENDAR}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-calendar"
fi

# Optionally select extra community completions. Unselected by default.
if [ "${WITH_EXTRA_COMPLETIONS}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-completions"
fi

# Optionally select fast syntax highlighting. Unselected by default.
if [ "${WITH_FAST_SYNTAX_HIGHLIGHTING}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-fast-syntax-highlighting"
    if [ "${WITH_DOCS}" = "true" ]; then
        APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-fast-syntax-highlighting-doc"
    fi
fi

# Optionally select Fish-like autosuggestions. Unselected by default.
if [ "${WITH_FISH_AUTOSUGGESTIONS}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-autosuggestions"
fi

# Optionally select Fish-like history search. Unselected by default.
if [ "${WITH_FISH_HISTORY_SEARCH}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-history-substring-search"
fi

# Optionally select Fish-like syntax highlighting. Unselected by default.
if [ "${WITH_FISH_SYNTAX_HIGHLIGHTING}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-syntax-highlighting"
    if [ "${WITH_DOCS}" = "true" ]; then
        APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-syntax-highlighting-doc"
    fi
fi

# Optionally select history search multiword module. Unselected by default.
if [ "${WITH_MULTIWORD_HISTORY_SEARCH}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-history-search-multi-word"
fi

# Optionally select PCRE module. Unselected by default.
if [ "${WITH_PCRE}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-pcre"
fi

# Optionally select shift-selection module. Unselected by default.
if [ "${WITH_SHIFT_SELECT}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-shift-select"
fi

# Optionally select VCS information module. Unselected by default.
if [ "${WITH_VCS}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-vcs"
fi

# Optionally select ZFTP function system. Unselected by default.
if [ "${WITH_ZFTP}" = "true" ]; then
    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-zftp"
fi

# Update the APK package index and install the requested packages. Install
# the latest version of each package, upgrading dependencies if needed.
apk update --quiet
apk add --quiet --no-interactive --latest --upgrade ${APK_PACKAGE_LIST}

# Optionally set Zsh as /bin/sh. Unselected by default.
if [ "${SET_AS_BIN_SH}" = "true" ]; then
#    # Workaround for Alpine Linux, which does not provide this package quite yet.
#    APK_PACKAGE_LIST="${APK_PACKAGE_LIST} zsh-binsh"
    ln -sfn $(which zsh) $(which sh)
fi

# Clean up APK cache.
apk cache --quiet --purge clean
rm -rf /var/cache/apk/*
