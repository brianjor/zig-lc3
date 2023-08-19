const std = @import("std");
const ascii = std.ascii;

const CPU = @import("../../../machine/machine.zig").CPU;
const common = @import("../../common.zig");

pub fn parseDirective(line: []const u8, cpu: *CPU) !void {
    if (ascii.startsWithIgnoreCase(line, ".ORIG")) {
        cpu.orig = try common.getImmedValue(line, 0xffff);
        cpu.pc = cpu.orig;
    } else if (ascii.startsWithIgnoreCase(line, ".END")) {
        cpu.pc = 0;
    } else if (ascii.startsWithIgnoreCase(line, ".BLKW")) {
        const numWords: u16 = try common.getImmedValue(line, 0xffff);
        cpu.pc += numWords;
        cpu.pc += 1;
    } else if (ascii.startsWithIgnoreCase(line, ".FILL")) {
        const fillVal: u16 = try common.getImmedValue(line, 0xffff);
        cpu.memory[cpu.pc] = fillVal;
        cpu.pc += 1;
    } else if (ascii.startsWithIgnoreCase(line, ".STRINGZ")) {
        const startOfMessage = ascii.indexOfIgnoreCase(line, "\"");
        const endOfMessage = ascii.indexOfIgnoreCasePos(line, startOfMessage.? + 1, "\"");
        const message: []const u8 = line[startOfMessage.? + 1 .. endOfMessage.?];
        for (message) |char| {
            cpu.memory[cpu.pc] = char;
            cpu.pc += 1;
        }
        // null terminator
        cpu.pc += 1;
    }
}
