const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// Not
/// ___
/// Encoding:
/// ```
/// | 15:12 | 11:9 | 8:6 | 5 |  4:0  |
/// |-------|------|-----|---|-------|
/// |  1001 |  DR  |  SR | 1 | 11111 |
///
/// DR = ~SR
/// setCC()
/// ```
pub const Not = struct {
    pub fn run(_: Not, cpu: *CPU) void {
        const ir = cpu.ir;
        const registers = &(cpu.registers);
        const dr = (ir & masks.DR_MASK) >> masks.DR_SHIFT;
        const sr1 = (ir & masks.SR1_MASK) >> masks.SR1_SHIFT;

        registers[dr] = ~registers[sr1];
        cpu.setCC(registers[dr]);
    }
};

test "NOT sets DR" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("NOT R1 R2");
    cpu.registers[2] = 0b1010_1010_1010_1010;

    const notInstruction = Instruction{ .Not = Not{} };
    notInstruction.run(&cpu);
    const expected: u16 = 0b0101_0101_0101_0101;
    try expectEqual(expected, cpu.registers[1]);
}

test "NOT sets CC" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("NOT R1 R2");
    cpu.registers[2] = 0b0101_0101_0101_0101;

    const notInstruction = Instruction{ .Not = Not{} };
    notInstruction.run(&cpu);
    const expected: u16 = 0b0000_0000_0000_0100;
    try expectEqual(expected, cpu.psr & masks.PSR_N_MASK);
}
