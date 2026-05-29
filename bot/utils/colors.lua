local colors = {
  reset = '\27[0m'
}

colors.xterm256color = (function ()
  local term = os.getenv('TERM')
  if term and (term == 'xterm' or term:find'-256color$') then
    return true
  else
    return false
  end
end)

colors.brightBlack = '\27[38;5;8m'
colors.brightRed = '\27[38;5;9m'
colors.brightGreen = '\27[38;5;10m'
colors.brightYellow = '\27[38;5;11m'
colors.brightBlue = '\27[38;5;12m'
colors.brightMagenta = '\27[38;5;13m'
colors.brightCyan = '\27[38;5;14m'
colors.brightOrange = '\27[38;5;202m'
colors.brightWhite = '\27[38;5;15m'

return colors
