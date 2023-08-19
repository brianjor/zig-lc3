const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParsers = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// Conditional Branch
/// ___
/// Encoding:
/// ```
/// | 15:12 | 11 | 10 | 9 |    8:0    |
/// |-------|----|----|---|-----------|
/// |  0000 | n  | z  | p | PCoffset9 |
/// If any match:
/// - n == 1 and PSR[n] == 1
/// - z == 1 and PSR[z] == 1
/// - p == 1 and PSR[p] == 1
/// then: PC = PC + SEXT(PCoffset9)
/// ```
pub const Br = struct {
    pub fn run(_: Br, cpu: *CPU) void {
        const ir = cpu.ir;
        const pc = &cpu.pc;
        const n: bool = ((ir & masks.BRN_MASK) == masks.BRN_MASK) and ((cpu.psr & masks.PSR_N_MASK) == masks.PSR_N_MASK);
        const z: bool = ((ir & masks.BRZ_MASK) == masks.BRZ_MASK) and ((cpu.psr & masks.PSR_Z_MASK) == masks.PSR_Z_MASK);
        const p: bool = ((ir & masks.BRP_MASK) == masks.BRP_MASK) and ((cpu.psr & masks.PSR_P_MASK) == masks.PSR_P_MASK);
        if (n or z or p) {
            const iPc: i16 = @bitCast(pc.*);
            const offset: i16 = @bitCast(sext.SEXT9(ir));
            pc.* = @bitCast(iPc + offset);
        }
    }
};

test "BRn #5, with CC[n] = 1" {
    var cpu = CPU{};
    cpu.ir = try asmParsers.parseSingle("BRn #5");
    cpu.pc = 0x3000;
    cpu.setCC(0b1000_0000_0000_0000);

    const brInstruction = Instruction{ .Br = Br{} };
    brInstruction.run(&cpu);

    const expected: u16 = 0x3005;
    try expectEqual(expected, cpu.pc);
}

test "BRz #5, with CC[z] = 1" {
    var cpu = CPU{};
    cpu.ir = try asmParsers.parseSingle("BRz #5");
    cpu.pc = 0x3000;
    cpu.setCC(0);

    const brInstruction = Instruction{ .Br = Br{} };
    brInstruction.run(&cpu);

    const expected: u16 = 0x3005;
    try expectEqual(expected, cpu.pc);
}

test "BRp #5, with CC[p] = 1" {
    var cpu = CPU{};
    cpu.ir = try asmParsers.parseSingle("BRp #5");
    cpu.pc = 0x3000;
    cpu.setCC(1);

    const brInstruction = Instruction{ .Br = Br{} };
    brInstruction.run(&cpu);

    const expected: u16 = 0x3005;
    try expectEqual(expected, cpu.pc);
}
