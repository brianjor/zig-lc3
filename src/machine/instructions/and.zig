const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// And
/// ___
/// Encodings: \
/// Register mode
/// ```
/// | 15:12 | 11:9 | 8:6 | 5 | 4:3 | 2:0 |
/// |-------|------|-----|---|-----|-----|
/// |  0101 |  DR  | SR1 | 0 | 00  | SR2 |
///
/// DR = reg[SR1] & reg[SR2]
/// setCC()
/// ```
/// ___
///
/// Immed mode
/// ```
/// | 15:12 | 11:9 | 8:6 | 5 |  4:0   |
/// |-------|------|-----|---|--------|
/// |  0101 |  DR  | SR1 | 1 | immed5 |
///
/// DR = reg[SR1] & SEXT(immed5)
/// setCC()
/// ```
pub const And = struct {
    pub fn run(_: And, cpu: *CPU) void {
        const ir = cpu.ir;
        const registers = &(cpu.registers);
        const dr = (ir & masks.DR_MASK) >> masks.DR_SHIFT;
        const sr1 = (ir & masks.SR1_MASK) >> masks.SR1_SHIFT;
        const isImmedMode = (ir & masks.IMMED_MODE_MASK) > 0;
        if (isImmedMode) {
            const immed = sext.SEXT5(ir);
            registers[dr] = registers[sr1] & immed;
        } else {
            const sr2 = (ir & masks.SR2_MASK);
            registers[dr] = registers[sr1] & registers[sr2];
        }
        cpu.setCC(registers[dr]);
    }
};

test "And immed mode: SR1(0x0100) + immed5(#1) = 0b0000" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("AND R1, R3, #1");
    // Prime R2 with the value 4
    cpu.registers[2] = 0b0100;

    const addInstruction = Instruction{ .And = And{} };
    addInstruction.run(&cpu);
    const expected: u16 = 0b0000;
    try expectEqual(expected, cpu.registers[1]);
}

test "And Register mode: SR1(0b0011) + SR2(0b0010) = 0b0010" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("AND R1, R2, R3");
    // Prime R2 with the value 3
    cpu.registers[2] = 0b0011;
    // Prime R3 with the value 2
    cpu.registers[3] = 0b0010;

    const addInstruction = Instruction{ .And = And{} };
    addInstruction.run(&cpu);
    const expected: u16 = 0b0010;
    try expectEqual(expected, cpu.registers[1]);
}

test "And sets condition code" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("AND R1, R2, R3");
    // Prime R2 with the value 3
    cpu.registers[2] = 0b0011;
    // Prime R3 with the value 2
    cpu.registers[3] = 0b0010;

    const addInstruction = Instruction{ .And = And{} };
    addInstruction.run(&cpu);
    const expected: u16 = 0b0000_0000_0000_0001;
    try expectEqual(expected, cpu.psr & masks.PSR_P_MASK);
}
