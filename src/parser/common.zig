const std = @import("std");
const expectEqual = std.testing.expectEqual;
const ascii = std.ascii;

const ParseError = @import("../parser/errors.zig").ParseError;
const masks = @import("../machine/masks.zig");

/// Adds a register to the partially built instruction. \
/// \
/// `partialInstruction` pointer the the partially built instruction \
/// `line` source of the instruction information \
/// `index` index to get register value from line \
/// Throws: `ParseIntError`
pub fn addRegisterToInstruction(partialInstruction: *u16, line: []const u8, index: u16) !void {
    const register = line[index .. index + 1];
    partialInstruction.* = partialInstruction.* << 3;
    partialInstruction.* += try std.fmt.parseInt(u16, register, 10);
}

test "addRegisterToInstruction" {
    const line: []const u8 = "4";
    var instruction: u16 = 0b0;
    try addRegisterToInstruction(&instruction, line, 0);
    const expected: u16 = 0b100;
    try std.testing.expectEqual(expected, instruction);
}

/// Gets the immed value from the instruction string.
/// Uses mask to zero out bits not a part of the immed value.
/// ---
/// Ex:
/// - Immed5 with value of `#3` and mask of `0b00000000000_11111` returns `0b00000000000_00011`
/// - Immed9 with value of `#-3` and mask of `0b0000000_111111111` returns `0b0000000_111111101`
pub fn getImmedValue(line: []const u8, mask: u16) !u16 {
    // Check if command is proceded by a comment, stop parsing for
    // immed values up to before the start of the comment
    const hasComment = ascii.indexOfIgnoreCase(line, ";");
    const endOfCmd = if (hasComment) |idx| idx else line.len;

    const isHex = ascii.indexOfIgnoreCase(line, "x");
    const isDec = ascii.indexOfIgnoreCase(line, "#");
    if (isHex) |idx| {
        const parsed = try std.fmt.parseInt(i16, line[idx + 1 .. endOfCmd], 16);
        const unsigned: u16 = @bitCast(parsed);
        return unsigned & mask;
    } else if (isDec) |idx| {
        const parsed = try std.fmt.parseInt(i16, line[idx + 1 .. endOfCmd], 10);
        const unsigned: u16 = @bitCast(parsed);
        return unsigned & mask;
    } else {
        return ParseError.InvalidInstruction;
    }
}

test "getImmedValue: #12 immed5" {
    const immed = "#12";
    const value = try getImmedValue(immed, masks.IMMED_5_MASK);
    const expected: u16 = 0b01100;
    try expectEqual(expected, value);
}

test "getImmedValue negative: #-12 immed5" {
    const immed = "#-12";
    const value = try getImmedValue(immed, masks.IMMED_5_MASK);
    const expected: u16 = 0b10100;
    try expectEqual(expected, value);
}

test "getImmedValue hex: xc (#12) immed5" {
    const immed = "xc";
    const value = try getImmedValue(immed, masks.IMMED_5_MASK);
    const expected: u16 = 0b01100;
    try expectEqual(expected, value);
}

test "getImmedValue negative hex: x14 (#-12) immed5" {
    const immed = "x14";
    const value = try getImmedValue(immed, masks.IMMED_5_MASK);
    const expected: u16 = 0b10100;
    try expectEqual(expected, value);
}
