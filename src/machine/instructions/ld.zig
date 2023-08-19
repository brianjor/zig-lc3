const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// Load
/// ___
/// Encoding:
/// ```
/// | 15:12 | 11:9 |    8:0    |
/// |-------|------|-----------|
/// |  0010 |  DR  | PCoffset9 |
///
/// DR = mem[PC + SEXT(PCoffset9)]
/// setCC()
/// ```
pub const Ld = struct {
    pub fn run(_: Ld, cpu: *CPU) void {
        const ir = cpu.ir;
        const iPc: i16 = @bitCast(cpu.pc);
        const registers = &(cpu.registers);
        const mem = cpu.memory;

        const dr = (ir & masks.DR_MASK) >> masks.DR_SHIFT;
        const offset: i16 = @bitCast(sext.SEXT9(ir));
        const memLoc: u16 = @bitCast(iPc + offset);
        registers[dr] = mem[memLoc];
        cpu.setCC(registers[dr]);
    }
};

test "LD: Sets destination register" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("LD R3 x4");

    // Init pc
    cpu.pc = 0x3000;

    // Value in memory that will be loaded into R3
    cpu.memory[0x3000 + 0x0004] = 0x1234;

    const ldInstruction = Instruction{ .Ld = Ld{} };
    ldInstruction.run(&cpu);

    const expected: u16 = 0x1234;
    try expectEqual(expected, cpu.registers[3]);
}

test "LD: Sets CC" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("LD R3 x4");

    // Init pc
    cpu.pc = 0x3000;

    // Value in memory that will be loaded into R3
    cpu.memory[0x3000 + 0x0004] = 0x1234;

    const ldInstruction = Instruction{ .Ld = Ld{} };
    ldInstruction.run(&cpu);

    const expected: u16 = 0b0000_0000_0000_0001;
    try expectEqual(expected, cpu.psr & masks.PSR_P_MASK);
}
