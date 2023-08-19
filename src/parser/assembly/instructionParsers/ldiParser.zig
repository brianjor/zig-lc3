const std = @import("std");
const expectEqual = std.testing.expectEqual;
const ascii = std.ascii;

const common = @import("../../common.zig");
const ParseError = @import("../../errors.zig").ParseError;
const masks = @import("../../../machine/masks.zig");

pub fn parseLdi(line: []const u8) !u16 {
    var instruction: u16 = 0b1010;

    const hasReg = ascii.indexOfIgnoreCase(line, "R");
    if (hasReg) |idx| {
        const id: u16 = @intCast(idx);
        try common.addRegisterToInstruction(&instruction, line, id + 1);
    } else {
        return ParseError.InvalidInstruction;
    }

    // Add PcOffset9
    instruction = instruction << 9;
    instruction |= try common.getImmedValue(line, masks.IMMED_9_MASK);

    return instruction;
}

test "parseLoadIndirect: LDI R3 #3" {
    const instruction = "LDI R3 #3";
    const result = try parseLdi(instruction);
    const expected: u16 = 0b1010_011_000000011;
    try expectEqual(expected, result);
}

test "parseLoadIndirect: LDI R3 #-3" {
    const instruction = "LDI R3 #-3";
    const result = try parseLdi(instruction);
    const expected: u16 = 0b1010_011_111111101;
    try expectEqual(expected, result);
}
