const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// Jump to Subroutine
/// ___
/// Encodings:
/// ```
/// JSR
/// | 15:12 | 11 |    10:0    |
/// |-------|----|------------|
/// |  0100 |  1 | PCoffset11 |
///
/// R7 = PC
/// PC = PC + SEXT(PCoffset11)
/// ```
/// ___
/// ```
/// JSRR
/// | 15:12 | 11 | 10:9 |  8:6  |   5:0  |
/// |-------|----|------|-------|--------|
/// |  0100 |  0 |  00  | BaseR | 000000 |
///
/// R7 = PC
/// PC = BaseR
/// ```
pub const Jsr = struct {
    pub fn run(_: Jsr, cpu: *CPU) void {
        const ir = cpu.ir;
        const pc = &cpu.pc;
        const registers = &(cpu.registers);
        registers[7] = pc.*;

        const isJsr = ((ir & masks.JSR_MODE_MASK) >> masks.JSR_MODE_MASK_SHIFT) == 1;
        if (isJsr) {
            const iPc: i16 = @bitCast(pc.*);
            const immed: i16 = @bitCast(sext.SEXT11(ir));
            pc.* = @bitCast(iPc + immed);
        } else { // JSRR
            const baseR = (ir & masks.JSRR_BASE_R_MASK) >> masks.JSRR_BASE_R_MASK_SHIFT;
            pc.* = registers[baseR];
        }
    }
};

test "JSR sets PC to PC + xf" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("JSR xf");

    // Prime PC
    cpu.pc = 0x3000;

    const jsrInstruction = Instruction{ .Jsr = Jsr{} };
    jsrInstruction.run(&cpu);
    const expected: u16 = 0x300f;
    try expectEqual(expected, cpu.pc);
}

test "JSR sets R7 to PC" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("JSR xf");

    // Prime PC with a value other than 0
    cpu.pc = 0x3000;

    const jsrInstruction = Instruction{ .Jsr = Jsr{} };
    jsrInstruction.run(&cpu);
    const expected: u16 = 0x3000;
    try expectEqual(expected, cpu.registers[7]);
}

test "JSRR sets PC to R4" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("JSRR R4");

    // Prime PC
    cpu.pc = 0x3000;

    // Prime R4 with value 25
    cpu.registers[4] = 25;

    const jsrInstruction = Instruction{ .Jsr = Jsr{} };
    jsrInstruction.run(&cpu);
    const expected: u16 = 25;
    try expectEqual(expected, cpu.pc);
}

test "JSRR sets R7 to PC" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("JSRR R4");

    // Prime PC with a value other than 0
    cpu.pc = 0x3000;

    const jsrInstruction = Instruction{ .Jsr = Jsr{} };
    jsrInstruction.run(&cpu);
    const expected: u16 = 0x3000;
    try expectEqual(expected, cpu.registers[7]);
}
