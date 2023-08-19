const std = @import("std");
const expectEqual = std.testing.expectEqual;
const ascii = std.ascii;

const common = @import("../../common.zig");
const ParseError = @import("../../errors.zig").ParseError;
const masks = @import("../../../machine/masks.zig");

pub fn parseNot(line: []const u8) !u16 {
    var instruction: u16 = 0b1001;

    var ribbon = line;
    const hasDr = ascii.indexOfIgnoreCase(ribbon, "r");
    if (hasDr) |idx| {
        const id: u16 = @intCast(idx);
        try common.addRegisterToInstruction(&instruction, ribbon, id + 1);
        ribbon = ribbon[id + 1 ..];
    } else {
        return ParseError.InvalidInstruction;
    }

    const hasSr = ascii.indexOfIgnoreCase(ribbon, "r");
    if (hasSr) |idx| {
        const id: u16 = @intCast(idx);
        try common.addRegisterToInstruction(&instruction, ribbon, id + 1);
    } else {
        return ParseError.InvalidInstruction;
    }

    // Unused bits [5:0], but they're all 1s
    instruction = instruction << 6;
    instruction |= 0b111111;

    return instruction;
}

test "notParser: NOT R1 R2" {
    const instruction: []const u8 = "NOT R1 R2";
    const parsed = try parseNot(instruction);
    const expected: u16 = 0b1001_001_010_111111;
    try expectEqual(expected, parsed);
}
