/*
 * npu.c
 *
 *  Created on: July 7, 2013
 *      Author: Thierry Moreau <moreau@cs.washington.edu>
 */

#include "npu.h"

void setTlbAttributes(unsigned int addr, unsigned int attrib)
{
    unsigned int *ptr;
    unsigned int section;

    int * MMUTable2;
    unsigned int MMUTable3;
    // Read TTB register
    asm volatile ("MRC p15, 0, %0, c2, c0, 0\t\n": "=r"(MMUTable3));
    // Mask off the least significant 14 bits
    MMUTable3 &= 0xFFFFC000;
    MMUTable2 = (int *) MMUTable3;

    mtcp(XREG_CP15_INVAL_UTLB_UNLOCKED, 0);
    dsb();

    section = addr / 0x100000;
    ptr = MMUTable2 + section;
    *ptr = (addr & 0xFFF00000) | attrib;
    dsb();

    mtcp(XREG_CP15_INVAL_UTLB_UNLOCKED, 0);
    /* Invalidate all branch predictors */
    mtcp(XREG_CP15_INVAL_BRANCH_ARRAY, 0);

    dsb(); /* ensure completion of the BP and TLB invalidation */
    isb(); /* synchronize context on this processor */
}