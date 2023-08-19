const std = @import("std");
const expectEqual = std.testing.expectEqual;
const ascii = std.ascii;

const common = @import("../../common.zig");
const masks = @import("../../../machine/masks.zig");

pub fn parseAnd(line: []const u8) !u16 {
    // Instruction opcode
    var instruction: u16 = 0b0101;

    // add destination register
    try common.addRegisterToInstruction(&instruction, line, 5);

    // add source register 1
    try common.addRegisterToInstruction(&instruction, line, 9);

    const isDecImmedMode = ascii.indexOfIgnoreCase(line, "#");
    const isHexImmedMode = ascii.indexOfIgnoreCase(line, "x");
    if (isDecImmedMode != null or isHexImmedMode != null) {
        // Add immed mode bit (1)
        instruction = instruction << 1;
        instruction += 1;

        // Add immed value
        instruction = instruction << 5;
        instruction |= try common.getImmedValue(line, masks.IMMED_5_MASK);
    } else { // Register mode
        // Add immed mode (0) and unused bits (00)
        instruction = instruction << 3;

        // Add source register 2
        try common.addRegisterToInstruction(&instruction, line, 13);
    }
    return instruction;
}

test "parseAnd: 'AND R4, R3, #1'" {
    const instruction: []const u8 = "AND R4, R3, #1";
    const parsed = try parseAnd(instruction);
    const expected: u16 = 0b0101_100_011_1_00001;
    try std.testing.expectEqual(expected, parsed);
}

test "parseAnd: 'AND R4, R3, R5'" {
    const instruction: []const u8 = "AND R4, R3, R5";
    const parsed = try parseAnd(instruction);
    const expected: u16 = 0b0101_100_011_0_00_101;
    try std.testing.expectEqual(expected, parsed);
}
