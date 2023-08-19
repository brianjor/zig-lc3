const std = @import("std");
const expectEqual = std.testing.expectEqual;
const ascii = std.ascii;

const common = @import("../../common.zig");
const ParseError = @import("../../errors.zig").ParseError;
const masks = @import("../../../machine/masks.zig");

pub fn parseTrap(line: []const u8) !u16 {
    var instruction: u16 = 0b1111;

    // Unused bits [11:8]
    instruction = instruction << 4;

    // Get trapvect8
    instruction = instruction << 8;
    instruction |= try common.getImmedValue(line, masks.TRAP_VECT_MASK);

    return instruction;
}

test "parseTrap: TRAP x25" {
    const instruction: []const u8 = "TRAP x25";
    const parsed = try parseTrap(instruction);
    const expected: u16 = 0b1111_0000_0010_0101;
    try expectEqual(expected, parsed);
}
