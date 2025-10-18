# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  pkgs,
  r,
  ...
}:

{
  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      vim-surround
      vim-toml
      vim-numbertoggle
      mediawiki-vim
      vim-gitgutter
      vim-commentary
      vim-markdown
      vim-auto-save
      coc-basedpyright
      coc-docker
      coc-lua
      coc-sh
    ];
    coc = {
      enable = true;
      settings = {
        "suggest.noselect" = true;
      };
    };
    extraConfig = builtins.readFile (r.extras + /neovim-config.vim);
    extraLuaConfig = builtins.readFile (r.extras + /neovim-config.lua);
  };
}
