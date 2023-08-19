const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const ArrayList = std.ArrayList;

const masks = @import("./masks.zig");

pub const CPU = struct {
    const Self = @This();

    // outBuffer: ArrayList(u8) = ArrayList(u8).init(std.heap.page_allocator),
    orig: u16 = 0x3000,

    isRunning: bool = false,

    /// Program Counter.
    /// Contains address of next instruction to be executed.
    pc: u16 = 0x3000,

    /// Instruction Register.
    /// Contains the current instruction being executed.
    ir: u16 = 0,

    /// General purpose registers, 0-7
    registers: [8]u16 = [_]u16{0} ** 8,

    /// Program memory
    memory: [0xFFFF]u16 = [_]u16{0} ** 0xFFFF,

    /// Memory Address Register.
    /// Holds address of current instruction.
    mar: u16 = 0,

    /// Memory Data Register.
    /// Holds contents of memory[mar].
    mdr: u16 = 0,

    /// Processor status register \
    /// [15]: Privilege mode \
    /// [10:8]: Priority level of currently running process \
    /// [2:0]: Condition Codes; [2]: N, [1]: Z, [0]: p
    psr: u16 = 0,

    pub fn setCC(self: *Self, value: u16) void {
        self.psr &= masks.CLEAR_CC;

        // Check if the sign bit [16] == 1
        const isNeg = (value & masks.BIT_16_MASK) == masks.BIT_16_MASK;
        if (isNeg) {
            self.psr |= masks.PSR_N_MASK;
        } else if (value == 0) {
            self.psr |= masks.PSR_Z_MASK;
        } else { // positive
            self.psr |= masks.PSR_P_MASK;
        }
    }
};

test "setCC: Negative" {
    var cc = CPU{};
    cc.setCC(0b1000_0000_0000_0000);
    const expected: u16 = 0b0000_0000_0000_0100;
    try expectEqual(expected, cc.psr & masks.PSR_N_MASK);
}

test "setCC: Zero" {
    var cc = CPU{};
    cc.setCC(0);
    const expected: u16 = 0b0000_0000_0000_0010;
    try expectEqual(expected, cc.psr & masks.PSR_Z_MASK);
}

test "setCC: Positive" {
    var cc = CPU{};
    cc.setCC(1);
    const expected: u16 = 0b0000_0000_0000_0001;
    try expectEqual(expected, cc.psr & masks.PSR_P_MASK);
}

// pub const ConditionCodes = struct {
//     const Self = @This();

//     n: u1 = 0,
//     z: u1 = 0,
//     p: u1 = 0,

//     /// Sets the condition codes based on the value of the sign bit or if value is zero
//     pub fn setCC(self: *Self, value: u16) void {
//         // Check if the sign bit [16] == 1
//         const isNeg = (value & masks.BIT_16_MASK) == masks.BIT_16_MASK;
//         if (isNeg) {
//             self.n = 1;
//             self.z = 0;
//             self.p = 0;
//         } else if (value == 0) {
//             self.n = 0;
//             self.z = 1;
//             self.p = 0;
//         } else { // positive
//             self.n = 0;
//             self.z = 0;
//             self.p = 1;
//         }
//     }
// };

// test "setCC: Positive" {
//     var cc = ConditionCodes{};
//     cc.setCC(1);
//     const n: u16 = 0;
//     const z: u16 = 0;
//     const p: u16 = 1;
//     try expectEqual(n, cc.n);
//     try expectEqual(z, cc.z);
//     try expectEqual(p, cc.p);
// }

// test "setCC: Negative" {
//     var cc = ConditionCodes{};
//     cc.setCC(0b1000000000000000);
//     const n: u16 = 1;
//     const z: u16 = 0;
//     const p: u16 = 0;
//     try expectEqual(n, cc.n);
//     try expectEqual(z, cc.z);
//     try expectEqual(p, cc.p);
// }

// test "setCC: Zero" {
//     var cc = ConditionCodes{};
//     cc.setCC(0);
//     const n: u16 = 0;
//     const z: u16 = 1;
//     const p: u16 = 0;
//     try expectEqual(n, cc.n);
//     try expectEqual(z, cc.z);
//     try expectEqual(p, cc.p);
// }

// pub const ProcessingUnit = struct {
//     registers: [8]u16 = [_]u16{0} ** 8,
// };

// pub const ControlUnit = struct {
//     /// Program Counter.
//     /// Contains address of next instruction to be executed.
//     pc: u16 = 0x3000,
//     /// Instruction Register.
//     /// Contains the current instruction being executed.
//     ir: u16 = 0,
// };

// /// Memory module.
// /// Provides an interface to load data from memory.
// pub const Memory = struct {
//     const Self = @This();

//     /// Program memory
//     memory: [0xFFFF]u16 = [_]u16{0} ** 0xFFFF,
//     /// Memory Address Register.
//     /// Holds address of current instruction.
//     mar: u16 = 0,
//     /// Memory Data Register.
//     /// Holds contents of memory[mar].
//     mdr: u16 = 0,
// };

// /// Arethmetic and Logic Unit.
// pub const ALU = struct {
//     const Self = @This();

//     /// Register that holds the first input
//     input1: u16 = 0,
//     /// Register that holds the second input
//     input2: u16 = 0,
//     /// Register that holds the result of the last operation
//     result: u16 = 0,

//     /// Adds the inputs and stores the result in the result register
//     pub fn Add(self: *Self) void {
//         self.result = self.input1 + self.input2;
//     }

//     /// Ands the inputs and stores the result in the result register
//     pub fn And(self: *Self) void {
//         self.result = self.input1 & self.input2;
//     }

//     /// Ors the inputs and stores the result in the result register
//     pub fn Or(self: *Self) void {
//         self.result = self.input1 | self.input2;
//     }

//     /// Nots the input1 and stores the result in the result register
//     pub fn Not(self: *Self) void {
//         self.result = ~self.input1;
//     }
// };

// test "ALU add" {
//     var testAlu: ALU = ALU{ .input1 = 2, .input2 = 3 };
//     testAlu.Add();
//     const expected: u16 = 0x0005;
//     try expectEqual(expected, testAlu.result);
// }
// test "ALU and" {
//     var testAlu: ALU = ALU{ .input1 = 2, .input2 = 3 };
//     testAlu.And();
//     const expected: u16 = 0x0002;
//     try expectEqual(expected, testAlu.result);
// }
// test "ALU or" {
//     var testAlu: ALU = ALU{ .input1 = 2, .input2 = 3 };
//     testAlu.Or();
//     const expected: u16 = 0x0003;
//     try expectEqual(expected, testAlu.result);
// }
// test "ALU not" {
//     var testAlu: ALU = ALU{ .input1 = 2 };
//     testAlu.Not();
//     const expected: u16 = 0xFFFD;
//     try expectEqual(expected, testAlu.result);
// }
