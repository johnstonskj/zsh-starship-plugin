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

###################################################################################################
# @section Setup
# @description Standard path and variable setup.
#

STARSHIP_PLUGIN_PATH="$(@zplugins_normalize_zero "$0")"

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

@zplugins_declare_plugin_dependencies starship completion

starship_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save starship STARSHIP_CONFIG
    typeset -g STARSHIP_CONFIG="$(xdg_config_for starship)/starship.toml"

    @completion_generate_local_file_from starship completions zsh
}

starship_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore starship STARSHIP_CONFIG
}
