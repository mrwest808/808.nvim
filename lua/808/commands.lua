local M = {}

local function enter_normal_mode()
	local key = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.api.nvim_feedkeys(key, "n", false)
end

local function enter_insert_mode()
	vim.api.nvim_feedkeys("i", "n", true)
end

local function get_expandable_word_behind_cursor()
	local column_number = vim.fn.col(".")
	local line_number = vim.fn.line(".")
	local line_text = vim.fn.getline(line_number)
	---@diagnostic disable-next-line: param-type-mismatch
	local text_before_cursor = string.sub(line_text, math.max(1, column_number - 40), column_number - 1)
	---@diagnostic disable-next-line: param-type-mismatch
	local last_char = string.sub(line_text, column_number - 1, column_number - 1)

	if not last_char:match("[a-zA-Z0-6._-]") then
		return nil
	end

	return string.match(text_before_cursor, "[a-zA-Z0-6._-]+$")
end

function M.expand_tag()
	if vim.fn.mode() ~= "i" then
		print("Must run expand_tag() from INSERT mode.")
		return
	end

	local current_word = get_expandable_word_behind_cursor()

	if current_word == nil or current_word == "" then
		return
	end

	local current_world_length = string.len(current_word)

	enter_normal_mode()

	-- NOTE: Used `ciW` motion before to allow expansion
	-- of words separated by dashes and dots, but the `ciW`
	-- also removed surrounding parentheses which isn't
	-- desirable. Changing from `ciW` motion to a manual
	-- jump + change motion based on the length of `current_word` :

	-- jump one character forward
	-- change until backwards until start of current_word
	vim.api.nvim_feedkeys("l", "n", true)
	vim.api.nvim_feedkeys("c" .. current_world_length .. "h", "n", true)

	-- insert the opening bracket
	vim.api.nvim_feedkeys("<", "n", true)

	-- move the cursor to the end of the word
	vim.api.nvim_feedkeys(current_word, "n", true)

	-- insert the closing bracket
	vim.api.nvim_feedkeys(">", "n", true)

	vim.api.nvim_feedkeys("</", "n", true)
	vim.api.nvim_feedkeys(current_word, "n", true)
	vim.api.nvim_feedkeys(">", "n", true)

	enter_normal_mode()

	vim.api.nvim_feedkeys("F<", "n", true)

	enter_insert_mode()
end

return M
