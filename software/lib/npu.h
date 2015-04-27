/*
 * npu.h
 *
 *  Created on: Oct 30, 2013
 *      Author: Thierry Moreau <moreau@cs.washington.edu>
 */

#ifndef NPU_HEADER_
#define NPU_HEADER_

// OCM Buffers
#define OCM_SRC              0xFFFF0000
#define OCM_DST              0xFFFF8000
// Function macros
#define mtcp(rn, v)       __asm__ __volatile__ ("mcr " rn "\n" : : "r" (v))
#define isb()             __asm__ __volatile__ ("isb" : : : "memory")
#define dsb()             __asm__ __volatile__ ("dsb" : : : "memory")
#define sev()             __asm__ __volatile__ ("SEV\n")
#define wfe()             __asm__ __volatile__ ("WFE\n")
#define init()            (*((volatile int *)OCM_CHK)=0)
#define check()           assert(*((volatile int *)OCM_CHK)==0)
#define wait()            while (*((volatile int *)OCM_CHK)==0) {; }
#define npu()             dsb(); sev(); wfe(); wfe()

void setTlbAttributes(unsigned int addr, unsigned int attrib);

// Register maps
#define XREG_CP15_INVAL_UTLB_UNLOCKED           "p15, 0, %0,  c8,  c7, 0"
#define XREG_CP15_INVAL_BRANCH_ARRAY            "p15, 0, %0,  c7,  c5, 6"

#endif /* NPU_HEADER_ */
