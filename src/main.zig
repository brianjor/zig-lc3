const std = @import("std");
const CPU = @import("./machine/machine.zig").CPU;
const Instruction = @import("./machine/instructions/instruction.zig");
const parseAsm = @import("./parser/assembly/asmParser.zig").parseAsm;

const hello = @import("./assembly/hello.asm.zig").hello;

pub fn main() !void {
    var cpu = CPU{ .isRunning = true };
    try parseAsm(hello, &cpu);

    while (cpu.isRunning) {
        //
        // Stages
        //
        // Fetch
        fetch(&cpu);

        // Decode
        const instruction: Instruction.Instruction = try decode(&cpu);

        // Run
        instruction.run(&cpu);
    }
}

fn fetch(cpu: *CPU) void {
    cpu.ir = cpu.memory[cpu.pc];
    cpu.pc += 1;
}

fn decode(cpu: *CPU) !Instruction.Instruction {
    return Instruction.decodeInstruction(cpu.ir);
}
