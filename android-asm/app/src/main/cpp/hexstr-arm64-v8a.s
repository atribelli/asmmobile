// hexstr-arm64-v8a.s

            .text
            .balign 4

            .global  createHexStr
            .global _createHexStr

//-----------------------------------------------------------------------------
// Convert a value to a hex string.
//
// bool createHexStr(char *buffer, size_t len, uint64_t value);
//
// Arguments:
//     X0    Buffer, 16-byte aligned
//     X1    Buffer size
//     X2    Value
// Return:
//     X0    Bool indicating success

            .balign 16
createHexStr:
_createHexStr:
            cbz     x0, 0f                  // Branch if nullptr
            tst     x0, #0x0f               // Branch if not 16-byte aligned
            bne     0f
            cmp     x1, #17                 // Branch if buffer too small
            blo     0f

            rev     x2, x2                  // Reverse bytes to match string
            mov     v0.d[0], x2

            movi    v2.8b, #0x0f
            ushr    v1.8b, v0.8b, #4        // Set V1 to the HO nibbles
            and     v0.8b, v0.8b, v2.8b     // Set V0 to the LO nibbles

            movi    v2.16b, #'0'
            zip1    v0.16b, v1.16b, v0.16b  // Interleave the HO and LO nibbles

            movi    v1.16b, #'9'
            orr     v0.16b, v0.16b, v2.16b  // Convert binary to ascii

            movi    v2.16b, #'A' - '0' - 10
            cmgt    v1.16b, v0.16b, v1.16b  // Determine A-F bytes

            strb    wzr, [x0, #16]          // Zero termination
            and     v1.16b, v1.16b, v2.16b  // Update bytes that should be A-F
            add     v0.16b, v0.16b, v1.16b

            str     q0, [x0]                // Output the string
            mov     x0, #1                  // Return success
            ret

0:          mov     x0, xzr                 // Return failure
            ret
