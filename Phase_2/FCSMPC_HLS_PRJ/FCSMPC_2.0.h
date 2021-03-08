#ifndef MAIN_H_INCLUDED
#define MAIN_H_INCLUDED

	#include <hls_stream.h>
	#include <ap_axi_sdata.h>
	#include <ap_cint.h>
	#include <ap_int.h>
	#include <stdint.h>
	#include <cstdlib>
//	#include "sin_table.h"

#define RPM_TO_W_E_FACTOR 	0.2094395102f    	// w_e = 2*w_m = 2*2*pi * RPM/60 = 0.2094395102*RPM
#define ONE_OVER_SQRT3 		0.57735026919f		// 1/sqrt(3) = 0.57735026919
#define INDUCTION_FACTOR 	385					// w_e * Psi/L = 2*2*pi*RPM/60 * Psi/L/0.002814433 = 469.133*RPM (Measured 385)

/*void FCSMPC(float R_over_L,				// quotient of phase resistance over phase inductance
			float one_over_L,			// inverse of the phase inductance
			float sampling_period,		// the sampling period of the synthesized FCSMPC Code
			uint16_t lm_over_c_i_sqr ,	// lamda_u divided by the conversion factor c_i squared
			int16_t	angle,				// angle of the motor in encoder steps (0 ... 999)
			int16_t	RPM,				// speed of the motor in rpm
			int16_t id_m,				// d component of the measured current
			int16_t	iq_m,				// q component of the measured current
			int16_t id_SP, 				// set point of the d component of the current
			int16_t iq_SP,				// set point of the q component of the current
			ap_int<3> *GH, 				// inverted Gate signals for the high side (bit layout 0bCBA)
			ap_int<3> *GL,				// inverted Gate signals for the low side (bit layout 0bCBA)
			int16_t *id_exp, 			// Output for debug purpose - what does the MPC predict
			int16_t *iq_exp);         // Output for debug purpose - what does the MPC predict)
*/
void FCSMPC(float R_over_L,				// quotient of phase resistance over phase inductance
			float one_over_L,			// inverse of the phase inductance
			float sampling_period,		// the sampling period of the synthesized FCSMPC Code
			uint16_t lm_over_c_i_sqr ,	// lamda_u divided by the conversion factor c_i squared
			hls::stream<int64_t> &s_axis,
			int16_t id_SP, 				// set point of the d component of the current
			int16_t iq_SP,				// set point of the q component of the current
			ap_int<3> *GH, 				// inverted Gate signals for the high side (bit layout 0bCBA)
			ap_int<3> *GL,				// inverted Gate signals for the low side (bit layout 0bCBA)
			int16_t *id_exp, 			// Output for debug purpose - what does the MPC predict
			int16_t *iq_exp
);
#endif // MAIN_H_INCLUDED
