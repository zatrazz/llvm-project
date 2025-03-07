# REQUIRES: aarch64

## Check if GNU_PROPERTY_MEMORY_SEAL is present when extra gnu attributes
## are present.

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu %s -o %t.o
# RUN: ld.lld -shared %t.o -z memory-seal -o %t.so
# RUN: llvm-readobj --sections --program-headers %t.so | FileCheck %s

# CHECK:      Name: .note.gnu.property
# CHECK-NEXT: Type: SHT_NOTE (0x7)
# CHECK-NEXT: Flags [ (0x2)
# CHECK-NEXT:   SHF_ALLOC (0x2)
# CHECK-NEXT: ]
# CHECK-NEXT: Address: 0x238
# CHECK-NEXT: Offset: 0x238
# CHECK-NEXT: Size: 40
# CHECK-NEXT: Link: 0
# CHECK-NEXT: Info: 0
# CHECK-NEXT: AddressAlignment: 8
# CHECK-NEXT: EntrySize: 0

.section ".note.gnu.property", "a"
.p2align 3
.long 1f - 0f           // name length
.long 3f - 2f           // data length
.long 5                 // note type
0:
.asciz "GNU"            // vendor name
1:
.p2align 3
2:
.long 0xc0000000        // pr_type - GNU_PROPERTY_AARCH64_FEATURE_1_AND
.long 4                 // pr_datasz
.long 1                 // GNU_PROPERTY_AARCH64_FEATURE_1_BTI
.long 0
3:
