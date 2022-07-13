# ranger_nvim
A ranger plugin for Neovim written in lua that respects your rifle config. 
This plugin is made to mimic the default Ranger behavior and integrate nicely
with Neovim.  

## Features 
* Respects your rifle (ranger default file launcher) config. 
* Files opened with Neovim are added to your buffer list; no nested Neovim
  sessions.

## Installation 
Requirements: 
* Ranger file manager 
* NVIM v0.7 or higher
* Linux

Install with Packer: 
`use 'jensjpedersen/ranger_nvim'` 

## Usage
Set keymap to open ranger: 
`nnoremap <leader>f lua require'ranger_nvim'.ranger_nvim()<CR>` 





