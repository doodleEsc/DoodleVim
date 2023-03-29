local config = {}
local vim_path = require('doodleVim.core.global').vim_path

function config.lspconfig(plugin, opts)
    local handler = require("doodleVim.modules.lsp.handler")
    handler.lsp_hover()
    handler.lsp_diagnostic()
    handler.null_ls_depress()

    local servers = opts.servers or {}
    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.offsetEncoding = { "utf-16" }
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
    }

    local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
            capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if server_opts.disabled then
            return
        end

        if opts.setup then
            if opts.setup[server] then
                if opts.setup[server](server, server_opts) then
                    return
                end
            elseif opts.setup["*"] then
                if opts.setup["*"](server, server_opts) then
                    return
                end
            end
        end

        require("lspconfig")[server].setup(server_opts)
    end

    local mlsp = require("mason-lspconfig")
    local available = mlsp.get_available_servers()
    local ensure_installed = {} ---@type string[]
    for server, server_opts in pairs(servers) do
        if server_opts then
            server_opts = server_opts == true and {} or server_opts
            -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
            if server_opts.mason == false or not vim.tbl_contains(available, server) then
                setup(server)
            else
                ensure_installed[#ensure_installed + 1] = server
            end
        end
    end
    require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
    require("mason-lspconfig").setup_handlers({ setup })
end

function config.mason()
    require("mason").setup({
        ui = {
            check_outdated_packages_on_open = true,
            -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
            border = "rounded",
            icons = {
                -- The list icon to use for installed packages.
                package_installed = "◍",
                -- The list icon to use for packages that are installing, or queued for installation.
                package_pending = "◍",
                -- The list icon to use for packages that are not installed.
                package_uninstalled = "◍",
            },
            keymaps = {
                -- Keymap to expand a package
                toggle_package_expand = "<CR>",
                -- Keymap to install the package under the current cursor position
                install_package = "i",
                -- Keymap to reinstall/update the package under the current cursor position
                update_package = "u",
                -- Keymap to check for new version for the package under the current cursor position
                check_package_version = "c",
                -- Keymap to update all installed packages
                update_all_packages = "U",
                -- Keymap to check which installed packages are outdated
                check_outdated_packages = "C",
                -- Keymap to uninstall a package
                uninstall_package = "X",
                -- Keymap to cancel a package installation
                cancel_installation = "<C-c>",
                -- Keymap to apply language filter
                apply_language_filter = "<C-f>",
            },
        },
        -- The directory in which to install packages.
        install_root_dir = require("mason-core.path").concat({ vim.fn.stdpath("data"), "mason" }),
        PATH = "prepend",
        pip = {
            -- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
            -- and is not recommended.
            --
            -- Example: { "--proxy", "https://proxyserver" }
            install_args = {},
        },
        -- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
        -- debugging issues with package installations.
        log_level = vim.log.levels.INFO,
        -- Limit for the maximum amount of packages to be installed at the same time. Once this limit is reached, any further
        -- packages that are requested to be installed will be put in a queue.
        max_concurrent_installers = 4,
        github = {
            -- The template URL to use when downloading assets from GitHub.
            -- The placeholders are the following (in order):
            -- 1. The repository (e.g. "rust-lang/rust-analyzer")
            -- 2. The release version (e.g. "v0.3.0")
            -- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
            download_url_template = "https://github.com/%s/releases/download/%s/%s",
        },
        providers = {
            "mason.providers.registry-api",
        },
    })
end

function config.nlsp_settings()
    require("nlspsettings").setup({
        config_home = vim_path .. "/nlsp-settings",
        local_settings_dir = ".nlsp-settings",
        local_settings_root_markers = { ".git" },
        append_default_schemas = true,
        loader = "json",
    })
end

function config.gotools()
    require("gotools").setup({
        gotests = {
            bin = require "mason-core.path".bin_prefix() .. "/" .. "gotests",
            win_opts = {
                prompt = 'Select An Action',
                kind = 'gotools'
            },
        },
        gomodifytags = {
            bin = require "mason-core.path".bin_prefix() .. "/" .. "gomodifytags",
            skip_unexported = true,
            win_opts = {
                prompt = 'Tags:',
            },
        },
        impl = {
            bin = require "mason-core.path".bin_prefix() .. "/" .. "impl",
            win_opts = {
                prompt = 'Select An Action',
                kind = 'gotools'
            },
        }
    })

    require("dressing.select.telescope").custom_kind["gotools"] = function(opts, defaults, items)
        local finders = require("telescope.finders")
        local make_indexed = function(items)
            local indexed_items = {}
            local widths = {
                idx = 0,
                command_title = 0,
            }
            for idx, item in ipairs(items) do
                local entry = {
                    idx = idx,
                    command_title = item,
                    text = item,
                }
                table.insert(indexed_items, entry)
                widths.idx = math.max(widths.idx, require "plenary.strings".strdisplaywidth(entry.idx))
                widths.command_title = math.max(widths.command_title,
                    require "plenary.strings".strdisplaywidth(entry.command_title))
            end
            return indexed_items, widths
        end

        local make_displayer = function(widths)
            return require "telescope.pickers.entry_display".create {
                separator = " ",
                items = {
                    { width = widths.idx + 1 }, -- +1 for ":" suffix
                    { width = widths.command_title },
                },
            }
        end
        local make_display_factory = function(displayer)
            return function(e)
                return displayer {
                    { e.value.idx .. ":",   "TelescopePromptPrefix" },
                    { e.value.command_title },
                }
            end
        end

        local make_ordinal = function(e)
            return e.idx .. e.command_title
        end

        local indexed_items, widths = make_indexed(items)
        local displayer = make_displayer(widths)
        local make_display = make_display_factory(displayer)

        defaults.finder = finders.new_table {
            results = indexed_items,
            entry_maker = function(e)
                return {
                    value = e,
                    display = make_display,
                    ordinal = make_ordinal(e),
                }
            end,
        }

        defaults.initial_mode = "normal"
    end
end

function config.null_ls()
    local null_ls = require("null-ls")

    null_ls.setup({
        cmd = { "nvim" },
        debounce = 250,
        debug = false,
        default_timeout = 5000,
        diagnostics_format = "#{m}",
        fallback_severity = vim.diagnostic.severity.ERROR,
        log = {
            enable = true,
            level = "warn",
            use_console = "async",
        },
        on_attach = nil,
        -- on_init = function(new_client, _)
        --     print(vim.inspect(new_client))
        --     new_client.offset_encoding = 'utf-32'
        -- end,
        on_exit = nil,
        sources = {
            require("gotools").code_actions.gotests,
            require("gotools").code_actions.gomodifytags,
            require("gotools").code_actions.impl,
            null_ls.builtins.code_actions.gitsigns,
            null_ls.builtins.diagnostics.solhint,
            null_ls.builtins.formatting.xmlformat.with({
                extra_args = { "--indent", "4" }
            }),
        },
        update_in_insert = false,
    })
end

function config.lightbulb()
    local codicons = require("codicons")

    vim.fn.sign_define("LightBulbSign", { text = codicons.get("lightbulb"), texthl = "GruvboxYellowSign" })

    -- Showing defaults
    require('nvim-lightbulb').setup({
        -- LSP client names to ignore
        -- Example: {"sumneko_lua", "null-ls"}
        ignore = { "null-ls" },
        sign = {
            enabled = true,
            -- Priority of the gutter sign
            priority = 10,
        },
        float = {
            enabled = false,
            -- Text to show in the popup float
            text = "💡",
            -- Available keys for window options:
            -- - height     of floating window
            -- - width      of floating window
            -- - wrap_at    character to wrap at for computing height
            -- - max_width  maximal width of floating window
            -- - max_height maximal height of floating window
            -- - pad_left   number of columns to pad contents at left
            -- - pad_right  number of columns to pad contents at right
            -- - pad_top    number of lines to pad contents at top
            -- - pad_bottom number of lines to pad contents at bottom
            -- - offset_x   x-axis offset of the floating window
            -- - offset_y   y-axis offset of the floating window
            -- - anchor     corner of float to place at the cursor (NW, NE, SW, SE)
            -- - winblend   transparency of the window (0-100)
            win_opts = {},
        },
        virtual_text = {
            enabled = false,
            -- Text to show at virtual text
            text = "💡",
            -- highlight mode to use for virtual text (replace, combine, blend), see :help nvim_buf_set_extmark() for reference
            hl_mode = "replace",
        },
        status_text = {
            enabled = false,
            -- Text to provide when code actions are available
            text = "💡",
            -- Text to provide when no actions are available
            text_unavailable = ""
        },
        autocmd = {
            enabled = true,
            -- see :help autocmd-pattern
            pattern = { "*" },
            -- see :help autocmd-events
            events = { "CursorHold", "CursorHoldI" }
        }
    })
end

function config.fidget(plugin, opts)
    require "fidget".setup({
        text = {
            spinner = "pipe",        -- animation shown when tasks are ongoing
            done = "󰞑 ",          -- character shown when all tasks are complete
            commenced = "Started",   -- message shown when task starts
            completed = "Completed", -- message shown when task completes
        },
        align = {
            bottom = true, -- align fidgets along bottom edge of buffer
            right = true,  -- align fidgets along right edge of buffer
        },
        timer = {
            spinner_rate = 125,  -- frame rate of spinner animation, in ms
            fidget_decay = 2000, -- how long to keep around empty fidget, in ms
            task_decay = 1000,   -- how long to keep around completed task, in ms
        },
        window = {
            relative = "win", -- where to anchor, either "win" or "editor"
            blend = 100,      -- &winblend for the window
            zindex = nil,     -- the zindex value for the window
            border = "none",  -- style of border for the fidget window
        },
        fmt = {
            leftpad = true,       -- right-justify text in fidget box
            stack_upwards = true, -- list of tasks grows upwards
            max_width = 0,        -- maximum width of the fidget box
            fidget =              -- function to format fidget title
                function(fidget_name, spinner)
                    return string.format("%s %s", spinner, fidget_name)
                end,
            task = -- function to format each task line
                function(task_name, message, percentage)
                    return string.format(
                        "%s%s [%s]",
                        message,
                        percentage and string.format(" (%s%%)", percentage) or "",
                        task_name
                    )
                end,
        }
    })
end

function config.barbecue(plugin, opts)
    local codicons = require("codicons")
    require("barbecue").setup({
        ---Whether to attach navic to language servers automatically.
        ---
        ---@type boolean
        attach_navic = true,
        ---Whether to create winbar updater autocmd.
        ---
        ---@type boolean
        create_autocmd = true,
        ---Buftypes to enable winbar in.
        ---
        ---@type string[]
        include_buftypes = { "" },
        ---Filetypes not to enable winbar in.
        ---
        ---@type string[]
        exclude_filetypes = { "gitcommit", "toggleterm", "DressingInput" },
        modifiers = {
            ---Filename modifiers applied to dirname.
            ---
            ---See: `:help filename-modifiers`
            ---
            ---@type string
            dirname = ":~:.",
            ---Filename modifiers applied to basename.
            ---
            ---See: `:help filename-modifiers`
            ---
            ---@type string
            basename = "",
        },
        ---Whether to display path to file.
        ---
        ---@type boolean
        show_dirname = false,
        ---Whether to display file name.
        ---
        ---@type boolean
        show_basename = true,
        ---Whether to replace file icon with the modified symbol when buffer is
        ---modified.
        ---
        ---@type boolean
        show_modified = false,
        ---Get modified status of file.
        ---
        ---NOTE: This can be used to get file modified status from SCM (e.g. git)
        ---
        ---@type fun(bufnr: number): boolean
        modified = function(bufnr) return vim.bo[bufnr].modified end,
        ---Whether to show/use navic in the winbar.
        ---
        ---@type boolean
        show_navic = true,
        ---Get leading custom section contents.
        ---
        ---NOTE: This function shouldn't do any expensive actions as it is run on each
        ---render.
        ---
        ---@type fun(bufnr: number): barbecue.Config.custom_section
        lead_custom_section = function() return " " end,
        ---@alias barbecue.Config.custom_section
        ---|string # Literal string.
        ---|{ [1]: string, [2]: string? }[] # List-like table of `[text, highlight?]` tuples in which `highlight` is optional.
        ---
        ---Get custom section contents.
        ---
        ---NOTE: This function shouldn't do any expensive actions as it is run on each
        ---render.
        ---
        ---@type fun(bufnr: number): barbecue.Config.custom_section
        custom_section = function() return " " end,
        ---@alias barbecue.Config.theme
        ---|'"auto"' # Use your current colorscheme's theme or generate a theme based on it.
        ---|string # Theme located under `barbecue.theme` module.
        ---|barbecue.Theme # Same as '"auto"' but override it with the given table.
        ---
        ---Theme to be used for generating highlight groups dynamically.
        ---
        ---@type barbecue.Config.theme

        --         return {
        --   dark0_hard = "#1d2021",
        --   dark0 = "#282828",
        --   dark0_soft = "#32302f",
        --   dark1 = "#3c3836",
        --   dark2 = "#504945",
        --   dark3 = "#665c54",
        --   dark4 = "#7c6f64",
        --   light0_hard = "#f9f5d7",
        --   light0 = "#fbf1c7",
        --   light0_soft = "#f2e5bc",
        --   light1 = "#ebdbb2",
        --   light2 = "#d5c4a1",
        --   light3 = "#bdae93",
        --   light4 = "#a89984",
        --   bright_red = "#fb4934",
        --   bright_green = "#b8bb26",
        --   bright_yellow = "#fabd2f",
        --   bright_blue = "#83a598",
        --   bright_purple = "#d3869b",
        --   bright_aqua = "#8ec07c",
        --   bright_orange = "#fe8019",
        --   neutral_red = "#cc241d",
        --   neutral_green = "#98971a",
        --   neutral_yellow = "#d79921",
        --   neutral_blue = "#458588",
        --   neutral_purple = "#b16286",
        --   neutral_aqua = "#689d6a",
        --   neutral_orange = "#d65d0e",
        --   faded_red = "#9d0006",
        --   faded_green = "#79740e",
        --   faded_yellow = "#b57614",
        --   faded_blue = "#076678",
        --   faded_purple = "#8f3f71",
        --   faded_aqua = "#427b58",
        --   faded_orange = "#af3a03",
        --   gray = "#928374",
        -- }



        theme = {
            -- this highlight is used to override other highlights
            -- you can take advantage of its `bg` and set a background throughout your winbar
            -- (e.g. basename will look like this: { fg = "#c0caf5", bold = true })
            normal = { fg = "#bdae93", bg = "#32302f" },
            -- these highlights correspond to symbols table from config
            ellipsis = { fg = "#bdae93" },
            separator = { fg = "#737aa2" },
            modified = { fg = "#fb4934" },
            -- these highlights represent the _text_ of three main parts of barbecue
            dirname = { fg = "#83a598" },
            basename = { bold = true },
            context = {},
            -- these highlights are used for context/navic icons
            context_module = { fg = "#fe8019" },
            context_field = { fg = "#d3869b" },
            context_file = { fg = "#83a598" },
            context_boolean = { fg = "#fe8019" },
            context_string = { fg = "#b8bb26" },
            context_operator = { fg = "#fb4934" },
            context_null = { fg = "#fe8019" },
            context_event = { fg = "#fabd2f" },
            context_namespace = { fg = "#83a598" },
            context_class = { fg = "#fabd2f" },
            context_method = { fg = "#83a598" },
            context_property = { fg = "#8ec07c" },
            context_constructor = { fg = "#83a598" },
            context_enum = { fg = "#d3869b" },
            context_interface = { fg = "#b8bb26" },
            context_package = { fg = "#8ec07c" },
            context_constant = { fg = "#fe8019" },
            context_object = { fg = "#fe8019" },
            context_key = { fg = "#8ec07c" },
            context_enum_member = { fg = "#fabd2f" },
            context_struct = { fg = "#d3869b" },
            context_array = { fg = "#fe8019" },
            context_type_parameter = { fg = "#fb4934" },
            context_function = { fg = "#83a598" },
            context_variable = { fg = "#d3869b" },
            context_number = { fg = "#fe8019" },
        },
        ---Whether context text should follow its icon's color.
        ---
        ---@type boolean
        context_follow_icon_color = false,
        symbols = {
            ---Modification indicator.
            ---
            ---@type string
            modified = "●",
            ---Truncation indicator.
            ---
            ---@type string
            ellipsis = "…",
            ---Entry separator.
            ---
            ---@type string
            separator = "",
        },
        ---@alias barbecue.Config.kinds
        ---|false # Disable kind icons.
        ---|table<string, string> # Type to icon mapping.
        ---
        ---Icons for different context entry kinds.
        ---
        ---@type barbecue.Config.kinds
        kinds = {
            File          = codicons.get("symbol-file"),
            Module        = codicons.get("symbol-module"),
            Namespace     = codicons.get("symbol-namespace"),
            Package       = codicons.get("symbol-package"),
            Class         = codicons.get("symbol-class"),
            Method        = codicons.get("symbol-method"),
            Property      = codicons.get("symbol-property"),
            Field         = codicons.get("symbol-field"),
            Constructor   = codicons.get("symbol-constructor"),
            Enum          = codicons.get("symbol-enum"),
            Interface     = codicons.get("symbol-interface"),
            Function      = codicons.get("symbol-function"),
            Variable      = codicons.get("symbol-variable"),
            Constant      = codicons.get("symbol-constant"),
            String        = codicons.get("symbol-string"),
            Number        = codicons.get("symbol-number"),
            Boolean       = codicons.get("symbol-boolean"),
            Array         = codicons.get("symbol-array"),
            Object        = codicons.get("symbol-object"),
            Key           = codicons.get("symbol-key"),
            Null          = codicons.get("symbol-null"),
            EnumMember    = codicons.get("symbol-enum-member"),
            Struct        = codicons.get("symbol-struct"),
            Event         = codicons.get("symbol-event"),
            Operator      = codicons.get("symbol-operator"),
            TypeParameter = codicons.get("symbol-type-parameter"),
            Component     = codicons.get("symbol-misc"),
            Fragment      = codicons.get("symbol-misc"),
        },
    })
end

function config.jdtls(plugin, opts)
    local trim = require("doodleVim.utils.utils").trim

    -- get current system
    local os_name = vim.loop.os_uname().sysname
    local system = os_name == "Linux" and "linux" or os_name == "Windows" and "win" or "mac"

    -- get jdtls and config jar path
    local jdtls_home = require("mason-core.path").package_prefix("jdtls")
    local jdtls_jar_path = trim(vim.fn.system({
        "find", jdtls_home .. "/plugins", "-name", "org.eclipse.equinox.launcher_*.jar"
    }))
    local config_path = jdtls_home .. "/config_" .. system

    -- get bundles
    local java_debug_home = require("mason-core.path").package_prefix("java-debug-adapter")
    local java_test_home = require("mason-core.path").package_prefix("java-test")
    local java_debug_jar_path = trim(vim.fn.system({
        "find", java_debug_home .. "/extension/server", "-name", "com.microsoft.java.debug.plugin-*.jar"
    }))
    local bundles = {
        vim.fn.glob(java_debug_jar_path, 1),
    }
    vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_home .. "/extension/server/*.jar", 1), "\n"))

    -- get project workspace
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace = vim.env.HOME .. "/.cache/jdtls/workspace/" .. project_name

    -- get lombok path
    local lombok_jar = jdtls_home .. "/plugins/" .. "lombok.jar"
    local javaagent = "-javaagent:" .. lombok_jar
    local Xbootclasspath = "-Xbootclasspath/a:" .. lombok_jar

    local conf = {
        cmd = {
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-Xms1g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
            javaagent,
            Xbootclasspath,
            '-jar', jdtls_jar_path,
            '-configuration', config_path,
            '-data', workspace
        },
        root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
        init_options = {
            bundles = bundles,
        },
        on_attach = function(client, bufnr)
            require'jdtls.setup'.add_commands()
            require('jdtls').setup_dap({
                hotcodereplace = 'auto',
            })
            require('jdtls.dap').setup_dap_main_class_configs({
                on_ready = function()
                    local dap = require("dap")
                    for _, java_config in pairs(dap.configurations.java) do
                        java_config.console = 'internalConsole'
                    end
                end
            })
        end
    }
    require('jdtls').start_or_attach(conf)
end

return config
