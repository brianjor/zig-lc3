const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// Addition
/// ___
/// Encodings:
/// ```
/// Register mode
/// | 15:12 | 11:9 | 8:6 | 5 | 4:3 | 2:0 |
/// |-------|------|-----|---|-----|-----|
/// |  0001 |  DR  | SR1 | 0 | 00  | SR2 |
///
/// reg[DR] = reg[SR1] + reg[SR2]
/// setCC()
/// ```
/// ___
/// ```
/// Immed mode
/// | 15:12 | 11:9 | 8:6 | 5 |  4:0   |
/// |-------|------|-----|---|--------|
/// |  0001 |  DR  | SR1 | 1 | immed5 |
///
/// reg[DR] = reg[SR1] + SEXT(immed5)
/// setCC()
/// ```
pub const Add = struct {
    pub fn run(_: Add, cpu: *CPU) void {
        const ir = cpu.ir;
        const registers = &(cpu.registers);
        const dr = (ir & masks.DR_MASK) >> masks.DR_SHIFT;
        const sr1 = (ir & masks.SR1_MASK) >> masks.SR1_SHIFT;
        const sr1Val: i16 = @bitCast(registers[sr1]);
        const isImmedMode = (ir & masks.IMMED_MODE_MASK) > 0;
        if (isImmedMode) {
            const immed: i16 = @bitCast(sext.SEXT5(ir));
            registers[dr] = @bitCast(sr1Val + immed);
        } else {
            const sr2 = ir & masks.SR2_MASK;
            const sr2Val: i16 = @bitCast(registers[sr2]);
            registers[dr] = @bitCast(sr1Val + sr2Val);
        }
        cpu.setCC(registers[dr]);
    }
};

test "Add immed mode: SR1(#4) + immed5(#5) = #9" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("ADD R1, R3, #5");

    // Prime R3 with the value 4
    cpu.registers[3] = 4;

    const addInstruction = Instruction{ .Add = Add{} };
    addInstruction.run(&cpu);
    const expected: u16 = 9;
    try expectEqual(expected, cpu.registers[1]);
}

test "Add immed mode: SR1(#4) + immed5(#-1) = #3" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("ADD R1, R2, #-1");

    // Prime R2 with the value 4
    cpu.registers[2] = 4;

    const addInstruction = Instruction{ .Add = Add{} };
    addInstruction.run(&cpu);
    const expected: u16 = 3;
    try expectEqual(expected, cpu.registers[1]);
}

test "Add Register mode: SR1(#3) + SR2(#2) = #5" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("ADD R1, R2, R3");

    // Prime R2 with the value 3
    cpu.registers[2] = 3;

    // Prime R3 with the value 2
    cpu.registers[3] = 2;

    const addInstruction = Instruction{ .Add = Add{} };
    addInstruction.run(&cpu);
    const expected: u16 = 5;
    try expectEqual(expected, cpu.registers[1]);
}

test "Add sets condition code" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("ADD R1, R2, R3");

    // Prime R2 with the value 3
    cpu.registers[2] = 3;

    // Prime R3 with the value 2
    cpu.registers[3] = 2;

    const addInstruction = Instruction{ .Add = Add{} };
    addInstruction.run(&cpu);
    const expected: u16 = 0b0000_0000_0000_0001;
    try expectEqual(expected, cpu.psr & masks.PSR_P_MASK);
}
