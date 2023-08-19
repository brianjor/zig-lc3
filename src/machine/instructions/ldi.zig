const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// Load Indirect
/// ___
/// Encoding:
/// ```
/// | 15:12 | 11:9 |    8:0    |
/// |-------|------|-----------|
/// |  1010 |  DR  | PCoffset9 |
///
/// DR = mem[mem[PC + SEXT(PCoffset9)]]
/// setCC()
/// ```
pub const Ldi = struct {
    pub fn run(_: Ldi, cpu: *CPU) void {
        const ir = cpu.ir;
        const iPc: i16 = @bitCast(cpu.pc);
        const registers = &(cpu.registers);
        const mem = cpu.memory;

        const dr = (ir & masks.DR_MASK) >> masks.DR_SHIFT;
        const offset: i16 = @bitCast(sext.SEXT9(ir));
        const memLoc: u16 = @bitCast(iPc + offset);
        registers[dr] = mem[mem[memLoc]];
        cpu.setCC(registers[dr]);
    }
};

test "LDI sets DR" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("LDI R4 #3");

    cpu.pc = 0x3000;
    cpu.memory[0x3003] = 0x3006;
    cpu.memory[0x3006] = 0x1234;

    const ldiInstruction = Instruction{ .Ldi = Ldi{} };
    ldiInstruction.run(&cpu);
    const expected: u16 = 0x1234;
    try expectEqual(expected, cpu.registers[4]);
}

test "LDI sets CC" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("LDI R4 #3");

    cpu.pc = 0x3000;
    cpu.memory[0x3003] = 0x3006;
    cpu.memory[0x3006] = 0x1234;

    const ldiInstruction = Instruction{ .Ldi = Ldi{} };
    ldiInstruction.run(&cpu);
    const expected: u16 = 0b0000_0000_0000_0001;
    try expectEqual(expected, cpu.psr & masks.PSR_P_MASK);
}
