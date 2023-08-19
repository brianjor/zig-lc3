const std = @import("std");
const eql = std.mem.eql;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

const CPU = @import("../machine.zig").CPU;
const sext = @import("../sext.zig");
const masks = @import("../masks.zig");
const asmParser = @import("../../parser/assembly/asmParser.zig");
const Instruction = @import("./instruction.zig").Instruction;

const TrapError = error{
    InvalidVect,
};

/// Trap
/// ___
/// Encoding:
/// ```
/// | 15:12 | 11:8 |    7:0    |
/// |-------|------|-----------|
/// |  1111 | 0000 | trapvect8 |
/// ```
/// trapvect8 determines which service routine to run
/// - 0x20: GETC - Read a single character from the keyboard. It is not echoed to the console. Copied into R0.
/// - 0x21: OUT - Write a character from the value R0[7:0] to the console.
/// - 0x22: PUTS - Write string of characters to console. Start of string specified by address in R0. Writing terminates when data at memory is x0000.
/// - 0x25: HALT - Halt execution.
pub const Trap = struct {
    pub fn run(_: Trap, cpu: *CPU) void {
        const ir = cpu.ir;

        const vect = ir & masks.TRAP_VECT_MASK;

        switch (vect) {
            0x25 => handleHalt(cpu),
            0x24 => handlePutsP(cpu),
            0x23 => handleIn(cpu),
            0x22 => handlePuts(cpu),
            0x21 => handleOut(cpu),
            0x20 => handleGetc(cpu),
            else => unreachable,
        }
    }

    fn handleHalt(cpu: *CPU) void {
        cpu.isRunning = false;
    }

    test "TRAP: Halt" {
        var cpu = CPU{ .isRunning = true };
        cpu.ir = try asmParser.parseSingle("TRAP x25");

        const trapInstruction = Instruction{ .Trap = Trap{} };
        trapInstruction.run(&cpu);
        try expectEqual(false, cpu.isRunning);
    }

    fn handlePutsP(cpu: *CPU) void {
        var memLoc = cpu.registers[0];
        while (cpu.memory[memLoc] != 0x0000) {
            const firstChar: u8 = @truncate(cpu.memory[memLoc]);
            const secondChar: u8 = @truncate(cpu.memory[memLoc] >> 8);
            std.debug.print("{}", .{firstChar});
            if (secondChar == 0x00) {
                break;
            }
            std.debug.print("{}", .{secondChar});
            memLoc += 1;
        }
    }

    // test "TRAP PutsP" {
    //     var cpu = CPU{};
    //     cpu.ir = try asmParser.parseSingle("TRAP x24");
    //     cpu.registers[0] = 0x3000;

    //     cpu.memory[0x3000] = 0x6548; // 'E' 'H'
    //     cpu.memory[0x3001] = 0x6c6c; // 'l' 'l'
    //     cpu.memory[0x3002] = 0x006f; // '\0' 'o'
    //     const trapInstruction = Instruction{ .Trap = Trap{} };
    //     trapInstruction.run(&cpu);

    //     try expect(eql(u8, "Hello", cpu.outBuffer.items));
    // }

    fn handleIn(cpu: *CPU) void {
        handleGetc(cpu);
        handleOut(cpu);
    }
    fn handleOut(cpu: *CPU) void {
        const char: u8 = @truncate(cpu.registers[0]);
        std.debug.print("{}", .{char});
    }

    fn handleGetc(cpu: *CPU) void {
        var reader = std.io.getStdIn().reader();
        var buffer: [1]u8 = [1]u8{0};
        while (buffer[0] == 0) {
            _ = reader.readAtLeast(&buffer, 1) catch continue;
        }
        cpu.registers[0] = buffer[0];
        cpu.registers[0] = cpu.registers[0] & 0x00FF;
    }

    // test "handleGetc" {
    //     var cpu = CPU{};
    //     cpu.ir = try asmParser.parseSingle("TRAP x20");

    //     const trapInstruction = Instruction{ .Trap = Trap{} };
    //     trapInstruction.run(&cpu);
    //     const expected: u16 = 0x0061;
    //     try expectEqual(expected, cpu.registers[0]);
    // }

    fn handlePuts(cpu: *CPU) void {
        var memLoc = cpu.registers[0];
        while (cpu.memory[memLoc] != 0x0000) {
            const firstChar: u8 = @truncate(cpu.memory[memLoc]);
            std.debug.print("{u}", .{firstChar});
            memLoc += 1;
        }
    }
};
