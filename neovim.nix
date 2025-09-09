{
  lib,
  replaceVars,
  wrapNeovim,
  neovim-unwrapped,
  fetchFromGitHub,
  vimUtils,
  vimPlugins,
  lua-language-server,
  vim-language-server,
  vscode-langservers-extracted,
  vscode-extensions,
  nodePackages,
  dockerfile-language-server-nodejs,
  pyright,
  ruff,
  gopls,
  clang-tools,
  rust-analyzer,
  nixd,
  nixfmt-rfc-style,
  metals,
  cmake-language-server,
  stylua,
  marksman,
  bash-language-server,
  shfmt,
}:

let
  buildInputs = [
    lua-language-server
    vim-language-server
    vscode-langservers-extracted
    vscode-extensions.ms-vscode.cpptools
    nodePackages.typescript-language-server
    nodePackages.prettier
    dockerfile-language-server-nodejs
    pyright
    ruff
    gopls
    rust-analyzer
    nixd
    nixfmt-rfc-style
    metals
    cmake-language-server
    clang-tools
    stylua
    marksman
    bash-language-server
    shfmt
  ];
  _vimPlugins =
    let
      calendar-vim = vimUtils.buildVimPlugin {
        pname = "calendar-vim";
        version = "2025-08-29";
        src = fetchFromGitHub {
          owner = "nvim-telekasten";
          repo = "calendar-vim";
          rev = "master";
          sha256 = "sha256-4XeDd+myM+wtHUsr3s1H9+GAwIjK8fAqBbFnBCeatPo=";
        };
      };
    in
    with vimPlugins;
    [
      plenary-nvim
      lualine-nvim
      material-nvim
      auto-session
      firenvim
      nvim-treesitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      telescope-nvim
      fzf-lua
      project-nvim
      typescript-tools-nvim
      lspkind-nvim
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-cmdline
      cmp_luasnip
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
      # when entering a .envrc dir, this will override the $PATH defined by the
      # buildInputs above, which breaks all LSPs integrations as their underlying
      # LSP server binaries are no longer available on $PATH
      # direnv-vim
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
      luasnip
      rustaceanvim
      telekasten-nvim
      calendar-vim
    ];
  subsitutedInitLua = replaceVars ./init.lua {
    vimPluginsPaths = lib.pipe _vimPlugins [
      (lib.concatMapStringsSep ",\n" (s: ''"${s}"''))
      # `@...@` is invalid syntax in lua, so inline unquote it when interpolating
      (s: ''
        ]]
        ${s},
        --[['')
    ];
  };
in
wrapNeovim neovim-unwrapped {
  extraMakeWrapperArgs = ''--prefix PATH : "${lib.makeBinPath buildInputs}"'';
  configure = {
    customRC = ''
      lua << EOF
        ${builtins.readFile (lib.traceValFn (v: "init.lua: ${v}") subsitutedInitLua)}
      EOF
    '';
    packages.myPlugins = {
      start = _vimPlugins;
    };
  };
}
