-- Adapted from ~/.config/ghostty/config.
-- Apply changes with: rex config check && rex config reload
-- App-assigned shortcuts have priority over this file.

-- Translate the key itself in Codex, including slash/file completion and menus.
-- Preserve Ctrl-I for Fish's file picker and every other foreground program.
rex.action{
  name = "codex_ctrl_i",
  title = "Ctrl-I as Tab in Codex",
  category = "Pane",
  run = function(ctx)
    local key = "ctrl+i"
    if ctx.session_id and ctx.block_id then
      local process, err = rex.call("com.superlogical.terminal.process", {
        session_id = ctx.session_id, block_id = ctx.block_id, args = {},
      })
      if not err and process and process.foreground
          and process.foreground.name == "codex" then
        key = "tab"
      end
    end
    rex.client.queue("pane.send_key", { key = key })
  end,
}
rex.bind("ctrl+i", "codex_ctrl_i")

rex.bind("cmd+enter", "pane.split", { direction = "down" })
for _, key in ipairs({ "cmd+\\", "cmd+;", "cmd+r" }) do
  rex.bind(key, "pane.split", { direction = "right" })
end
rex.bind("cmd+f", "pane.focus_next")
rex.bind("cmd+b", "pane.focus_previous")
rex.bind("cmd+ctrl+enter", "pane.zoom")
-- rex.bind("cmd+k", "client.palette.toggle")

-- Ghostty resizes in pixels; Rex uses percentages of the enclosing split.
for _, direction in ipairs({ "down", "left", "up", "right" }) do
  rex.bind("cmd+ctrl+" .. direction, "pane.resize", {
    direction = direction, amount = 5,
  })
end
for key, direction in pairs({ j = "down", h = "left", k = "up", l = "right" }) do
  rex.bind("cmd+ctrl+" .. key, "pane.resize", {
    direction = direction, amount = 10,
  })
end

-- rex.bind("cmd+t", "client.tab.new")
-- rex.bind("cmd+n", "client.window.new")
-- Match Cmd+Shift+N: create a new session.
rex.bind("cmd+j", "session.new")
rex.bind("cmd+l", "session.switch")
-- rex.bind("cmd+w", "client.close")
-- Match Ghostty: Cmd+Q closes the window, rather than quitting Rex.
-- rex.bind("cmd+q", "client.window.close")
rex.bind("cmd+shift+w", "client.tab.close")
rex.bind("cmd+shift+[", "client.tab.previous")
rex.bind("cmd+shift+]", "client.tab.next")
rex.bind("cmd+=", "client.font.increase")
rex.bind("cmd+-", "client.font.decrease")
-- rex.bind("cmd+0", "client.tab.goto", { index = 1 })

-- Bypass macOS accent/dead-key input (e.g. Option+N producing a tilde),
-- even when Rex's Option-as-Alt setting is enabled. Send an explicit Alt
-- chord instead of forwarding the native event's composed text.
for byte = string.byte("a"), string.byte("z") do
  local letter = string.char(byte)
  for _, modifiers in ipairs({ "alt+", "alt+shift+" }) do
    local key = modifiers .. letter
    rex.bind(key, "pane.send_key", { key = key })
  end
end

-- Forward these chords to the terminal without warning about missing defaults.
-- Cmd+O and Cmd+H are implemented below; the other unsupported Ghostty
-- actions remain unavailable (quick terminal, page scrolling, and file export).
for index = 0, 9 do rex.bind("alt+" .. index, "client.key.forward") end
for _, key in ipairs({ "alt+space", "ctrl+enter", "cmd+p", "cmd+d",
                        "cmd+u", "cmd+g" }) do
  rex.bind(key, "client.key.forward")
end
-- Native macOS Select All / Copy / Paste retain Rex's standard handling.

-- Ghostty's close_tab:other: keep the invoking pane's entire tab.
rex.action{
  name = "ghostty_close_other_tabs",
  title = "Close Other Tabs",
  description = "Keep this tab and its panes; close other tabs in this session.",
  category = "Tab",
  run = function(ctx, args)
    if not ctx.session_id or not ctx.block_id then
      error("Close Other Tabs needs a focused pane in a session.", 0)
    end
    local view, err = rex.session.view{ session_id = ctx.session_id }
    if err then error(err, 0) end
    local keep
    for _, window in ipairs(view.windows or {}) do
      for _, layer in ipairs(window.layers or {}) do
        for _, block in ipairs(layer.blocks or {}) do
          if block.block_id == ctx.block_id then keep = window.window_id end
        end
      end
    end
    if not keep then error("Focused pane was not found; no tabs closed.", 0) end
    local closed = 0
    for _, window in ipairs(view.windows or {}) do
      if window.window_id ~= keep then
        local result, close_err = rex.session.close_window{
          session_id = ctx.session_id, window_id = window.window_id,
        }
        if close_err then error(close_err, 0) end
        closed = closed + 1
      end
    end
    return { kept_window_id = keep, closed_tabs = closed }
  end,
}
rex.bind("cmd+o", "ghostty_close_other_tabs")

rex.action{
  name = "close_other_sessions",
  title = "Close Other Sessions",
  description = "Keep this session; close all other sessions and their tabs and panes on this server.",
  category = "Session",
  run = function(ctx)
    if not ctx.session_id then
      error("Close Other Sessions needs a current session.", 0)
    end
    local result, err = rex.call("session.list", {})
    if err then error(err, 0) end
    local found = false
    for _, session in ipairs(result.sessions or {}) do
      if session.session_id == ctx.session_id then found = true end
    end
    if not found then error("Current session was not found; no sessions closed.", 0) end
    local closed = 0
    for _, session in ipairs(result.sessions or {}) do
      if session.session_id ~= ctx.session_id then
        local _, attach_err = rex.call("session.attach", { session_id = session.session_id })
        if attach_err then error(attach_err, 0) end
        local _, close_err = rex.call("session.destroy", { session_id = session.session_id })
        if close_err then error(close_err, 0) end
        closed = closed + 1
      end
    end
    return { kept_session_id = ctx.session_id, closed_sessions = closed }
  end,
}

-- Capture through Rex's API and start a separate terminal above the source.
-- No input is sent to the source pane, even while it is running a program.
rex.action{
  name = "scrollback_nvim",
  title = "Open Scrollback in Neovim",
  description = "Search, select, and edit a snapshot of this pane in a floating Neovim viewer.",
  category = "Pane",
  run = function(ctx, args)
    if not ctx.session_id or not ctx.block_id then
      error("Open Scrollback needs a focused terminal pane in a session.", 0)
    end
    local pane, err = rex.session.describe_block{
      session_id = ctx.session_id, block_id = ctx.block_id,
    }
    if err then error(err, 0) end
    if pane.block.creator_name ~= "com.superlogical.terminal" or not pane.block.window_id then
      error("Open Scrollback needs a terminal pane in a tab.", 0)
    end

    local function terminal(method, method_args)
      local result, call_err = rex.call("com.superlogical.terminal." .. method, {
        session_id = ctx.session_id, block_id = ctx.block_id, args = method_args,
      })
      if call_err then error(call_err, 0) end
      return result
    end
    local snapshot = terminal("format", {
      format = "text", trim = true, unwrap = true, max_bytes = 256 * 1024,
    })
    -- mktemp creates a private file; never reuse a shared /tmp/kitty.log.
    local temp, temp_err = rex.exec({ "mktemp", "-t", "rex-scrollback" })
    if not temp or not temp.ok then
      error(temp_err or temp.stderr or "Could not create scrollback file.", 0)
    end
    local path = temp.stdout:gsub("[\r\n]+$", "")
    local file
    local ok, result = pcall(function()
      file = assert(io.open(path, "wb"))
      assert(file:write(snapshot.content))
      local offset = #snapshot.content
      if snapshot.id then
        while true do
          local part = terminal("blob_read", {
            id = snapshot.id, offset = offset, max_bytes = 256 * 1024,
          })
          assert(file:write(part.data))
          offset = offset + #part.data
          if part.eof then break end
          if #part.data == 0 then error("Scrollback capture stopped making progress.", 0) end
        end
      end
      assert(file:close())
      file = nil
      local layer, layer_err = rex.session.new_layer{
        session_id = ctx.session_id, window_id = pane.block.window_id,
        bounds = { 0.025, 0.025, 0.95, 0.95 }, focus = true,
        layout = rex.layout.block{
          flavor = "com.superlogical.terminal.shell",
          label = "Scrollback (Neovim)",
          options = {
            -- A fixed wrapper cleans up on exit, including editor startup failure.
            -- The filename is an argument, never interpolated into shell code.
            command = { "/bin/sh", "-c", [[
trap 'rm -f -- "$1"' EXIT
nvim -n -i NONE --cmd 'set nomodeline' \
  -c 'setlocal buftype=nofile bufhidden=wipe noswapfile noundofile' \
  -c 'normal! G' -- "$1"
]], "rex-scrollback", path },
            exit = { on_completion = true },
          },
        },
      }
      if layer_err then error(layer_err, 0) end
      return layer
    end)
    if file then file:close() end
    if not ok then
      os.remove(path)
      error(result, 0)
    end
    return result
  end,
}
rex.bind("cmd+h", "scrollback_nvim")
