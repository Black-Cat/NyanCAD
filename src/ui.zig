const std = @import("std");
const nyan = @import("nyancore");
const nc = nyan.c;

const Allocator = std.mem.Allocator;

fn hexToColor(col: u24) nc.ImVec4 {
    const ch = std.mem.asBytes(&col);
    return .{
        .x = @as(f16, @floatFromInt(ch[2])) / 255.0,
        .y = @as(f16, @floatFromInt(ch[1])) / 255.0,
        .z = @as(f16, @floatFromInt(ch[0])) / 255.0,
        .w = 1.0,
    };
}

pub const mainColors = [_]nc.ImVec4{
    hexToColor(0x041634), // Oxford Blue
    hexToColor(0x01081E), // Xiketic
    hexToColor(0xC79C65), // Camel
    hexToColor(0xDF7716), // Ochre
    hexToColor(0x122F60), // Space Cadet
};

fn mainColorWithTransparency(ind: usize, transparency: f32) nc.ImVec4 {
    var col = mainColors[ind];
    col.w = transparency;
    return col;
}

pub const UI = struct {
    ui: nyan.UI,

    windows: std.ArrayList(*nyan.Widgets.Window),

    ui_system_init_fn: *const fn (system: *nyan.System, app: *nyan.Application) void,
    ui_system_deinit_fn: *const fn (system: *nyan.System) void,

    pub fn init(self: *UI, allocator: Allocator) void {
        self.windows = std.ArrayList(*nyan.Widgets.Window).init(allocator);

        self.ui.init("WasteRed UI", allocator);
        self.ui.paletteFn = UI.palette;
        self.ui.drawFn = UI.draw;

        self.ui_system_init_fn = self.ui.system.init;
        self.ui.system.init = systemInit;

        self.ui_system_deinit_fn = self.ui.system.deinit;
        self.ui.system.deinit = systemDeinit;

        self.ui.rg_pass.initial_layout = .color_attachment_optimal;
        self.ui.rg_pass.load_op = .load;
    }

    pub fn deinit(self: *UI) void {
        self.windows.deinit();
    }

    pub fn activateWindow(self: *UI, window: *nyan.Widgets.Window) void {
        window.widget.init(&window.widget);
        self.windows.append(window) catch unreachable;
    }

    pub fn deactivateWindow(self: *UI, window: *nyan.Widgets.Window) void {
        window.widget.deinit(&window.widget);
        for (self.windows.items, 0..) |w, i| {
            if (w == window) {
                _ = self.windows.swapRemove(i);
                break;
            }
        }
    }

    fn systemInit(system: *nyan.System, app: *nyan.Application) void {
        const ui: *nyan.UI = @fieldParentPtr(nyan.UI, "system", system);
        const self: *UI = @fieldParentPtr(UI, "ui", ui);

        self.ui_system_init_fn(system, app);

        for (self.windows.items) |w|
            w.widget.init(&w.widget);
    }

    fn systemDeinit(system: *nyan.System) void {
        const ui: *nyan.UI = @fieldParentPtr(nyan.UI, "system", system);
        const self: *UI = @fieldParentPtr(UI, "ui", ui);

        for (self.windows.items) |w|
            w.widget.deinit(&w.widget);

        self.ui_system_deinit_fn(system);
    }

    fn draw(ui: *nyan.UI) void {
        const self: *UI = @fieldParentPtr(UI, "ui", ui);

        for (self.windows.items) |w|
            w.widget.draw(&w.widget);
    }

    fn palette(col: nc.ImGuiCol_) nc.ImVec4 {
        return switch (col) {
            nc.ImGuiCol_Text => .{ .x = 1.0, .y = 0.9, .z = 0.9, .w = 1.0 },
            nc.ImGuiCol_TextDisabled => mainColors[1],
            nc.ImGuiCol_WindowBg => mainColors[1],
            nc.ImGuiCol_ChildBg => mainColors[3],
            nc.ImGuiCol_PopupBg => mainColors[2],
            nc.ImGuiCol_Border => mainColors[1],
            nc.ImGuiCol_BorderShadow => mainColors[1],
            nc.ImGuiCol_FrameBg => mainColors[4],
            nc.ImGuiCol_FrameBgHovered => mainColors[1],
            nc.ImGuiCol_FrameBgActive => mainColors[2],
            nc.ImGuiCol_TitleBg => mainColors[0],
            nc.ImGuiCol_TitleBgActive => mainColors[1],
            nc.ImGuiCol_TitleBgCollapsed => mainColors[2],
            nc.ImGuiCol_MenuBarBg => mainColors[4],
            nc.ImGuiCol_ScrollbarBg => mainColors[2],
            nc.ImGuiCol_ScrollbarGrab => mainColors[1],
            nc.ImGuiCol_ScrollbarGrabHovered => mainColors[1],
            nc.ImGuiCol_ScrollbarGrabActive => mainColors[4],
            nc.ImGuiCol_CheckMark => mainColors[0],
            nc.ImGuiCol_SliderGrab => mainColors[3],
            nc.ImGuiCol_SliderGrabActive => mainColors[4],
            nc.ImGuiCol_Button => mainColors[4],
            nc.ImGuiCol_ButtonHovered => mainColors[2],
            nc.ImGuiCol_ButtonActive => mainColors[3],
            nc.ImGuiCol_Header => mainColors[4],
            nc.ImGuiCol_HeaderHovered => mainColors[2],
            nc.ImGuiCol_HeaderActive => mainColors[3],
            nc.ImGuiCol_Separator => mainColors[4],
            nc.ImGuiCol_SeparatorHovered => mainColors[2],
            nc.ImGuiCol_SeparatorActive => mainColors[3],
            nc.ImGuiCol_ResizeGrip => mainColors[4],
            nc.ImGuiCol_ResizeGripHovered => mainColors[2],
            nc.ImGuiCol_ResizeGripActive => mainColors[3],
            nc.ImGuiCol_Tab => mainColors[4],
            nc.ImGuiCol_TabHovered => mainColors[2],
            nc.ImGuiCol_TabActive => mainColors[3],
            nc.ImGuiCol_TabUnfocused => mainColorWithTransparency(1, 0.8),
            nc.ImGuiCol_TabUnfocusedActive => mainColorWithTransparency(2, 0.8),
            nc.ImGuiCol_PlotLines => mainColors[0],
            nc.ImGuiCol_PlotLinesHovered => mainColors[1],
            nc.ImGuiCol_PlotHistogram => mainColors[1],
            nc.ImGuiCol_PlotHistogramHovered => mainColors[0],
            nc.ImGuiCol_TableHeaderBg => mainColors[4],
            nc.ImGuiCol_TableBorderStrong => mainColors[1],
            nc.ImGuiCol_TableBorderLight => mainColors[4],
            nc.ImGuiCol_TableRowBg => mainColors[0],
            nc.ImGuiCol_TableRowBgAlt => mainColors[4],
            nc.ImGuiCol_TextSelectedBg => mainColors[1],
            nc.ImGuiCol_DragDropTarget => mainColors[2],
            nc.ImGuiCol_NavHighlight => mainColors[3],
            nc.ImGuiCol_NavWindowingHighlight => mainColors[3],
            nc.ImGuiCol_NavWindowingDimBg => mainColors[0],
            nc.ImGuiCol_ModalWindowDimBg => mainColorWithTransparency(1, 0.5),
            else => @panic("Unknown Style"),
        };
    }
};
