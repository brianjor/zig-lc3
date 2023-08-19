const masks = @import("masks.zig");

const SIGN_EXTEND_5 = 0b1111_1111_1110_0000;
const SIGN_EXTEND_6 = 0b1111_1111_1100_0000;
const SIGN_EXTEND_9 = 0b1111_1110_0000_0000;
const SIGN_EXTEND_11 = 0b1111_1000_0000_0000;

fn sext(value: u16, mask: u16, shift: u4, extension: u16) u16 {
    // Set unmasked bits to 0
    const masked: u16 = value & mask;

    var extendedVal = masked;
    // Check if sign bit is 1
    if (masked >> shift == 1) {
        // Spread the sign bit using the extension
        extendedVal = masked | extension;
    }
    return extendedVal;
}

/// Extends value of bit [5] over bits [15:6]
pub fn SEXT5(value: u16) u16 {
    return sext(value, masks.IMMED_5_MASK, masks.IMMED_5_SIGN_SHIFT, SIGN_EXTEND_5);
}

/// Extends value of bit [6] over bits [15:7]
pub fn SEXT6(value: u16) u16 {
    return sext(value, masks.IMMED_6_MASK, masks.IMMED_6_SIGN_SHIFT, SIGN_EXTEND_6);
}

/// Extends value of bit [9] over bits [15:10]
pub fn SEXT9(value: u16) u16 {
    return sext(value, masks.IMMED_9_MASK, masks.IMMED_9_SIGN_SHIFT, SIGN_EXTEND_9);
}

/// Extends value of bit [11] over bits [15:12]
pub fn SEXT11(value: u16) u16 {
    return sext(value, masks.IMMED_11_MASK, masks.IMMED_11_SIGN_SHIFT, SIGN_EXTEND_11);
}
