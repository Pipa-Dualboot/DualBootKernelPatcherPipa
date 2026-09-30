.include "DummyHead.S"

// Orientation-triggered variant of ShellCode.Pipa.bin
// TRIGGER = ASCII digit of androidboot.ori=0X that should boot UEFI (set to '3' to boot when tablet is in inverted landscape mode).
.equ    TRIGGER_HI, 0x30
.equ    TRIGGER_LO, 0x33

_ShellCodeStart:
    // x0 = DTB pointer (keep x0-x3 untouched for the Android path)
    mov     x7, x0
    ldr     w8, [x0, #4]            // fdt totalsize (big-endian)
    rev     w8, w8
    add     x8, x0, w8, uxtw        // end of DTB
    sub     x8, x8, #17             // scan while x7 < end-17 (last valid start = end-18)
    adr     x9, _Pattern

_Scan:
    cmp     x7, x8
    b.hs    _Linux                  // not found -> boot Android (safe default)
    mov     x10, #0

_Compare:
    ldrb    w11, [x7, x10]          // byte loads only (MMU off = no unaligned access)
    ldrb    w12, [x9, x10]
    cmp     w11, w12
    b.ne    _Next
    add     x10, x10, #1
    cmp     x10, #16
    b.ne    _Compare
    ldrb    w11, [x7, #16]          // first digit of the value (0X)
    cmp     w11, #TRIGGER_HI
    b.ne    _Linux
    ldrb    w11, [x7, #17]          // second digit of the value (0X)
    cmp     w11, #TRIGGER_LO
    b.eq    _UEFI
    b       _Linux

_Next:
    add     x7, x7, #1
    b       _Scan

_Pattern:
    .ascii  "androidboot.ori="
    .p2align 2

.include "CommonTail.S"
/* Do not remove the last line  */
