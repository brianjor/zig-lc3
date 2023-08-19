const std = @import("std");
const expectEqual = std.testing.expectEqual;
const ascii = std.ascii;

const common = @import("../../common.zig");
const ParseError = @import("../../errors.zig").ParseError;
const masks = @import("../../../machine/masks.zig");

pub fn parseStr(line: []const u8) !u16 {
    var instruction: u16 = 0b0111;

    var ribbon = line[3..];

    // Get Source Register
    const srIdx: u16 = @intCast(ascii.indexOfIgnoreCase(ribbon, "r") orelse return ParseError.InvalidInstruction);
    try common.addRegisterToInstruction(&instruction, ribbon, srIdx + 1);
    ribbon = ribbon[srIdx + 1 ..];

    // Get Base Register
    const baseRIdx: u16 = @intCast(ascii.indexOfIgnoreCase(ribbon, "r") orelse return ParseError.InvalidInstruction);
    try common.addRegisterToInstruction(&instruction, ribbon, baseRIdx + 1);

    // Get offset6
    instruction = instruction << 6;
    instruction |= try common.getImmedValue(line, masks.IMMED_6_MASK);

    return instruction;
}

test "parseStr: STR R2 R3 #3" {
    const instruction = "ST R2 R3 #3";
    const parsed = try parseStr(instruction);
    const expected: u16 = 0b0111_010_011_000011;
    try expectEqual(expected, parsed);
}

test "parseStr: STR R2 R3 xF" {
    const instruction = "ST R2 R3 xF";
    const parsed = try parseStr(instruction);
    const expected: u16 = 0b0111_010_011_001111;
    try expectEqual(expected, parsed);
}
