const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// Store Indirect
/// ___
/// Encoding:
/// ```
/// | 15:12 | 11:9 |    8:0    |
/// |-------|------|-----------|
/// |  1011 |  SR  | PCoffset9 |
///
/// mem[mem[PC + SEXT(PCoffset9)]] = SR
/// ```
pub const Sti = struct {
    pub fn run(_: Sti, cpu: *CPU) void {
        const ir = cpu.ir;
        const iPc: i16 = @bitCast(cpu.pc);
        const registers = &cpu.registers;
        const memory = &cpu.memory;

        const sr = (ir & masks.DR_MASK) >> masks.DR_SHIFT;
        const immed: i16 = @bitCast(sext.SEXT9(ir));

        const memLoc: u16 = @bitCast(iPc + immed);
        memory[memory[memLoc]] = registers[sr];
    }
};

test "STI sets memory" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("STI R0 #3");
    cpu.pc = 0x3000;
    cpu.registers[0] = 0x1234;
    cpu.memory[0x3003] = 0x3009;

    const stInstruction = Instruction{ .Sti = Sti{} };
    stInstruction.run(&cpu);

    const expected: u16 = 0x1234;
    try expectEqual(expected, cpu.memory[0x3009]);
}

test "STI sets memory, neg. offset" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("STI R0 #-3");
    cpu.pc = 0x3003;
    cpu.registers[0] = 0x1234;
    cpu.memory[0x3000] = 0x3008;

    const stInstruction = Instruction{ .Sti = Sti{} };
    stInstruction.run(&cpu);

    const expected: u16 = 0x1234;
    try expectEqual(expected, cpu.memory[0x3008]);
}
