const std = @import("std");
const ascii = std.ascii;

const common = @import("../../common.zig");
const ParseError = @import("../../errors.zig").ParseError;

pub fn parseJmp(line: []const u8) !u16 {
    var instruction: u16 = 0b1100;

    // Unused bits, [11:9]
    instruction = instruction << 3;

    // Add base register
    instruction = instruction << 3;
    const hasReg = ascii.indexOfIgnoreCase(line, "R");
    if (hasReg) |idx| {
        instruction += try std.fmt.parseInt(u16, line[idx + 1 .. idx + 2], 10);
    } else {
        return ParseError.InvalidInstruction;
    }

    // Unused bits [5:0]
    instruction = instruction << 6;

    return instruction;
}

test "parseJump: JMP R6" {
    const instruction: []const u8 = "JMP R6";
    const parsed = try parseJmp(instruction);
    const expected: u16 = 0b1100_000_110_000000;
    try std.testing.expectEqual(expected, parsed);
}
