-- Adapted from ~/.config/ghostty/config.
-- Apply changes with: rex config check && rex config reload
-- App-assigned shortcuts have priority over this file.

rex.bind("cmd+enter", "pane.split", { direction = "down" })
for _, key in ipairs({ "cmd+\\", "cmd+l", "cmd+;", "cmd+r" }) do
  rex.bind(key, "pane.split", { direction = "right" })
end
rex.bind("cmd+f", "pane.focus_next")
rex.bind("cmd+b", "pane.focus_previous")
rex.bind("cmd+ctrl+enter", "pane.zoom")
rex.bind("cmd+k", "client.palette.toggle")

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

rex.bind("cmd+t", "client.tab.new")
rex.bind("cmd+n", "client.window.new")
rex.bind("cmd+w", "client.close")
-- Match Ghostty: Cmd+Q closes the window, rather than quitting Rex.
rex.bind("cmd+q", "client.window.close")
rex.bind("cmd+shift+w", "client.tab.close")
rex.bind("cmd+shift+[", "client.tab.previous")
rex.bind("cmd+shift+]", "client.tab.next")
rex.bind("cmd+=", "client.font.increase")
rex.bind("cmd+-", "client.font.decrease")
-- rex.bind("cmd+0", "client.tab.goto", { index = 1 })

-- Forward these chords to the terminal without warning about missing defaults.
-- Cmd+O is implemented below; the other unsupported Ghostty actions remain
-- unavailable (quick terminal, page scrolling, and screen-file export/editor).
for index = 0, 9 do rex.bind("alt+" .. index, "client.key.forward") end
for _, key in ipairs({ "alt+space", "ctrl+enter", "cmd+p", "cmd+d",
                        "cmd+u", "cmd+g", "cmd+h" }) do
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
