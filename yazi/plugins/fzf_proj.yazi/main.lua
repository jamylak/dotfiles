local state = ya.sync(function()
	return cx.active.current.cwd
end)

local function fail(s, ...)
	ya.notify({ title = "Fzf", content = string.format(s, ...), timeout = 5, level = "error" })
end

local function entry()
	local _permit = ya.hide()
	local cwd = tostring(state())

	local child, err =
		-- Command("fzf"):cwd(cwd):stdin(Command.INHERIT):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()
		Command("sh")
			:arg({ "-c", "ls -d /Applications/ /tmp/ $HOME/ ~/.Trash/ ~/.config/ ~/bar/*/ ~/proj/*/ ~/.config/dotfiles/ ~/.config/nvim/ | fzf --bind ctrl-j:accept" })
			:cwd(cwd)
			:stdin(Command.INHERIT)
			:stdout(Command.PIPED)
			:stderr(Command.INHERIT)
			:spawn()

	if not child then
		return fail("Failed to start `fzf`, error: " .. err)
	end

	local output, err = child:wait_with_output()
	if not output then
		return fail("Cannot read `fzf` output, error: " .. err)
	elseif not output.status.success and output.status.code ~= 130 then
		return fail("`fzf` exited with error code %s", output.status.code)
	end

	local target = output.stdout:gsub("\n$", "")
	if target ~= "" then
		ya.mgr_emit(target:find("[/\\]$") and "cd" or "reveal", { target })
	end
end

return { entry = entry }
