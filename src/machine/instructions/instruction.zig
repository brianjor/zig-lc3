const std = @import("std");
const CPU = @import("../machine.zig").CPU;
const masks = @import("../masks.zig");
const opCodes = @import("../opCodes.zig");

const Add = @import("./add.zig").Add;
const And = @import("./and.zig").And;
const Br = @import("./br.zig").Br;
const Jmp = @import("./jmp.zig").Jmp;
const Jsr = @import("./jsr.zig").Jsr;
const Ld = @import("./ld.zig").Ld;
const Ldi = @import("./ldi.zig").Ldi;
const Ldr = @import("./ldr.zig").Ldr;
const Lea = @import("./lea.zig").Lea;
const Not = @import("./not.zig").Not;
const St = @import("./store.zig").St;
const Sti = @import("./sti.zig").Sti;
const Str = @import("./str.zig").Str;
const Trap = @import("./trap.zig").Trap;

const expectEqual = std.testing.expectEqual;
const expectError = std.testing.expectError;

pub const InstructionError = error{
    Unused,
    NotImplemented,
};

pub const Instruction = union(enum) {
    Add: Add,
    And: And,
    Br: Br,
    Jmp: Jmp,
    Jsr: Jsr,
    Ld: Ld,
    Ldi: Ldi,
    Ldr: Ldr,
    Lea: Lea,
    Not: Not,
    St: St,
    Sti: Sti,
    Str: Str,
    Trap: Trap,

    /// Run the instruction
    pub fn run(self: Instruction, cpu: *CPU) void {
        switch (self) {
            inline else => |instruction| instruction.run(cpu),
        }
    }
};

pub fn decodeInstruction(ir: u16) !Instruction {
    const opCode: u4 = @truncate((ir & masks.OP_CODE_MASK) >> masks.OP_CODE_SHIFT);
    switch (opCode) {
        opCodes.ADD => return Instruction{ .Add = Add{} },
        opCodes.AND => return Instruction{ .And = And{} },
        opCodes.BR => return Instruction{ .Br = Br{} },
        opCodes.JMP => return Instruction{ .Jmp = Jmp{} },
        opCodes.JSR => return Instruction{ .Jsr = Jsr{} },
        opCodes.LD => return Instruction{ .Ld = Ld{} },
        opCodes.LDI => return Instruction{ .Ldi = Ldi{} },
        opCodes.LDR => return Instruction{ .Ldr = Ldr{} },
        opCodes.LEA => return Instruction{ .Lea = Lea{} },
        opCodes.NOT => return Instruction{ .Not = Not{} },
        opCodes.RTI => return InstructionError.NotImplemented, // Only used by interupts
        opCodes.ST => return Instruction{ .St = St{} },
        opCodes.STI => return Instruction{ .Sti = Sti{} },
        opCodes.STR => return Instruction{ .Str = Str{} },
        opCodes.TRAP => return Instruction{ .Trap = Trap{} },
        opCodes.UNUSED => return InstructionError.Unused,
    }
}

test "decodeInstruction: Decode Add" {
    const instruction: u16 = 0b0001_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Add = Add{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode And" {
    const instruction: u16 = 0b0101_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .And = And{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Br" {
    const instruction: u16 = 0b0000_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Br = Br{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Jmp" {
    const instruction: u16 = 0b1100_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Jmp = Jmp{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Jsr" {
    const instruction: u16 = 0b0100_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Jsr = Jsr{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Ld" {
    const instruction: u16 = 0b0010_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Ld = Ld{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Ldi" {
    const instruction: u16 = 0b1010_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Ldi = Ldi{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Ldr" {
    const instruction: u16 = 0b0110_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Ldr = Ldr{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Lea" {
    const instruction: u16 = 0b1110_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Lea = Lea{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Not" {
    const instruction: u16 = 0b1001_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Not = Not{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Rti" {
    const instruction: u16 = 0b1000_0000_0000_0000;
    const decoded = decodeInstruction(instruction);
    try expectError(InstructionError.NotImplemented, decoded);
}

test "decodeInstruction: Decode St" {
    const instruction: u16 = 0b0011_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .St = St{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Sti" {
    const instruction: u16 = 0b1011_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Sti = Sti{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Str" {
    const instruction: u16 = 0b0111_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Str = Str{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Trap" {
    const instruction: u16 = 0b1111_0000_0000_0000;
    const decoded = try decodeInstruction(instruction);
    const expected = Instruction{ .Trap = Trap{} };
    try expectEqual(expected, decoded);
}

test "decodeInstruction: Decode Unused" {
    const instruction: u16 = 0b1101_0000_0000_0000;
    const decoded = decodeInstruction(instruction);
    try expectError(InstructionError.Unused, decoded);
}
