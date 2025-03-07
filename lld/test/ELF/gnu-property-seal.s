# REQUIRES: aarch64

## Check if a GNU_PROPERTY_MEMORY_SEAL is not replicated without the
## -z directive.

# RUN: split-file %s %t

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu %t/property.s -o %property.o
# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu %t/empty.s -o %empty.o

# RUN: ld.lld %property.o -o %t/exec1
# RUN: llvm-readobj --sections --program-headers %t/exec1 | FileCheck %s --check-prefix=TEST1
# TEST1-NOT: Name: .note.gnu.property

# RUN: ld.lld %property.o %empty.o -o %t/exec2
# RUN: llvm-readobj --sections --program-headers %t/exec2 | FileCheck %s --check-prefix=TEST2
# TEST2-NOT: Name: .note.gnu.property

# RUN: ld.lld -shared %property.o -o %t/dyn1
# RUN: llvm-readobj --sections --program-headers %t/dyn1 | FileCheck %s --check-prefix=TEST3
# TEST3-NOT: Name: .note.gnu.property

# RUN: ld.lld -shared %property.o %empty.o -o %t/dyn2
# RUN: llvm-readobj --sections --program-headers %t/dyn2 | FileCheck %s --check-prefix=TEST4
# TEST4-NOT: Name: .note.gnu.property


## Check if GNU_PROPERTY_MEMORY_SEAL is created when the -z directive is used

# RUN: ld.lld %empty.o -e 4096 -z memory-seal -o %t/exec3
# RUN: llvm-readobj --sections --program-headers %t/exec3 | FileCheck %s --check-prefix=TEST5
# TEST5:      Name: .note.gnu.property
# TEST5-NEXT: Type: SHT_NOTE (0x7)
# TEST5-NEXT: Flags [ (0x2)
# TEST5-NEXT:   SHF_ALLOC (0x2)
# TEST5-NEXT: ]
# TEST5-NEXT: Address: 0x200190
# TEST5-NEXT: Offset: 0x190
# TEST5-NEXT: Size: 24
# TEST5-NEXT: Link: 0
# TEST5-NEXT: Info: 0
# TEST5-NEXT: AddressAlignment: 8
# TEST5-NEXT: EntrySize: 0

# TEST5:      Type: PT_GNU_PROPERTY (0x6474E553)
# TEST5-NEXT: Offset: 0x190
# TEST5-NEXT: VirtualAddress: 0x200190
# TEST5-NEXT: PhysicalAddress: 0x200190
# TEST5-NEXT: FileSize: 24
# TEST5-NEXT: MemSize: 24
# TEST5-NEXT: Flags [ (0x4)
# TEST5-NEXT:   PF_R (0x4)
# TEST5-NEXT: ]
# TEST5-NEXT: Alignment: 8

# RUN: ld.lld %empty.o %property.o -z memory-seal -o %t/exec4
# RUN: llvm-readobj --sections --program-headers %t/exec4 | FileCheck %s --check-prefix=TEST6
# TEST6:      Name: .note.gnu.property
# TEST6-NEXT: Type: SHT_NOTE (0x7)
# TEST6-NEXT: Flags [ (0x2)
# TEST6-NEXT:   SHF_ALLOC (0x2)
# TEST6-NEXT: ]
# TEST6-NEXT: Address: 0x200190
# TEST6-NEXT: Offset: 0x190
# TEST6-NEXT: Size: 24
# TEST6-NEXT: Link: 0
# TEST6-NEXT: Info: 0
# TEST6-NEXT: AddressAlignment: 8
# TEST6-NEXT: EntrySize: 0

# TEST6:      Type: PT_GNU_PROPERTY (0x6474E553)
# TEST6-NEXT: Offset: 0x190
# TEST6-NEXT: VirtualAddress: 0x200190
# TEST6-NEXT: PhysicalAddress: 0x200190
# TEST6-NEXT: FileSize: 24
# TEST6-NEXT: MemSize: 24
# TEST6-NEXT: Flags [ (0x4)
# TEST6-NEXT:   PF_R (0x4)
# TEST6-NEXT: ]
# TEST6-NEXT: Alignment: 8

# RUN: ld.lld -shared %empty.o -z memory-seal -o %t/dyn3
# RUN: llvm-readobj --sections --program-headers %t/dyn3 | FileCheck %s --check-prefix=TEST7
# TEST7:      Name: .note.gnu.property
# TEST7-NEXT: Type: SHT_NOTE (0x7)
# TEST7-NEXT: Flags [ (0x2)
# TEST7-NEXT:   SHF_ALLOC (0x2)
# TEST7-NEXT: ]
# TEST7-NEXT: Address: 0x238
# TEST7-NEXT: Offset: 0x238
# TEST7-NEXT: Size: 24
# TEST7-NEXT: Link: 0
# TEST7-NEXT: Info: 0
# TEST7-NEXT: AddressAlignment: 8
# TEST7-NEXT: EntrySize: 0

# TEST7:      Type: PT_GNU_PROPERTY (0x6474E553)
# TEST7-NEXT: Offset: 0x238
# TEST7-NEXT: VirtualAddress: 0x238
# TEST7-NEXT: PhysicalAddress: 0x238
# TEST7-NEXT: FileSize: 24
# TEST7-NEXT: MemSize: 24
# TEST7-NEXT: Flags [ (0x4)
# TEST7-NEXT:   PF_R (0x4)
# TEST7-NEXT: ]
# TEST7-NEXT: Alignment: 8

# RUN: ld.lld -shared %empty.o %property.o -z memory-seal -o %t/dyn3
# RUN: llvm-readobj --sections --program-headers %t/dyn3 | FileCheck %s --check-prefix=TEST8
# TEST8:      Name: .note.gnu.property
# TEST8-NEXT: Type: SHT_NOTE (0x7)
# TEST8-NEXT: Flags [ (0x2)
# TEST8-NEXT:   SHF_ALLOC (0x2)
# TEST8-NEXT: ]
# TEST8-NEXT: Address: 0x238
# TEST8-NEXT: Offset: 0x238
# TEST8-NEXT: Size: 24
# TEST8-NEXT: Link: 0
# TEST8-NEXT: Info: 0
# TEST8-NEXT: AddressAlignment: 8
# TEST8-NEXT: EntrySize: 0

# TEST8:      Type: PT_GNU_PROPERTY (0x6474E553)
# TEST8-NEXT: Offset: 0x238
# TEST8-NEXT: VirtualAddress: 0x238
# TEST8-NEXT: PhysicalAddress: 0x238
# TEST8-NEXT: FileSize: 24
# TEST8-NEXT: MemSize: 24
# TEST8-NEXT: Flags [ (0x4)
# TEST8-NEXT:   PF_R (0x4)
# TEST8-NEXT: ]
# TEST8-NEXT: Alignment: 8

#--- property.s
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
.long 3                 // pr_type
.long 0                 // pr_datasz
3:

.text
.globl _start
 ret

#--- empty.s
// empty
