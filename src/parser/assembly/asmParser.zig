const std = @import("std");
const ascii = std.ascii;
const Allocator = std.mem.Allocator;

const parseAdd = @import("./instructionParsers/addParser.zig").parseAdd;
const parseAnd = @import("./instructionParsers/andParser.zig").parseAnd;
const parseBr = @import("./instructionParsers/brParser.zig").parseBr;
const parseJmp = @import("./instructionParsers/jmpParser.zig").parseJmp;
const parseJsr = @import("./instructionParsers/jrsParser.zig").parseJsr;
const parseLd = @import("./instructionParsers/ldParser.zig").parseLd;
const parseLdi = @import("./instructionParsers/ldiParser.zig").parseLdi;
const parseLdr = @import("./instructionParsers/ldrParser.zig").parseLdr;
const parseLea = @import("./instructionParsers/leaParser.zig").parseLea;
const parseNot = @import("./instructionParsers/notParser.zig").parseNot;
const parseSt = @import("./instructionParsers/stParser.zig").parseSt;
const parseSti = @import("./instructionParsers/stiParser.zig").parseSti;
const parseStr = @import("./instructionParsers/strParser.zig").parseStr;
const parseTrap = @import("./instructionParsers/trapParser.zig").parseTrap;
const parseDirective = @import("./instructionParsers/directiveParser.zig").parseDirective;

const CPU = @import("../../machine/machine.zig").CPU;
const common = @import("../common.zig");

const ParseError = @import("../errors.zig").ParseError;

const COMMENT_CHAR = ';';

// pub fn parseAsm(input: []const u8, cpu: *CPU) !void {
// var file = try std.fs.cwd().openFile(input, .{});
// defer file.close();

// var bufReader = std.io.bufferedReader(file.reader());
// var inStream = bufReader.reader();

// var buf: [1024]u8 = undefined;

// var idx: u16 = 0;
// while (try inStream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (idx += 1) {
//     if (std.mem.eql(u8, line[0..1], ".")) {
//         try parseDirective(line, cpu);
//         if (cpu.pc == 0) {
//             cpu.pc = cpu.orig;
//             break;
//         }
//     } else {
//         cpu.memory[cpu.pc] = try parseSingle(line);
//         cpu.pc += 1;
//     }
// }
// }
pub fn parseAsm(input: [6][]const u8, cpu: *CPU) !void {
    for (input) |line| {
        if (std.mem.eql(u8, line[0..1], ".")) {
            try parseDirective(line, cpu);
            if (cpu.pc == 0) {
                cpu.pc = cpu.orig;
                break;
            }
        } else {
            cpu.memory[cpu.pc] = try parseSingle(line);
            cpu.pc += 1;
        }
    }
}

// test "parseMultiple" {
//     const allocator = std.testing.allocator;
//     var input = [_][]const u8{ "AND R1, R2, R3", "ADD R1, R2, R3" };
//     const res = try parseMultiple(&input, allocator);
//     defer allocator.free(res);

//     const expected = [_]u16{
//         0b0101_001_010_0_00_011, // AND R1, R2, R3
//         0b0001_001_010_0_00_011, // ADD R1, R2, R3
//     };
//     try std.testing.expectEqual(expected, res[0..2].*);
// }

pub fn parseSingle(line: []const u8) !u16 {
    var out: u16 = 0;
    try switch (line[0]) {
        'A' => switch (line[1]) {
            'D' => out = try parseAdd(line),
            'N' => out = try parseAnd(line),
            else => ParseError.InvalidInstruction,
        },
        'B' => out = try parseBr(line),
        'J' => switch (line[1]) {
            'M' => out = try parseJmp(line),
            'S' => out = try parseJsr(line),
            else => ParseError.InvalidInstruction,
        },
        'L' => switch (line[1]) {
            'D' => switch (line[2]) {
                ' ' => out = try parseLd(line),
                'I' => out = try parseLdi(line),
                'R' => out = try parseLdr(line),
                else => ParseError.InvalidInstruction,
            },
            'E' => out = try parseLea(line),
            else => ParseError.InvalidInstruction,
        },
        'N' => out = try parseNot(line),
        'R' => out = try parseJmp(line),
        'S' => switch (line[1]) {
            'T' => switch (line[2]) {
                ' ' => out = try parseSt(line),
                'I' => out = try parseSti(line),
                'R' => out = try parseStr(line),
                else => ParseError.InvalidInstruction,
            },
            else => ParseError.InvalidInstruction,
        },
        'T' => out = try parseTrap(line),
        else => ParseError.InvalidInstruction,
    };

    return out;
}
