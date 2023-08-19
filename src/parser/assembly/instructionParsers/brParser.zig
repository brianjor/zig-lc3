const std = @import("std");
const ascii = std.ascii;

const common = @import("../../common.zig");
const ParseError = @import("../../errors.zig").ParseError;

pub fn parseBr(line: []const u8) !u16 {
    // Instruction opcode
    var instruction: u16 = 0b0000;

    // Add n bit flag, [11]
    const hasN = ascii.indexOfIgnoreCase(line, "n");
    instruction = instruction << 1;
    if (hasN) |_| {
        instruction += 1;
    }

    // Add z bit flag, [10]
    const hasZ = ascii.indexOfIgnoreCase(line, "z");
    instruction = instruction << 1;
    if (hasZ) |_| {
        instruction += 1;
    }

    // Add p bit flag, [9]
    const hasP = ascii.indexOfIgnoreCase(line, "p");
    instruction = instruction << 1;
    if (hasP) |_| {
        instruction += 1;
    }

    // Add PC offset, [8:0]
    instruction = instruction << 9;
    const isHex = ascii.indexOfIgnoreCase(line, "x");
    const isDec = ascii.indexOfIgnoreCase(line, "#");
    if (isHex) |idx| {
        const value = try std.fmt.parseInt(u16, line[idx + 1 ..], 16);
        instruction += value;
    } else if (isDec) |idx| {
        const value = try std.fmt.parseInt(u16, line[idx + 1 ..], 10);
        instruction += value;
    } else {
        return ParseError.InvalidInstruction;
    }

    return instruction;
}

test "parseBranch: BRn #1" {
    const instruction: []const u8 = "BRn #1";
    const parsed = try parseBr(instruction);
    const expected: u16 = 0b0000_1_0_0_000000001;
    try std.testing.expectEqual(expected, parsed);
}

test "parseBranch: BRz #1" {
    const instruction: []const u8 = "BRz #1";
    const parsed = try parseBr(instruction);
    const expected: u16 = 0b0000_0_1_0_000000001;
    try std.testing.expectEqual(expected, parsed);
}

test "parseBranch: BRp #1" {
    const instruction: []const u8 = "BRp #1";
    const parsed = try parseBr(instruction);
    const expected: u16 = 0b0000_0_0_1_000000001;
    try std.testing.expectEqual(expected, parsed);
}

test "parseBranch: BRnzp #1" {
    const instruction: []const u8 = "BRnzp #1";
    const parsed = try parseBr(instruction);
    const expected: u16 = 0b0000_1_1_1_000000001;
    try std.testing.expectEqual(expected, parsed);
}

test "parseBranch: BRn x1" {
    const instruction: []const u8 = "BRn xf";
    const parsed = try parseBr(instruction);
    const expected: u16 = 0b0000_1_0_0_000001111;
    try std.testing.expectEqual(expected, parsed);
}
