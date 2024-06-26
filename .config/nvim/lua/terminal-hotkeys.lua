-- [[ Terminal Hotkeys ]]

-- Make exiting the terminal buffer easier when spawned from a hotkey.
vim.keymap.set("n", "<Esc>", function()
	vim.cmd.nohlsearch() -- This keymap clobbers a previous keymap to clear search, so we stuff it back here again.

	if vim.bo.buftype == "terminal" and vim.b.terminal_exits_easily == true then
		vim.cmd.bdelete()
	end
end, { desc = "Exit terminal buffer more easily when spawned from a hotkey." })

-- Pops a terminal in insert mode.
vim.keymap.set("n", "<F3>", function()
	vim.cmd.split()
	vim.cmd.terminal()
	vim.cmd.startinsert()
end, { desc = "Opens a terminal in insert mode." })

-- Function snippet from:
-- https://stackoverflow.com/questions/76675375/how-to-get-all-files-and-directories-within-the-current-working-directory-of-neo
-- Checks if name_to_check is in the cwd.
local exists_in_cwd = function(name_to_check)
	local cwd_path = vim.fn.getcwd()

	-- Get all files and directories in CWD
	local cwd_files_and_directories = vim.split(vim.fn.glob(cwd_path .. "/*"), "\n", { trimempty = true })

	-- Check if specified file or directory exists
	local full_path_to_check = cwd_path .. "/" .. name_to_check
	print('Checking for: "' .. full_path_to_check .. '"')
	for _, item in pairs(cwd_files_and_directories) do
		if item == full_path_to_check then
			return true
		end
	end
	return false
end

-- Compiles and runs the current file in a new terminal buffer.
-- Compilation command can be changed with 'f5cmd'.
vim.keymap.set("n", "<F5>", function()
	local cmd = nil

	if vim.g.f5cmd ~= nil then
		cmd = vim.g.f5cmd
	else
		local filetype_to_command = {
			["rust"] = "cargo run",
			["c"] = "make && echo \"Running './" .. vim.fn.expand("%:t:r") .. "'...\" && ./" .. vim.fn.expand("%:t:r"),
			["java"] = "make && echo \"Running 'java " .. vim.fn.expand("%:t:r") .. "'...\" && java " .. vim.fn.expand(
				"%:t:r"
			),
			["python"] = "python3 " .. vim.fn.expand("%"),
			["sh"] = "bash " .. vim.fn.expand("%"),
			["tex"] = "pdflatex " .. vim.fn.expand("%"),
		}

		cmd = filetype_to_command[vim.bo.filetype]

		if exists_in_cwd("Makefile") and vim.bo.filetype ~= "java" then
			cmd = "make && echo \"Running './" .. vim.fn.expand("%:t:r") .. "'...\" && ./" .. vim.fn.expand("%:t:r")
		end

		if cmd == nil then
			print("No default compile cmd found; set f5cmd with: :F5cmd <insert-cmd-here>")
			return
		end
	end

	vim.cmd.split()
	vim.cmd.terminal(cmd)
	vim.b.terminal_exits_easily = true
	vim.cmd.startinsert()
end, { desc = "Compile and run the current file, or specify a command with f5cmd." })

-- Compiles the current file in a new terminal buffer without running it.
-- Compilation command can be changed with 'f6cmd'.
vim.keymap.set("n", "<F6>", function()
	local cmd = nil

	if vim.g.f6cmd ~= nil then
		cmd = vim.g.f6cmd
	else
		local filetype_to_command = {
			["rust"] = "cargo check",
			["c"] = "make",
		}

		cmd = filetype_to_command[vim.bo.filetype]

		if exists_in_cwd("Makefile") then
			cmd = "make"
		end

		if cmd == nil then
			print("No default compile cmd found; set f6cmd with: :F6cmd <insert-cmd-here>")
			return
		end
	end

	vim.cmd.split()
	vim.cmd.terminal(cmd)
	vim.b.terminal_exits_easily = true
	vim.cmd.startinsert()
end, { desc = "Compile the current file without running it, or specify a command with f6cmd." })

-- Define user commands to make writing custom compilation commands less painful.
-- :F5cmd <arg> is equivalent to :lua vim.g.f5cmd = '<arg>'
vim.api.nvim_create_user_command("F5cmd", function(opts)
	vim.g.f5cmd = opts.fargs[1]
end, { nargs = 1 })

vim.api.nvim_create_user_command("Clearf5cmd", function()
	vim.g.f5cmd = nil
end, {})

vim.api.nvim_create_user_command("F6cmd", function(opts)
	vim.g.f6cmd = opts.fargs[1]
end, { nargs = 1 })

vim.api.nvim_create_user_command("Clearf6cmd", function()
	vim.g.f6cmd = nil
end, {})

-- vim: ts=2 sts=2 sw=2 et
