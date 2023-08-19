const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// Load Effective Address
/// ___
/// Encoding:
/// ```
/// | 15:12 | 11:9 |    8:0    |
/// |-------|------|-----------|
/// |  1110 |  DR  | PCoffset9 |
///
/// DR = PC + SEXT(offset9)
/// setCC()
/// ```
pub const Lea = struct {
    pub fn run(_: Lea, cpu: *CPU) void {
        const ir = cpu.ir;
        const iPc: i16 = @bitCast(cpu.pc);
        const registers = &(cpu.registers);

        const dr = (ir & masks.DR_MASK) >> masks.DR_SHIFT;
        const immed: i16 = @bitCast(sext.SEXT9(ir));

        registers[dr] = @bitCast(iPc + immed);
        cpu.setCC(registers[dr]);
    }
};

test "LEA sets DR" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("LEA R3 #3");
    cpu.pc = 0x3000;

    const leaInstruction = Instruction{ .Lea = Lea{} };
    leaInstruction.run(&cpu);
    const expected: u16 = 0x3003;
    try expectEqual(expected, cpu.registers[3]);
}

test "LEA sets CC" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("LEA R3 #3");
    cpu.pc = 0x3000;

    const leaInstruction = Instruction{ .Lea = Lea{} };
    leaInstruction.run(&cpu);
    const expected: u16 = 0b0000_0000_0000_0001;
    try expectEqual(expected, cpu.psr & masks.PSR_P_MASK);
}
