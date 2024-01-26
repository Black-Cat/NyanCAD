const nyan = @import("nyancore");
const builtin = @import("builtin");

const std = @import("std");

const UI = @import("ui.zig").UI;

fn setDefaultSettings() void {
    var config: *nyan.Config = nyan.app.config;
    config.putBool("swapchain_vsync", true);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator: std.mem.Allocator = gpa.allocator();

    nyan.initGlobalData(allocator);
    defer nyan.deinitGlobalData();

    var renderer: nyan.DefaultRenderer = undefined;
    renderer.init("Main Renderer", allocator);

    var ui: UI = undefined;
    ui.init(allocator);

    var systems: [2]*nyan.System = [_]*nyan.System{
        &renderer.system,
        &ui.ui.system,
    };

    nyan.app.init("NyanCAD", allocator, &systems);
    defer nyan.app.deinit();

    setDefaultSettings();

    try nyan.app.initSystems();
    defer nyan.app.deinitSystems();

    try nyan.app.mainLoop();
}
