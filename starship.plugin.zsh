# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name starship
# @description Setup starship prompt for Zsh shells.
# @repository https://github.com/johnstonskj/zsh-starship-plugin
#
# Public variables:
#
# ### State Variables
#
# * **PLUGIN**: Plugin-defined global associative array with the following keys:
#   * **_PATH**: The path to the plugin's sourced file.
#
# ### Public Variables
#
# * `STARSHIP_CONFIG`; location of the starship configuration file.
#

############################################################################
# @section Setup
# @description Standard path and variable setup.
#

typeset -A PLUGIN
PLUGIN[_PATH]="$(@zplugins_normalize_zero "$0")"

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

starship_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    @zplugins_envvar_save STARSHIP_CONFIG
    export STARSHIP_CONFIG="$(xdg_config_for starship)/starship.toml"

    local completion_file="${PLUGIN[_PATH]:h}/functions/_starship"
    starship completions zsh > "${completion_file}"
    autoload -Uz "${completion_file}"
    @zplugins_remember_fn starship "${completion_file:t}"
}

starship_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore STARSHIP_CONFIG
    
    unset PLUGIN
}
