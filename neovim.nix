{
  lib,
  replaceVars,
  wrapNeovim,
  neovim-unwrapped,
  vimPlugins,
  lua-language-server,
  vim-language-server,
  vscode-js-debug,
  vscode-langservers-extracted,
  vscode-extensions,
  dockerfile-language-server,
  typescript-go,
  prettier,
  pyright,
  ruff,
  eslint,
  gopls,
  kotlin-lsp,
  clang-tools,
  rust-analyzer,
  nixd,
  nixfmt,
  cmake-language-server,
  stylua,
  bash-language-server,
  shfmt,
  libfaketime,
}:

let
  # Tools that need to be on PATH (formatters, linters, etc.)
  # LSP servers now use absolute paths via replaceVars
  buildInputs = [
    vscode-js-debug
    vscode-extensions.ms-vscode.cpptools
    prettier
    ruff
    eslint
    rust-analyzer
    stylua
    shfmt
  ];
  _vimPlugins = with vimPlugins; [
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
    obsidian-nvim
    typescript-tools-nvim
    lspkind-nvim
    lsp_lines-nvim
    nvim-cmp
    cmp-nvim-lsp
    cmp-buffer
    cmp-cmdline
    cmp-nvim-lua
    cmp-path
    cmp_luasnip
    nvim-lint
    nvim-lspconfig
    vim-abolish
    vim-surround
    vim-sleuth
    vim-repeat
    nvim-web-devicons
    nvim-colorizer-lua
    surround-nvim
    vim-multiple-cursors
    csv-vim
    nvim-autopairs
    # when entering a .envrc dir, this will override the $PATH defined by the
    # buildInputs above, which breaks all LSPs integrations as their underlying
    # LSP server binaries are no longer available on $PATH
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
    nvim-dap-vscode-js
    conform-nvim
    luasnip
    rustaceanvim
    codecompanion-nvim
  ];
  subsitutedInitLua = replaceVars ./init.lua {
    inherit
      nixfmt
      dockerfile-language-server
      vscode-js-debug
      lua-language-server
      cmake-language-server
      nixd
      vscode-langservers-extracted
      gopls
      kotlin-lsp
      pyright
      vim-language-server
      clang-tools
      bash-language-server
      rust-analyzer
      libfaketime
      typescript-go
      ;
    cpptools = vscode-extensions.ms-vscode.cpptools;
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
  # lua deps required by rest-nvim; without them its plugin script errors on startup
  extraLuaPackages = ps: [
    ps.xml2lua
    ps.mimetypes
  ];
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
