const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// Store Base+offset
/// ____
/// Encodings:
/// ```
/// | 15:12 | 11:9 |  8:6  |   5:0   |
/// |-------|------|-------|---------|
/// |  0111 |  SR  | BaseR | offset6 |
///
/// mem[reg[BaseR] + SEXT(offset6)] = reg[SR]
/// ```
///
pub const Str = struct {
    pub fn run(_: Str, cpu: *CPU) void {
        const ir = cpu.ir;
        const registers = cpu.registers;
        const memory = &cpu.memory;
        const sr = (ir & masks.DR_MASK) >> masks.DR_SHIFT;
        const baseR = (ir & masks.SR1_MASK) >> masks.SR1_SHIFT;
        const baseRVal: i16 = @bitCast(registers[baseR]);
        const offset: i16 = @bitCast(sext.SEXT6(ir));

        const memLoc: u16 = @bitCast(baseRVal + offset);
        memory[memLoc] = registers[sr];
    }
};

test "STR sets memory" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("STR R0 R1 #3");
    cpu.registers[1] = 0x3000;
    cpu.registers[0] = 0x1234;

    const strInstruction = Instruction{ .Str = Str{} };
    strInstruction.run(&cpu);

    const expected: u16 = 0x1234;
    try expectEqual(expected, cpu.memory[0x3003]);
}
