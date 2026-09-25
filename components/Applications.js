// Pure helpers shared by pinned items and the running-applications section.
function normalize(value) {
  return String(value || "").toLowerCase().replace(/\.desktop$/, "")
}

function webAppId(entry) {
  if (!entry || !entry.command) return ""
  for (var i = 0; i < entry.command.length; ++i) {
    var match = String(entry.command[i]).match(/https?:\/\/[^?#\s]+/i)
    if (!match) continue
    var url = match[0].replace(/^https?:\/\//i, "").replace(/\/$/, "")
    try { url = decodeURIComponent(url) } catch (error) { /* Keep encoded URL. */ }
    return url.toLowerCase().replace(/[^a-z0-9]/g, "")
  }
  return ""
}

function score(window, desktopId, entry) {
  if (!window) return 0
  var appId = normalize(window.appId)
  if (!appId) return 0
  if (appId === normalize(desktopId) || (entry && appId === normalize(entry.id))) return 100
  if (entry && normalize(entry.startupClass) && appId === normalize(entry.startupClass)) return 90
  var webId = webAppId(entry)
  return webId.length >= 6 && appId.replace(/[^a-z0-9]/g, "").indexOf(webId) >= 0 ? 80 : 0
}

function findEntry(id, entries) {
  for (var i = 0; i < entries.length; ++i)
    if (normalize(entries[i].id) === normalize(id)) return entries[i]
  return null
}

function unpinned(pinned, entries, windows) {
  var result = []
  var groups = Object.create(null)
  var pinnedEntries = pinned.map(function(id) { return findEntry(id, entries) })
  for (var i = 0; i < windows.length; ++i) {
    var window = windows[i]
    if (!window) continue
    var alreadyPinned = false
    for (var p = 0; p < pinned.length; ++p) {
      if (score(window, pinned[p], pinnedEntries[p])) { alreadyPinned = true; break }
    }
    if (alreadyPinned) continue
    var entry = null
    var best = 0
    for (var e = 0; e < entries.length; ++e) {
      var candidate = entries[e]
      var value = score(window, candidate.id, candidate)
      if (value > best) { best = value; entry = candidate }
    }
    var appId = normalize(window.appId)
    var key = entry ? "desktop:" + normalize(entry.id) : appId ? "app:" + appId : "window:" + i
    if (!groups[key]) {
      groups[key] = {key: key, desktopId: entry ? entry.id : "", appId: window.appId || "",
                     entry: entry, windows: []}
      result.push(groups[key])
    }
    groups[key].windows.push(window)
  }
  return result
}
