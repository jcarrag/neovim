{
  lib,
  replaceVars,
  wrapNeovim,
  neovim-unwrapped,
  vimPlugins,
  lua-language-server,
  vim-language-server,
  vscode-langservers-extracted,
  nodePackages,
  dockerfile-language-server-nodejs,
  pyright,
  gopls,
  clang-tools,
  rust-analyzer,
  nixd,
  nixfmt-rfc-style,
  metals,
  cmake-language-server,
}:

let
  buildInputs = [
    lua-language-server
    vim-language-server
    vscode-langservers-extracted
    nodePackages.typescript-language-server
    dockerfile-language-server-nodejs
    pyright
    gopls
    rust-analyzer
    nixd
    nixfmt-rfc-style
    metals
    cmake-language-server
    clang-tools
  ];
  _vimPlugins = with vimPlugins; [
    plenary-nvim
    lualine-nvim
    material-nvim
    auto-session
    nvim-treesitter
    nvim-treesitter.withAllGrammars
    nvim-treesitter-textobjects
    telescope-nvim
    fzf-lua
    project-nvim
    typescript-tools-nvim
    lspkind-nvim
    nvim-cmp
    nvim-lspconfig
    vim-abolish
    vim-surround
    vim-sleuth
    vim-repeat
    nvim-web-devicons
    surround-nvim
    vim-multiple-cursors
    csv-vim
    nvim-autopairs
    direnv-vim
    file-line
    rest-nvim
    markdown-preview-nvim
    repolink-nvim
    neo-tree-nvim
    fidget-nvim
    trouble-nvim
    comment-nvim
    gitsigns-nvim
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-dap-python
    rustaceanvim
  ];
  subsitutedInitLua = replaceVars ./init.lua {
    vimPluginsPaths = lib.pipe _vimPlugins [
      (lib.concatMapStringsSep ",\n" (s: ''"${s}"''))
      # `@...@` is invalid syntax in lua, so inline unquote it when interpolating
      (s: '']]${s},--[['')
    ];
  };
in
wrapNeovim neovim-unwrapped {
  extraMakeWrapperArgs = ''--prefix PATH : "${lib.makeBinPath buildInputs}"'';
  configure = {
    customRC = ''
      lua << EOF
        ${builtins.readFile subsitutedInitLua}
      EOF
    '';
    packages.myPlugins = {
      start = _vimPlugins;
    };
  };
}
