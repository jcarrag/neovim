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
  stylua,
}:

let
  buildInputs = [
    lua-language-server
    vim-language-server
    vscode-langservers-extracted
    nodePackages.typescript-language-server
    nodePackages.prettier
    dockerfile-language-server-nodejs
    pyright
    gopls
    rust-analyzer
    nixd
    nixfmt-rfc-style
    metals
    cmake-language-server
    clang-tools
    stylua
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
    conform-nvim
    rustaceanvim
  ];
  # `@...@` is invalid syntax in lua, so inline unquote it when interpolating
  unescapeLua = (s: '']]${s},--[['');
  subsitutedInitLua = replaceVars ./init.lua {
    prettierPath = lib.pipe nodePackages.prettier [
      (s: ''command = "${s}/bin/prettier"'')
      unescapeLua
    ];
    vimPluginsPaths = lib.pipe _vimPlugins [
      (lib.concatMapStringsSep ",\n" (s: ''"${s}"''))
      unescapeLua
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
