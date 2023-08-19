const std = @import("std");
const expectEqual = std.testing.expectEqual;
const ascii = std.ascii;

const common = @import("../../common.zig");
const ParseError = @import("../../errors.zig").ParseError;
const masks = @import("../../../machine/masks.zig");

pub fn parseLdr(line: []const u8) !u16 {
    var instruction: u16 = 0b0110;

    // cut up version of the instruction, since there are a lot of "r"s
    var ribbon = line[3..];
    const hasDr = ascii.indexOfIgnoreCase(ribbon, "r");
    if (hasDr) |idx| {
        const id: u16 = @intCast(idx);
        try common.addRegisterToInstruction(&instruction, ribbon, id + 1);

        ribbon = ribbon[id + 1 ..];
    } else {
        return ParseError.InvalidInstruction;
    }

    const hasBr = ascii.indexOfIgnoreCase(ribbon, "r");
    if (hasBr) |idx| {
        const id: u16 = @intCast(idx);
        try common.addRegisterToInstruction(&instruction, ribbon, id + 1);
    } else {
        return ParseError.InvalidInstruction;
    }

    // Get Immed6
    instruction = instruction << 6;
    instruction |= try common.getImmedValue(ribbon, masks.IMMED_6_MASK);

    return instruction;
}

test "parseLdr: LDR R4 R3 #3" {
    const instruction: []const u8 = "LDR R4 R3 #3";
    const result = try parseLdr(instruction);
    const expected: u16 = 0b0110_100_011_000011;
    try expectEqual(expected, result);
}

test "parseLdr: LDR R4 R3 xe1 (#-31)" {
    const instruction: []const u8 = "LDR R4 R3 xe0";
    const result = try parseLdr(instruction);
    const expected: u16 = 0b0110_100_011_100000;
    try expectEqual(expected, result);
}
