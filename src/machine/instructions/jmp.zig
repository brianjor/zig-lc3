const std = @import("std");
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

/// Jump
///
/// The `RET` instruction is a special case `JMP` instruction,
/// where BaseR = `0x111`, or R7
/// ___
/// Encoding:
/// ```
/// JMP
/// | 15:12 | 11:9 |  8:6  |   5:0  |
/// |-------|------|-------|--------|
/// |  1100 | 000  | BaseR | 000000 |
///
/// PC = BaseR
/// ```
pub const Jmp = struct {
    pub fn run(_: Jmp, cpu: *CPU) void {
        const ir = cpu.ir;
        const registers = &(cpu.registers);
        const baseR = (ir & masks.JMP_BASE_R_MASK) >> masks.JMP_BASE_R_SHIFT;
        cpu.pc = registers[baseR];
    }
};

test "JMP R4, Registers[R4] = 25" {
    var cpu = CPU{};
    cpu.ir = try asmParser.parseSingle("JMP R4");

    // Prime R4 with the value 25
    cpu.registers[4] = 25;

    const jmpInstruction = Instruction{ .Jmp = Jmp{} };
    jmpInstruction.run(&cpu);
    const expected: u16 = 25;
    try expectEqual(expected, cpu.pc);
}
