const std = @import("std");
const expectEqual = std.testing.expectEqual;
const ascii = std.ascii;

const common = @import("../../common.zig");
const ParseError = @import("../../errors.zig").ParseError;
const masks = @import("../../../machine/masks.zig");

pub fn parseSti(line: []const u8) !u16 {
    var instruction: u16 = 0b1011;

    const hasSr = ascii.indexOfIgnoreCase(line, "r");
    if (hasSr) |idx| {
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

test "parseStore: ST R2 #234" {
    const instruction = "ST R2 #234";
    const parsed = try parseSti(instruction);
    const expected: u16 = 0b1011_010_011101010;
    try expectEqual(expected, parsed);
}
