local commands = require("808.commands")

local M = {}

function M.setup()
	local cmd = vim.api.nvim_create_user_command
	cmd("ExpandTag", function()
		commands.expand_tag()
	end, {})
end

return M
