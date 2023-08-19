const std = @import("std");
const expectEqual = std.testing.expectEqual;
const ascii = std.ascii;

const common = @import("../../common.zig");
const ParseError = @import("../../errors.zig").ParseError;
const masks = @import("../../../machine/masks.zig");

pub fn parseLd(line: []const u8) !u16 {
    var instruction: u16 = 0b0010;

    const hasReg = ascii.indexOfIgnoreCase(line, "R");
    if (hasReg) |idx| {
        const id: u16 = @intCast(idx);
        try common.addRegisterToInstruction(&instruction, line, id + 1);
    } else {
        return ParseError.InvalidInstruction;
    }

    // Get PcOffset9
    instruction = instruction << 9;
    instruction |= try common.getImmedValue(line, masks.IMMED_9_MASK);

    return instruction;
}

test "parseLd: LD R4 #3" {
    const instruction: []const u8 = "LD R4 #3";
    const result = try parseLd(instruction);
    const expected: u16 = 0b0010_100_000000011;
    try expectEqual(expected, result);
}

test "parseLd: LD R6 x3" {
    const instruction: []const u8 = "LD R6 xf";
    const result = try parseLd(instruction);
    const expected: u16 = 0b0010_110_000001111;
    try expectEqual(expected, result);
}
