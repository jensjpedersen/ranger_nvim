# ranger_nvim
A Ranger plugin for Neovim written in lua that respects your rifle config. 
This plugin is made to mimic the default Ranger behavior and integrate nicely
with Neovim.  

## Features 
* ranger_nvim respects your rifle (Ranger's default file
  launcher) configuration, ensuring consistency in file handling.
* Files opened with Neovim using ranger_nvim are
  automatically added to your buffer list, avoiding nested Neovim sessions. 
  
## Installation 

* Install ranger file manager on linux (Debian/Ubuntu):
`sudo apt install ranger`

* Install plugin with Packer: 
`use 'jensjpedersen/ranger_nvim'` 

* Run the setup function in your Lua configuration: 
`require("ranger_nvim").setup({})` 


### Requirements: 
* **Ranger file manager**
* NVIM v0.7 or higher
* Linux



## Configuration 
To customize ranger_nvim according to your preferences, you can adjust the
configuration options.

### Default configuration:
```lua
require("ranger_nvim").setup({
    fileopener = "rifle",
    mapping = '<leader>f',
})
```

### Options:
* fileopener: options (string): "rifle" (default), "xdg-open," or "nvim" - Set the file opener to use with Ranger.
* mapping: string - Set the keymap to open Ranger within Neovim.
