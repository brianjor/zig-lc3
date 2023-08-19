pub const hello: [6][]const u8 = [_][]const u8{
    ".ORIG 0x3000",
    "LEA R0, 0x3002",
    "TRAP 0x22",
    "TRAP 0x25",
    ".STRINGZ \"Hello World!\"",
    ".END",
};
