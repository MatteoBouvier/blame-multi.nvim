vim.api.nvim_create_user_command("DevReload", function(opts)
	for k, _ in pairs(package.loaded) do
		if string.match(k, "blame%-multi") then
			package.loaded[k] = nil
		end
	end

	require('blame-multi').setup()
end, {})

vim.api.nvim_create_user_command("DevLogClear", function(opts)
	require('blame-multi.logger'):clear()
end, {})

vim.api.nvim_create_user_command("DevLog", function(opts)
	require('blame-multi.logger'):show()
end, {})

vim.api.nvim_set_keymap('n', '<leader>zb', ':BlameToggle<CR>', {})
