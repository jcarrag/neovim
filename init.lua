--
-- Options
--

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.autowriteall = true
vim.api.nvim_create_autocmd({ "FocusLost" }, {
	callback = function()
		vim.api.nvim_cmd({ cmd = "wa", mods = { emsg_silent = true } }, { output = true })
	end,
})

vim.opt.termguicolors = true
vim.opt.background = "dark"

-- qol settings
local HOME = os.getenv("HOME")
vim.opt.backupdir = HOME .. "/.config/nvim/tmp/backup_files/"
vim.opt.directory = HOME .. "/.config/nvim/tmp/swap_files/"
vim.opt.undodir = HOME .. "/.config/nvim/tmp/undo_files/"
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.scrolloff = 1
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
-- enable mouse highlighting with Mouse Reporting
vim.opt.mouse = "a"
-- always show the signcolumn, otherwise it would shift the text each time diagnostics (dis)appear
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- stop vim from creating automatic backups
vim.opt.swapfile = false
vim.opt.backupcopy = "yes"
-- TODO: can you set wrap=true for only the current line?
vim.opt.colorcolumn = "80"

vim.cmd([[
set completeopt=menu,menuone,noselect
]])

-- highlight on yank (https://stackoverflow.com/a/73365602)
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", {}),
	desc = "Hightlight selection on yank",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- lsp diagnostics
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
vim.diagnostic.config({ virtual_text = true, update_in_insert = false })
-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
vim.o.updatetime = 500
vim.cmd([[autocmd! CursorHold * lua vim.diagnostic.open_float(nil, {focus=false})]])

--
-- Plugins
--

-- lualine
require("lualine").setup({})

-- material-nvim
vim.g.material_style = "deep ocean"
require("material").setup()
vim.cmd("colorscheme material")

-- auto-session
require("auto-session").setup({
	suppressed_dirs = { "~/", "~/tmp", "~/Downloads", "/" },
})

-- treesitter
require("nvim-treesitter.configs").setup({
	sync_install = false,
	auto_install = false,
	ignore_install = { "all" },
	ensure_installed = {},
	modules = {},
	highlight = { enable = true, additional_vim_regex_highlighting = false },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn", -- set to `false` to disable one of the mappings
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
	textobjects = {
		select = {
			enable = true,
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = "@class.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
		swap = {
			enable = true,
			-- swap_next = {
			--   ['<leader>a'] = '@parameter.inner',
			-- },
			-- swap_previous = {
			--   ['<leader>A'] = '@parameter.inner',
			-- },
		},
	},
	indent = { enable = false },
})

-- telescope
require("telescope").setup()
require("telescope").load_extension("projects")

-- fzf-lua
require("fzf-lua").setup({
	defaults = {
		winopts = {
			preview = {
				hidden = "hidden",
			},
		},
	},
	keymap = {
		builtin = {
			["?"] = "toggle-preview",
		},
		fzf = {
			["?"] = "toggle-preview",
		},
	},
})
require("fzf-lua").register_ui_select()

-- project-nvim
require("project_nvim").setup({
	detection_methods = { "pattern" },
	patterns = {
		".git",
		"Cargo.toml",
	},
})

-- typescript-tools-nvim
require("typescript-tools").setup({
	settings = {
		publish_diagnostic_on = "change",
		expose_as_code_action = "all",
		-- contrary to the docs, this must be a number or it isn't acknowledged
		-- https://github.com/pmizio/typescript-tools.nvim/pull/67/files#diff-a51f0845ed52f1844d37953402f96d8e402fe3c480d06d94df209c6d78c3d8e3R129
		tsserver_max_memory = 32768,
	},
	on_attach = function(client)
		-- using prettier to format
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
})

-- lspkind-nvim
local lspkind = require("lspkind")

-- nvim-cmp
local cmp = require("cmp")
cmp.setup({
	mapping = {
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-y>"] = cmp.mapping.scroll_docs(-4),
		["<C-e>"] = cmp.mapping.scroll_docs(4),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	},

	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "nvim_lua" },
		{ name = "buffer" },
		{ name = "path" },
	},

	window = {
		completion = cmp.config.window.bordered(),
	},

	formatting = {
		format = lspkind.cmp_format({
			with_text = true,
			menu = {
				buffer = "[buf]",
				nvim_lsp = "[LSP]",
				nvim_lua = "[API]",
				path = "[path]",
				luasnip = "[snip]",
			},
		}),
	},

	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},

	experimental = { native_menu = false, ghost_text = true },
})

-- nvim-web-devicons
require("nvim-web-devicons").setup()

-- nvim-autopairs
require("nvim-autopairs").setup()

-- repo-link
require("repolink").setup()

-- neotree
require("neo-tree").setup({
	filesystem = {
		window = {
			mappings = {
				["u"] = "navigate_up",
				["O"] = "expand_all_nodes",
			},
		},
		filtered_items = {
			visible = true,
			show_hidden_count = true,
			hide_dotfiles = false,
			hide_gitignored = false,
		},
		follow_current_file = {
			enabled = true,
			leave_dirs_open = false,
		},
	},
	buffers = { follow_current_file = { enable = true } },
})
-- auto close https://github.com/gomfol12/dotfiles/blob/47efefe2bfe3f800b0f94b5036e83a79e85fac4c/.config/nvim/lua/tree.lua#L103C3-L124
local function non_floating_wins_count()
	local i = 0
	for _, v in pairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(v).relative == "" then
			i = i + 1
		end
	end
	return i
end
vim.api.nvim_create_autocmd("BufEnter", {
	nested = true,
	callback = function()
		if non_floating_wins_count() == 1 and vim.api.nvim_buf_get_name(0):match("neo-tree") ~= nil then
			vim.cmd("quit")
		end
	end,
})

-- fidget-nvim
require("fidget").setup()

-- trouble-nvim
require("trouble").setup()

-- comment-nvim
require("Comment").setup()

-- gitsigns-nvim
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		map("n", "]g", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end)

		map("n", "[g", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end)
	end,
})

-- nvim-dapui
require("dapui").setup({
	icons = { expanded = "", collapsed = "", current_frame = "" },
	force_buffers = true,
	mappings = {
		-- Use a table to apply multiple mappings
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
		toggle = "t",
	},
	-- Use this to override mappings for specific elements
	element_mappings = {
		-- Example:
		-- stacks = {
		--   open = "<CR>",
		--   expand = "o",
		-- }
	},
	-- Expand lines larger than the window
	-- Requires >= 0.7
	expand_lines = vim.fn.has("nvim-0.7") == 1,
	-- Layouts define sections of the screen to place windows.
	-- The position can be "left", "right", "top" or "bottom".
	-- The size specifies the height/width depending on position. It can be an Int
	-- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
	-- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
	-- Elements are the elements shown in the layout (in order).
	-- Layouts are opened in order so that earlier layouts take priority in window sizing.
	layouts = {
		{
			elements = {
				-- Elements can be strings or table with id and size keys.
				{ id = "scopes", size = 0.25 },
				"breakpoints",
				"stacks",
				"watches",
			},
			size = 40, -- 40 columns
			position = "left",
		},
		{
			elements = { "repl", "console" },
			size = 0.25, -- 25% of total lines
			position = "bottom",
		},
	},
	controls = {
		-- Requires Neovim nightly (or 0.8 when released)
		enabled = true,
		-- Display controls in this element
		element = "repl",
		icons = {
			pause = "",
			play = "",
			step_into = "",
			step_over = "",
			step_out = "",
			step_back = "",
			run_last = "",
			terminate = "",
		},
	},
	floating = {
		max_height = nil, -- These can be integers or a float between 0 and 1.
		max_width = nil, -- Floats will be treated as percentage of your screen.
		border = "single", -- Border style. Can be "single", "double" or "rounded"
		mappings = { close = { "q", "<Esc>" } },
	},
	windows = { indent = 1 },
	render = {
		indent = 2,
		-- max_type_length = nil, -- Can be integer or nil.
		-- max_value_lines = 100, -- Can be integer or nil.
	},
})

-- nvim-dap-python
require("dap-python").setup()

-- conform-nvim
require("conform").setup({
	formatters_by_ft = {
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		lua = { "stylua" },
	},
})

--
-- lspconfig
--

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- https://github.com/neovim/nvim-lspconfig/blob/bb3fb99cf14daa33014331ac6eb4b5de9180f775/lsp/lua_ls.lua
lspconfig.lua_ls.setup({
	capabilities = capabilities,
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using
				-- (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					--[[@vimPluginsPaths@]]
					-- Depending on the usage, you might want to add additional paths here.
					"${3rd}/luv/library",
					-- "${3rd}/busted/library",
				},
				-- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
				-- library = vim.api.nvim_get_runtime_file("", true)
			},
		})
	end,
	on_attach = function(client, bufnr)
		-- use stylua
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	settings = {
		Lua = {},
	},
})
lspconfig.lua_ls.setup({ capabilities = capabilities })
lspconfig.cmake.setup({ capabilities = capabilities })
lspconfig.nixd.setup({ capabilities = capabilities })
lspconfig.nixd.setup({
	capabilities = capabilities,
	settings = { nixd = { formatting = { command = { "nixfmt" } } } },
})
lspconfig.dockerls.setup({ capabilities = capabilities })
lspconfig.jsonls.setup({ capabilities = capabilities })
lspconfig.gopls.setup({ capabilities = capabilities })
lspconfig.pyright.setup({ capabilities = capabilities })
lspconfig.vimls.setup({ capabilities = capabilities })
lspconfig.clangd.setup({ capabilities = capabilities })

--
-- Mappings
--

-- diagnostics
vim.api.nvim_set_keymap("n", "<leader>ra", "<cmd>lua vim.diagnostic.reset()<cr>", { noremap = true })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>a", vim.diagnostic.setloclist)
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Go to next diagnostic" })

-- trouble
vim.api.nvim_set_keymap("n", "<leader>a", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>A", "<cmd>Trouble diagnostics toggle<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tq", "<cmd>Trouble quickfix toggle<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "gr", "<cmd>Trouble lsp_references toggle<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "gd", "<cmd>Trouble lsp_definitions toggle<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "gy", "<cmd>Trouble lsp_type_definitions toggle<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "gi", "<cmd>Trouble lsp_implementations toggle<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { noremap = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>fd",
	"<cmd>lua require('telescope.builtin').diagnostics()<cr>",
	{ noremap = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>fi",
	"<cmd>lua require('telescope.builtin').lsp_implementations()<cr>",
	{ noremap = true }
)
vim.api.nvim_set_keymap("n", "<leader>fw", "<cmd>Telescope telescope-cargo-workspace switch<cr>", { noremap = true })

-- fzf
vim.api.nvim_set_keymap("n", "<C-g>", "<cmd>lua require('fzf-lua').git_files()<cr>", { noremap = true })
-- a couple of necessary extra params here:
-- 1. disable adding icons since it makes fzf 10x slower (https://github.com/ibhagwan/fzf-lua/issues/1005#issuecomment-1894367825)
-- 2. include filename in fzf's fuzzy search
-- 3. set fzf's cwd to be git_root if available, otherwise neovim's cwd - this replaces using project_root which breaks when it
--    changes neovim's root to be something other than git root (e.g. Cargo.toml directory)
vim.keymap.set("n", "<leader><C-g>", function()
	vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }, function(obj)
		local search_path = nil

		if obj.code == 0 then
			search_path = obj.stdout:gsub("\n", "")
		else
			search_path = vim.schedule(function()
				vim.fn.getcwd()
			end)
		end

		-- use vim.schedule to prevent:
		-- > Vimscript function must not be called in a fast event context
		vim.schedule(function()
			require("fzf-lua").grep({
				search = "", -- imitate project_grep
				cwd = search_path,
				file_icons = false,
				git_icons = false,
				fzf_opts = { ["--nth"] = "1.." },
				rg_opts = ([[
					  --hidden
					  --column
					  --line-number
					  --no-heading
					  --color=always
					  --smart-case
					  --max-columns=4096
					  --no-messages
					  --glob "!.git"
					  --regexp
					]]):gsub("\n", " "),
			})
		end)
	end)
end, { noremap = true })
vim.api.nvim_set_keymap("n", "<leader><C-w>", "<cmd>lua require('fzf-lua').buffers()<cr>", { noremap = true })

-- dap
vim.api.nvim_set_keymap("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>dc", "<cmd>lua require('dap').continue()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>so", "<cmd>lua require('dap').step_over()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>si", "<cmd>lua require('dap').step_into()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>du", "<cmd>lua require('dapui').toggle()<cr>", { noremap = true })

-- quickfix
vim.api.nvim_set_keymap("n", "<leader>qn", "<cmd>:cn<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>qp", "<cmd>:cp<CR>", { noremap = true })

-- neotree
vim.api.nvim_set_keymap("n", "<leader><C-f>", "<cmd>Neotree reveal<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader><C-b>", "<cmd>Neotree toggle<CR>", { noremap = true })

-- windows
vim.api.nvim_set_keymap("n", "<M-j>", "<C-W>+", { noremap = true })
vim.api.nvim_set_keymap("n", "<M-k>", "<C-W>-", { noremap = true })
vim.api.nvim_set_keymap("n", "<M-l>", "<C-W>>", { noremap = true })
vim.api.nvim_set_keymap("n", "<M-h>", "<C-W><", { noremap = true })

vim.api.nvim_set_keymap("n", "<C-j>", "<C-W>j", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-W>k", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-W>l", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-h>", "<C-W>h", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-p>", "<C-W>p", { noremap = true })

-- misc
vim.api.nvim_set_keymap("n", "J", "<cmd>lua JoinSpaceless()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>o", "<cmd>lua OnlyAndNeotree()<cr>", { noremap = true })
-- copy current filename + position
vim.api.nvim_set_keymap("n", "yL", "<cmd>let @+=join([expand('%:p'),  line('.')], ':')<cr>", { noremap = true })

-- LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- inlay hints
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client ~= nil and client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(true)
		end

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		-- defined by Trouble
		-- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		-- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		-- vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
		-- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<leader>o", vim.lsp.buf.document_symbol, opts)
		vim.keymap.set("n", "<leader>s", vim.lsp.buf.workspace_symbol, opts)
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.api.nvim_set_keymap(
			"n",
			"<leader>cl",
			"<cmd>lua require('fzf-lua').lsp_code_actions()<cr>",
			{ noremap = true }
		)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "<leader>p", function()
			if client ~= nil and client.server_capabilities.documentFormattingProvider then
				vim.lsp.buf.format({ async = true })
			else
				require("conform").format()
			end
		end, opts)
	end,
})

--
-- Utils
--

-- join spaceless
function JoinSpaceless()
	vim.api.nvim_exec2("normal gJ<cr>", {})
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local char = vim.api.nvim_get_current_line():sub(col + 1, col + 1)
	if char:match("%s") ~= nil then
		vim.api.nvim_exec2("normal dw<cr>", {})
	end
end

-- only close other windows other than this one and NERDTree
function OnlyAndNeotree()
	local currentWindowId = vim.api.nvim_get_current_win()
	for _, windowId in pairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(windowId)
		if windowId ~= currentWindowId and vim.api.nvim_get_option_value("filetype", { buf = buf }) ~= "neo-tree" then
			vim.api.nvim_win_call(windowId, function()
				vim.cmd("silent! close")
			end)
		end
	end
end
