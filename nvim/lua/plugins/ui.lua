return {
    -- messages, cmdline and the popupmenu
    {
        "folke/noice.nvim",
        opts = function(_, opts)
            table.insert(opts.routes, {
                filter = {
                    event = "notify",
                    find = "No information available",
                },
                opts = { skip = true },
            })
            local focused = true
            vim.api.nvim_create_autocmd("FocusGained", {
                callback = function()
                    focused = true
                end,
            })
            vim.api.nvim_create_autocmd("FocusLost", {
                callback = function()
                    focused = false
                end,
            })
            table.insert(opts.routes, 1, {
                filter = {
                    cond = function()
                        return not focused
                    end,
                },
                view = "notify_send",
                opts = { stop = false },
            })

            opts.commands = {
                all = {
                    -- options for the message history that you get with `:Noice`
                    view = "split",
                    opts = { enter = true, format = "details" },
                    filter = {},
                },
            }

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function(event)
                    vim.schedule(function()
                        require("noice.text.markdown").keys(event.buf)
                    end)
                end,
            })

            opts.presets = opts.presets or {}
            opts.presets.lsp_doc_border = true
        end,
    },

    {
        "rcarriga/nvim-notify",
        opts = {
            timeout = 5000,
        },
    },

    -- animations
    {
        "nvim-mini/mini.animate",
        event = "VeryLazy",
        opts = function(_, opts)
            opts.scroll = {
                enable = false,
            }
        end,
    },

    -- buffer line
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        keys = {
            { "<Tab>",   "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
            { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
        },
        opts = {
            options = {
                mode = "tabs",
                -- separator_style = "slant",
                show_buffer_close_icons = false,
                show_close_icon = false,
            },
        },
    },

    -- filename
    {
        "b0o/incline.nvim",
        dependencies = { "craftzdog/solarized-osaka.nvim" },
        event = "BufReadPre",
        priority = 1200,
        config = function()
            local colors = require("solarized-osaka.colors").setup()
            require("incline").setup({
                highlight = {
                    groups = {
                        InclineNormal = { guibg = colors.magenta500, guifg = colors.base04 },
                        InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
                    },
                },
                window = { margin = { vertical = 0, horizontal = 1 } },
                hide = {
                    cursorline = true,
                },
                render = function(props)
                    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                    if vim.bo[props.buf].modified then
                        filename = "[+] " .. filename
                    end

                    local icon, color = require("nvim-web-devicons").get_icon_color(filename)
                    return { { icon, guifg = color }, { " " }, { filename } }
                end,
            })
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        opts = function(_, opts)
            opts.routes = opts.routes or {}
            -- Paleta de colores mejorada
            local colors = {
                blue = "#2196f3",
                cyan = "#77CBD0",
                black = "#080808",
                white = "#c6c6c6",
                red = "#e5383b",
                violet = "#2ec4b6",
                grey = "#161a1d",
                whitefull = "#ffffff",
                yellow = "#ffd60a",
                green = "#52b788",
                orange = "#f77f00",
            }

            -- Tema burbuja
            local bubbles_theme = {
                normal = {
                    a = { fg = colors.black, bg = colors.violet, gui = "bold" },
                    b = { fg = colors.white, bg = colors.grey },
                    c = { fg = colors.white, bg = colors.black },
                },
                insert = { a = { fg = colors.black, bg = colors.blue, gui = "bold" } },
                visual = { a = { fg = colors.black, bg = colors.cyan, gui = "bold" } },
                replace = { a = { fg = colors.black, bg = colors.red, gui = "bold" } },
                command = { a = { fg = colors.black, bg = colors.yellow, gui = "bold" } },
                inactive = {
                    a = { fg = colors.white, bg = colors.black },
                    b = { fg = colors.white, bg = colors.black },
                    c = { fg = colors.white, bg = colors.black },
                },
            }

            -- Función para mostrar búsqueda activa
            local function search_result()
                if vim.v.hlsearch == 0 then
                    return ""
                end
                local last_search = vim.fn.getreg("/")
                if not last_search or last_search == "" then
                    return ""
                end
                local searchcount = vim.fn.searchcount({ maxcount = 9999 })
                return " " .. last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
            end

            -- Modificado/readonly
            local function modified()
                if vim.bo.modified then
                    return "●"
                elseif vim.bo.modifiable == false or vim.bo.readonly == true then
                    return ""
                end
                return ""
            end

            -- Nombre de LSP activo
            local function lsp_client()
                local clients = vim.lsp.get_active_clients({ bufnr = 0 })
                if #clients == 0 then
                    return ""
                end
                local names = {}
                for _, client in ipairs(clients) do
                    table.insert(names, client.name)
                end
                return " " .. table.concat(names, ", ")
            end

            -- Espacios de indentación
            local function spaces()
                return "->" .. vim.api.nvim_buf_get_option(0, "shiftwidth")
            end

            -- Hora actual
            local function clock()
                return " " .. os.date("%H:%M")
            end

            opts.options = {
                theme = bubbles_theme,
                component_separators = "",
                section_separators = { left = "", right = "" },
                globalstatus = true,
                disabled_filetypes = { "NvimTree", "dashboard", "alpha" },
            }
            opts.sections = {
                lualine_a = {
                    { "mode", separator = { left = "" }, right_padding = 2 },
                },
                lualine_b = {
                    { "branch", icon = "", color = { bg = colors.whitefull, fg = colors.black } },
                    { "diff", colored = true, symbols = { added = " ", modified = " ", removed = " " } },
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        sections = { "error", "warn", "info", "hint" },
                        symbols = { error = " ", warn = " ", info = " ", hint = " " },
                        diagnostics_color = {
                            error = { fg = colors.red },
                            warn = { fg = colors.yellow },
                            info = { fg = colors.cyan },
                            hint = { fg = colors.green },
                        },
                    },
                    { "filename", file_status = true,                            path = 1 },
                    { modified,   color = { bg = colors.red, fg = colors.white } },
                },
                lualine_c = {
                    "%=", -- Centrado
                },
                lualine_x = {
                    { lsp_client,    color = { fg = colors.cyan } },
                    { spaces,        color = { fg = colors.orange } },
                    { search_result, color = { fg = colors.yellow } },
                },
                lualine_y = {
                    { "filetype", icon_only = false,            colored = true },
                    { clock,      color = { fg = colors.green } },
                },
                lualine_z = {
                    { "progress", separator = { left = "" }, left_padding = 2 },
                    { "location", separator = { right = "" }, left_padding = 1 },
                },
            }
            opts.inactive_sections = {
                lualine_a = { "filename" },
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = { "location" },
            }
            opts.tabline = {}
            opts.extensions = {}
        end,
    },
    -- statusline
    -- {
    -- 	"nvim-lualine/lualine.nvim",
    -- 	opts = function(_, opts)
    -- 		-- Bubbles config for lualine
    -- 		-- Author: lokesh-krishna
    -- 		-- MIT license, see LICENSE for more details.
    --
    -- 		-- stylua: ignore
    -- 		local colors = {
    -- 			blue   = '#80a0ff',
    -- 			cyan   = '#79dac8',
    -- 			black  = '#080808',
    -- 			white  = '#c6c6c6',
    -- 			red    = '#ff5189',
    -- 			violet = '#d183e8',
    -- 			grey   = '#303030',
    --        whitefull = 'ffffff'
    -- 		}
    --
    -- 		local bubbles_theme = {
    -- 			normal = {
    -- 				a = { fg = colors.black, bg = colors.violet },
    -- 				b = { fg = colors.white, bg = colors.grey },
    -- 				c = { fg = colors.white },
    -- 			},
    --
    -- 			insert = { a = { fg = colors.black, bg = colors.blue } },
    -- 			visual = { a = { fg = colors.black, bg = colors.cyan } },
    -- 			replace = { a = { fg = colors.black, bg = colors.red } },
    --
    -- 			inactive = {
    -- 				a = { fg = colors.white, bg = colors.black },
    -- 				b = { fg = colors.white, bg = colors.black },
    -- 				c = { fg = colors.white },
    -- 			},
    -- 		}
    --
    -- 		local function search_result()
    -- 			if vim.v.hlsearch == 0 then
    -- 				return ""
    -- 			end
    -- 			local last_search = vim.fn.getreg("/")
    -- 			if not last_search or last_search == "" then
    -- 				return ""
    -- 			end
    -- 			local searchcount = vim.fn.searchcount({ maxcount = 9999 })
    -- 			return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
    -- 		end
    --
    -- 		local function modified()
    -- 			if vim.bo.modified then
    -- 				return "+"
    -- 			elseif vim.bo.modifiable == false or vim.bo.readonly == true then
    -- 				return "-"
    -- 			end
    -- 			return ""
    -- 		end
    --
    -- 		opts.options = {
    -- 			theme = bubbles_theme,
    -- 			component_separators = "",
    -- 			section_separators = { left = "", right = "" },
    -- 		}
    -- 		opts.sections = {
    -- 			lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
    -- 			lualine_b = {
    -- 				{ "branch", color = { bg = colors.cyan, fg = colors.black } },
    -- 				"diff",
    -- 				{
    -- 					"diagnostics",
    -- 					source = { "nvim" },
    -- 					sections = { "error", "warn" },
    -- 					diagnostics_color = {
    -- 						error = { bg = colors.red, fg = colors.white },
    -- 					},
    -- 				},
    -- 				{ "filename", file_status = false, path = 1 },
    -- 				{ modified, color = { bg = colors.red, fg = colors.white } },
    -- 			},
    -- 			lualine_c = {
    -- 				"%=", -- Center component
    -- 			},
    -- 			lualine_x = {},
    -- 			lualine_y = { search_result, "filetype" },
    -- 			lualine_z = {
    -- 				{ "location", separator = { right = "" }, left_padding = 2 },
    -- 			},
    -- 		}
    -- 		opts.inactive_sections = {
    -- 			lualine_a = { "filename" },
    -- 			lualine_b = {},
    -- 			lualine_c = {},
    -- 			lualine_x = {},
    -- 			lualine_y = {},
    -- 			lualine_z = { "location" },
    -- 		}
    -- 		opts.tabline = {}
    -- 		opts.extensions = {}
    -- 	end,
    -- },

    {
        "folke/zen-mode.nvim",
        cmd = "ZenMode",
        opts = {
            plugins = {
                gitsigns = true,
                tmux = true,
                kitty = { enabled = false, font = "+2" },
            },
        },
        keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
    },

    {
        "folke/snacks.nvim",
        opts = {
            dashboard = {
                preset = {
                    header = [[
     (⌐■_■)       (⌐■_■)         (⌐■_■)             (⌐■_■)        (⌐■_■)

     ███╗   ██╗ ██████╗ ████████╗███╗   ███╗██╗███╗   ██╗██╗███╗   ███╗ █████╗ ██╗
     ████╗  ██║██╔═══██╗╚══██╔══╝████╗ ████║██║████╗  ██║██║████╗ ████║██╔══██╗██║
     ██╔██╗ ██║██║   ██║   ██║   ██╔████╔██║██║██╔██╗ ██║██║██╔████╔██║███████║██║
     ██║╚██╗██║██║   ██║   ██║   ██║╚██╔╝██║██║██║╚██╗██║██║██║╚██╔╝██║██╔══██║██║
     ██║ ╚████║╚██████╔╝   ██║   ██║ ╚═╝ ██║██║██║ ╚████║██║██║ ╚═╝ ██║██║  ██║███████╗
     ╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝
                (⌐■_■)                        (⌐■_■)             (⌐■_■)


  ]],
                },
            },
        },
    },
}
