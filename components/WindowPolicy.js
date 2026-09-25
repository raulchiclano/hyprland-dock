// Window identity comes from Hyprland's native Wayland handle, never the title.
function select(windows, hyprWindows, workspaceId, monitorId) {
  var local = [], remote = []
  for (var i = 0; i < windows.length; ++i) {
    var window = windows[i]
    if (!window) continue
    for (var j = 0; j < hyprWindows.length; ++j) {
      var h = hyprWindows[j]
      if (h.wayland !== window || !h.workspace) continue
      var data = h.lastIpcObject || {}
      var rank = Number(data.focusHistoryID)
      var item = {window: window, address: h.address, workspaceId: h.workspace.id,
                  workspaceName: h.workspace.name, active: window.activated,
                  rank: isNaN(rank) || rank < 0 ? Infinity : rank}
      var here = h.workspace.id === workspaceId
        || (data.pinned === true && h.monitor && h.monitor.id === monitorId)
      if (here) local.push(item)
      else remote.push(item)
      break
    }
  }
  function recent(a, b) {
    if (a.active !== b.active) return a.active ? -1 : 1
    return a.rank - b.rank
  }
  local.sort(recent)
  remote.sort(recent)
  return {local: local, remote: remote}
}

// Only known multi-window entry points may be used while the app is running.
// A generic execute() can activate a singleton on a different workspace.
function launchPlan(entry, running) {
  if (!entry) return {kind: 'blocked'}
  var id = String(entry.id).toLowerCase().replace(/\.desktop$/, '')
  var actions = entry.actions || []
  // Zen's ordinary "new-window" action may reuse its existing window.
  var preferred = id === 'zen' ? ['new-blank-window'] : ['new-window', 'new-empty-window']
  for (var p = 0; p < preferred.length; ++p)
    for (var a = 0; a < actions.length; ++a)
      if (actions[a].id === preferred[p]) return {kind: 'action', action: actions[a]}
  if (id === 'foot' || id === 'footclient') return {kind: 'entry'}
  return {kind: running ? 'blocked' : 'entry'}
}

function intent(localCount, canLaunch, alwaysLaunch) {
  if (localCount > 0 && !alwaysLaunch) return 'focus'
  if (canLaunch) return 'launch'
  return 'menu'
}

function focusRequest(address, usingLua) {
  var raw = String(address || "").replace(/^0x/, "")
  if (!/^[0-9a-f]+$/i.test(raw)) return ""
  var selector = "address:0x" + raw
  return usingLua ? 'hl.dsp.focus({ window = "' + selector + '" })'
    : "focuswindow " + selector
}

// Flat rows let the chooser scroll both groups together without nested popups.
function windowRows(selection) {
  var rows = []
  var groups = [{label: "Este escritorio", windows: selection.local},
                {label: "Otros escritorios", windows: selection.remote}]
  var all = selection.local.concat(selection.remote).slice().sort(function(a, b) {
    return String(a.address).localeCompare(String(b.address))
  })
  for (var g = 0; g < groups.length; ++g) {
    var group = groups[g]
    if (!group.windows.length) continue
    rows.push({header: true, title: group.label + " · " + group.windows.length})
    for (var i = 0; i < group.windows.length; ++i) {
      var target = group.windows[i]
      if (!target.window) continue
      var number = all.indexOf(target) + 1
      var workspace = target.workspaceId < 0 ? target.workspaceName
        : "Escritorio " + target.workspaceName
      rows.push({header: false, address: target.address,
        title: String(target.window.title || "Ventana sin título"),
        subtitle: "Ventana " + number + " · " + workspace,
        active: target.window.activated === true})
    }
  }
  return rows
}

function findWindow(selection, address) {
  var windows = selection.local.concat(selection.remote)
  for (var i = 0; i < windows.length; ++i)
    if (windows[i].address === address && windows[i].window) return windows[i]
  return null
}

function indicator(selection) {
  var windows = selection.local.concat(selection.remote)
  for (var i = 0; i < windows.length; ++i)
    if (windows[i].window && windows[i].window.activated) return "active"
  if (selection.local.length > 1) return "multiple"
  if (selection.local.length === 1) return "local"
  return selection.remote.length ? "remote" : "closed"
}

function windowSummary(name, selection) {
  var local = selection.local.length, remote = selection.remote.length
  if (!local && !remote) return name
  return name + " · " + local + " aquí"
    + (remote ? " · " + remote + " en otros escritorios" : "")
}
