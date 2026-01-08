# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: starship
# Description: Setup starship prompt for Zsh shells.
# Repository: https://github.com/johnstonskj/zsh-starship-plugin
#
# Public variables:
#
# * `STARSHIP`; plugin-defined global associative array with the following keys:
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_OLD_STARSHIP_CONFIG`; the old starship configuration value.
# * `STARSHIP_CONFIG`; location of the starship configuration file.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA STARSHIP
STARSHIP[_PLUGIN_DIR]="${0:h}"
STARSHIP[_ALIASES]=""
STARSHIP[_FUNCTIONS]=""

# Saving the current state for any modified global environment variables.
STARSHIP[_OLD_STARSHIP_CONFIG]="${STARSHIP_CONFIG}"

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `STARSHIP[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
# See https://wiki.zshell.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
#
.starship_remember_fn() {
    builtin emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${STARSHIP[_FUNCTIONS]}" ]]; then
        STARSHIP[_FUNCTIONS]="${fn_name}"
    elif [[ ",${STARSHIP[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        STARSHIP[_FUNCTIONS]="${STARSHIP[_FUNCTIONS]},${fn_name}"
    fi
}
.starship_remember_fn .starship_remember_fn

.starship_define_alias() {
    local alias_name="${1}"
    local alias_value="${2}"

    alias ${alias_name}=${alias_value}

    if [[ -z "${STARSHIP[_ALIASES]}" ]]; then
        STARSHIP[_ALIASES]="${alias_name}"
    elif [[ ",${STARSHIP[_ALIASES]}," != *",${alias_name},"* ]]; then
        STARSHIP[_ALIASES]="${STARSHIP[_ALIASES]},${alias_name}"
    fi
}
.starship_remember_fn .starship_remember_alias

#
# This function does the initialization of variables in the global variable
# `STARSHIP`. It also adds to `path` and `fpath` as necessary.
#
starship_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    export STARSHIP_CONFIG="$(xdg_config_for starship)/starship.toml"
}
.starship_remember_fn starship_plugin_init

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
starship_plugin_unload() {
    builtin emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${STARSHIP[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done
        
    # Remove all remembered aliases.
    local aliases
    IFS=',' read -r -A aliases <<< "${STARSHIP[_ALIASES]}"
    local alias
    for alias in ${aliases[@]}; do
        unalias "${alias}"
    done

    # Reset global environment variables .
    export STARSHIP_CONFIG="${STARSHIP[_OLD_STARSHIP_CONFIG]}"
    
    # Remove the global data variable.
    unset STARSHIP

    # Remove this function.
    unfunction starship_plugin_unload
}

############################################################################
# Initialize Plugin
############################################################################

starship_plugin_init
eval "$(starship init zsh)"

true
