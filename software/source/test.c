//-----------------------------------------------------------------------------
// test.c
// Author: Thierry Moreau
// Email: moreau@cs.washington.edu
//-----------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "npu.h"
#include "profile.h"

#define DATASET_SIZE    1024

// Interface parameteres
#define NUM_INPUTS      1
#define NUM_OUTPUTS     1
#define BUFFER_SIZE     64

// Global variables
long long int t_kernel_precise;
long long int t_kernel_approx;
long long int dynInsn_kernel_approx;

int main (int argc, char **argv)
{
    int i, j;

    // Performance counters
    unsigned int t_precise;
    unsigned int t_approx;
    unsigned int dynInsn_precise;
    unsigned int dynInsn_approx;
    unsigned int evt_counter[1] = {0x68};

    ///////////////////////////////
    // 1 - Initialization
    ///////////////////////////////

    // Init performance counters:
    init_perfcounters (1, 0, 1, evt_counter);
    t_kernel_precise = 0;
    t_kernel_approx = 0;
    dynInsn_kernel_approx = 0;

    // TLB page settings
    setTlbAttributes(OCM_SRC,0x15c06);
    setTlbAttributes(OCM_DST,0x15c06);

#if TIMER==0
    t_approx = get_cyclecount();
#else
    t_approx = rd_fpga_clk();
#endif //TIMER

    dynInsn_approx = get_eventcount(0);

    volatile uint64_t * iBuff;
    volatile uint64_t * oBuff;

    // NPU OFFLOADING
    for (i = 0; i < DATASET_SIZE*NUM_INPUTS; i += BUFFER_SIZE*NUM_INPUTS){

#if PROFILE_MODE == 2
        t_kernel_approx_start();
#elif PROFILE_MODE == 1
        dynInsn_kernel_approx_start();
#endif //PROFILE_MODE

        iBuff = (uint64_t*) OCM_SRC;
        oBuff = (uint64_t*) OCM_DST;
        for(j = 0; j < NUM_OUTPUTS * BUFFER_SIZE; j++) {
            *(oBuff+j) = 0;
        }
        for(j = 0; j < NUM_INPUTS * BUFFER_SIZE; j++) {
            *(iBuff+j) = j;
        }
        npu();
        for(j = 0; j < NUM_OUTPUTS * BUFFER_SIZE; j++) {
            assert( *(oBuff+j)==j );
        }

#if PROFILE_MODE == 2
        t_kernel_approx_stop();
#elif PROFILE_MODE == 1
        dynInsn_kernel_approx_stop();
#endif //PROFILE_MODE
    }

    dynInsn_approx = get_eventcount(0) - dynInsn_approx;

#if TIMER==0
    t_approx = get_cyclecount() - t_approx;
#else
    t_approx = rd_fpga_clk() - t_approx;
#endif //TIMER

    printf("Success!!!\n");

    return 0;
}
