// Coordinates are logical compositor coordinates, before hide animations.
function dockRect(x, y, sw, sh, width, height, thickness, margin, edge) {
  if (edge === "left") return [x + margin, y + (sh - height) / 2, thickness, height];
  if (edge === "right") return [x + sw - thickness - margin, y + (sh - height) / 2, thickness, height];
  return [x + (sw - width) / 2, edge === "top" ? y + margin : y + sh - thickness - margin, width, thickness];
}
function occludes(client, rect, visible) {
  if (!client || client.mapped === false || client.hidden || !client.at || !client.size) return false;
  if (!client.pinned && (!client.workspace || visible.indexOf(client.workspace.id) < 0)) return false;
  var x = client.at[0], y = client.at[1], w = client.size[0], h = client.size[1];
  return w > 0 && h > 0 && x < rect[0] + rect[2] && x + w > rect[0]
    && y < rect[1] + rect[3] && y + h > rect[1];
}
