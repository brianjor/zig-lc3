const std = @import("std");
const expectEqual = std.testing.expectEqual;
const ascii = std.ascii;

const common = @import("../../common.zig");
const ParseError = @import("../../errors.zig").ParseError;
const masks = @import("../../../machine/masks.zig");

pub fn parseJsr(line: []const u8) !u16 {
    var instruction: u16 = 0b0100;

    const isJsrr = ascii.startsWithIgnoreCase(line, "JSRR");
    if (isJsrr) {
        // Unsused bits [11:9]
        instruction = instruction << 3;

        // Line without "JSRR", the "R"s get in the way of finding the register index
        const minusCommand = line[4..];
        const hasReg = ascii.indexOfIgnoreCase(minusCommand, "R");
        if (hasReg) |idx| {
            instruction = instruction << 3;
            instruction += try std.fmt.parseInt(u16, minusCommand[idx + 1 .. idx + 2], 10);
        } else {
            return ParseError.InvalidInstruction;
        }
        // Unused bits [5:0]
        instruction = instruction << 6;
    } else { // JSR
        instruction = instruction << 1;
        instruction += 1;

        const pcOffset = try common.getImmedValue(line, masks.IMMED_11_MASK);

        instruction = instruction << 11;
        instruction |= pcOffset;
    }

    return instruction;
}

test "parseJsr: JSRR R4" {
    const instruction: []const u8 = "JSRR R4";
    const parsed = try parseJsr(instruction);
    const expected: u16 = 0b0100_000_100_000000;
    try expectEqual(expected, parsed);
}

test "parseJsr: JSR #3" {
    const instruction: []const u8 = "JSR #3";
    const parsed = try parseJsr(instruction);
    const expected: u16 = 0b0100_1_00000000011;
    try expectEqual(expected, parsed);
}
