const std = @import("std");
const expectEqual = std.testing.expectEqual;
const ascii = std.ascii;

const common = @import("../../common.zig");
const ParseError = @import("../../errors.zig").ParseError;
const masks = @import("../../../machine/masks.zig");

pub fn parseLea(line: []const u8) !u16 {
    var instruction: u16 = 0b1110;

    const hasDr = ascii.indexOfIgnoreCase(line, "r");
    if (hasDr) |idx| {
        const id: u16 = @intCast(idx);
        try common.addRegisterToInstruction(&instruction, line, id + 1);
    } else {
        return ParseError.InvalidInstruction;
    }

    // Get PcOffest9
    instruction = instruction << 9;
    instruction |= try common.getImmedValue(line, masks.IMMED_9_MASK);

    return instruction;
}

test "parseLea" {
    const instruction: []const u8 = "LEA R4 #3";
    const result = try parseLea(instruction);
    const expected: u16 = 0b1110_100_000000011;
    try expectEqual(expected, result);
}
