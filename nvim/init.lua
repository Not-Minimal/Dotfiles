vim.opt.shell = "/bin/zsh"
if vim.loader then
    vim.loader.enable()
end

_G.dd = function(...)
    require("util.debug").dump(...)
end
vim.print = _G.dd

require("config.lazy")
vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE")
vim.cmd("hi EndOfBuffer guibg=NONE ctermbg=NONE")
vim.cmd("hi SignColumn guibg=NONE ctermbg=NONE")
vim.cmd("hi MsgArea guibg=NONE ctermbg=NONE")
vim.cmd("hi TelescopeNormal guibg=NONE ctermbg=NONE")
vim.cmd("hi NeoTreeNormal guibg=NONE ctermbg=NONE")
vim.cmd("colorscheme nightfox")
