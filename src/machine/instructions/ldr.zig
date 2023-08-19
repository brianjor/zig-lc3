const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// Load Base + offset
/// ___
/// Encoding:
/// ```
/// | 15:12 | 11:9 |  8:6  |   5:0   |
/// |-------|------|-------|---------|
/// |  0110 |  DR  | BaseR | offset6 |
///
/// DR = mem[BaseR + SEXT(offset6)]
/// setCC()
/// ```
pub const Ldr = struct {
    pub fn run(_: Ldr, cpu: *CPU) void {
        const ir = cpu.ir;
        const registers = &(cpu.registers);
        const mem = cpu.memory;

        const dr = (ir & masks.DR_MASK) >> masks.DR_SHIFT;
        const baseR = (ir & masks.SR1_MASK) >> masks.SR1_SHIFT;
        const baseRVal: i16 = @bitCast(registers[baseR]);
        const immed: i16 = @bitCast(sext.SEXT6(ir));
        const memLoc: u16 = @bitCast(baseRVal + immed);
        registers[dr] = mem[memLoc];
        cpu.setCC(registers[dr]);
    }
};

test "LDR sets DR = mem[BaseR + SEXT(offset6)]" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("LDR R3 R4 #3");

    cpu.registers[4] = 0x3000;
    cpu.memory[0x3003] = 0x1234;

    const ldrInstruction = Instruction{ .Ldr = Ldr{} };
    ldrInstruction.run(&cpu);

    const result = cpu.registers[3];
    const expected: u16 = 0x1234;
    try expectEqual(expected, result);
}

test "LDR sets CC" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("LDR R3 R4 #3");

    cpu.registers[4] = 0x3000;
    cpu.memory[0x3003] = 0x1234;

    const ldrInstruction = Instruction{ .Ldr = Ldr{} };
    ldrInstruction.run(&cpu);

    const expected: u16 = 0b0000_0000_0000_0001;
    try expectEqual(expected, cpu.psr & masks.PSR_P_MASK);
}
