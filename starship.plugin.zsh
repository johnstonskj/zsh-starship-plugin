# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name: starship
# @brief: Setup Starship prompt for Zsh shells.
# @repository: https://github.com/johnstonskj/zsh-starship-plugin
# @version: 0.1.1
# @license: MIT AND Apache-2.0
#
# ### Public Variables
#
# * `STARSHIP_CONFIG`; location of the starship configuration file.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

starship_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save starship STARSHIP_CONFIG
    export STARSHIP_CONFIG="$(xdg_config_for starship)/starship.toml"

    local completion_dir="$(@zplugins_plugin_functions_dir starship create)"
    local completion_file="${completion_dir}/_starship"
    starship completions zsh > "${completion_file}"
    autoload -Uz _starship
    @zplugins_remember_fn starship _starship
}

starship_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore starship STARSHIP_CONFIG
}
