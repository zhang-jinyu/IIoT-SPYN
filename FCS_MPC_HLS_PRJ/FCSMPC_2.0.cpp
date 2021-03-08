#include "FCSMPC_2.0.h"
#include "sin_table.h"
using namespace hls;

/* void FCSMPC(float R_over_L,				// quotient of phase resistance over phase inductance
            float one_over_L,			// inverse of the phase inductance
            float sampling_period,		// the sampling period of the synthesized FCSMPC Code
            uint16_t lm_over_c_i_sqr ,	// lamda_u divided by the squared conversion factor c_i^2
		    int16_t	angle,				// angle of the motor in encoder steps (0 ... 999)
		    int16_t	RPM,				// speed of the motor in rpm
		    int16_t id_m,				// d component of the measured current (conversion factor c_i applied)
		    int16_t	iq_m,				// q component of the measured current (conversion factor c_i applied)
			int16_t id_SP, 				// set point of the d component of the current (conversion c_i factor applied)
			int16_t iq_SP,				// set point of the q component of the current (conversion c_i factor applied)
			ap_int<3> *GH, 				// inverted Gate signals for the high side (bit layout 0bCBA)
			ap_int<3> *GL,				// inverted Gate signals for the low side (bit layout 0bCBA)
			int16_t *id_exp, 			// Output for debug purpose - MPC prediction (conversion factor c_i applied)
			int16_t *iq_exp)*/

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
			int16_t *iq_exp){// Output for debug purpose - MPC prediction (conversion factor c_i applied)

	int64_t in_data;
	int16_t	angle;				// angle of the motor in encoder steps (0 ... 999)
	int16_t	RPM;			// speed of the motor in rpm
	int16_t id_m;				// d component of the measured current (conversion factor c_i applied)
	int16_t	iq_m;				// q component of the measured current (conversion factor c_i applied)

	in_data =s_axis.read();
	id_m  = int16_t(in_data & 0xFFFF);
	iq_m  = int16_t(in_data >> 16 & 0xFFFF );
	RPM   = int16_t(in_data >> 32 & 0xFFFF );
	angle = int16_t(in_data >> 48 & 0xFFFF );

	/* all switch positions: idx 	0		1		2		3		4		5		6		7		*/
    const uint8_t uk_pos[3][8] = {{ 0,  	12,		0,      12,     0,  	12,  	0,  	12},	// PHASE A
                                 { 	0,		0,		12,  	12,  	0,      0,		12,  	12},	// PHASE B
								 { 	0,		0, 		0,      0,  	12,     12, 	12,     12}};	// PHASE C

    /* the switch position that was chosen at the last MPC run (initially 0) */
    static uint8_t uk_0 = 0;
    /* current predictions of the last three MPC runs */
	static  int16_t	delta_id_pred_k_1 = 0,	// 1st delay compensation for the execution time of the MPC
					delta_iq_pred_k_1 = 0,
					delta_id_pred_k_2 = 0,	// 2nd delay compensation for delay in the measurement
					delta_iq_pred_k_2 = 0,
					delta_id_pred_k_3 = 0,	// 3rd delay compensation for delay in the measurement
					delta_iq_pred_k_3 = 0;

	/* System Matrix of the PMSM */
	static float A_Mat[2][2];
	A_Mat[0][1] = RPM	*	RPM_TO_W_E_FACTOR;	// A =  [ -R/L	w_e	 ]
	A_Mat[1][0] = -A_Mat[0][1];				//		[  w_e	-R/L ]
	A_Mat[0][0] = A_Mat[1][1] = -R_over_L;	// with w_e = electrical speed of the EM in rad/sec

	/* If the EM turns faster than 2500 an encoder step has to be added (sample rate ~6us)
	 * since the code is calculated for the situation 3 steps in the future */
	int16_t cost_over_c_i;
	int16_t sint_over_c_i;
	if (RPM > 2500)
		angle++;
	else if (RPM > 7500)
		angle += 2;
	/* sine and cosine are needed for the park transformation.
	 * A LUT has been calculated offline for all encoder steps to increase performance.
	 * The current scaling factor has already been applied to be able to work with integer */
	if (angle > 999)
		angle -= 1000;
	cost_over_c_i = cosus_table[angle];
	sint_over_c_i = sinus_table[angle];

	/* The last 3 delta_i predictions are summed up and the newest measurement is used as the base.
	 * The result are the currents that are expected at t = k+3 (code started at t = k) */
	int16_t id_pred_k_3 = id_m + delta_id_pred_k_1 + delta_id_pred_k_2 + delta_id_pred_k_3;
	int16_t iq_pred_k_3 = iq_m + delta_iq_pred_k_1 + delta_iq_pred_k_2 + delta_iq_pred_k_3;

/*########## Calculate the Udq for all possible switch positions ##########*/
	/* only two offline calculated ualpha/beta values are needed (symmetrical voltage hexagon):
	 * U_alpha/beta = 	[ 2/3*ua  -  ub/3    -   uc/3  ]
	 * 					[   0   + ub/sqrt(3) - uc/sqrt(3)] 	*/
	float ualpha[3], ubeta[3];
	ualpha[0] = 8;			// for switch position index 1
	ubeta[0]  = 0;			// for switch position index 1
	ualpha[1] = -4;			// for switch position index 2
	ubeta[1]  = 6.9282;		// for switch position index 2
	ualpha[2] = -ualpha[1];	// switch position 3 can be derived from 2
	ubeta[2]  = ubeta[1];	// switch position 3 can be derived from 2

	/* three Udq values have to be calculated for the given angle:
	 * U_d/q = 	[ cos(ang)*u_alpha + sin(ang)*i_beta ]
	 * 			[ cos(ang)*i_beta  - sin(ang)*u_alpha] 	*/
	float ud[8], uq[8];
	CAL_UD_UQ_LOOP:for (int idx = 1; idx <4; idx++){
		ud[idx] = cost_over_c_i * ualpha[idx-1] + sint_over_c_i * ubeta[idx-1];
		uq[idx] = cost_over_c_i * ubeta[idx-1]  - sint_over_c_i * ualpha[idx-1];
	}
	/* Udq 4 to 6 are just mirrored Udq 1 to 3 */
	ud[4] = -ud[3];
	uq[4] = -uq[3];
	ud[5] = -ud[2];
	uq[5] = -uq[2];
	ud[6] = -ud[1];
	uq[6] = -uq[1];
	/* ud = uq = 0 if all switch positions are identical */
	ud[0] = uq[0] = ud[7] = uq[7] = 0;

/*########## Calculate the current changes for all possible switch positions ##########*/
	int32_t iq_induction = -RPM*INDUCTION_FACTOR;	// iq induction = -w_e * Psi/L
	int32_t d_id[8], d_iq[8];						// variables to store the di/dt values
	float delta_id[8], delta_iq[8];					// variables to store the delta_i/t_sample
	/* Calculate the current change for all possible switch positions
	 * di_dq/dt =  	[A00 A01]*[id] + 	0	   + 1/L*ud
	 * 				[A10 A11] [iq] + iq_induct + 1/L*uq */
	CAL_ID_IQ_LOOP:for (int idx = 0; idx < 8; idx++){
		d_id[idx] =   A_Mat[0][0]*id_pred_k_3
					+ A_Mat[0][1]*iq_pred_k_3
					+ one_over_L*ud[idx];
		d_iq[idx] =   A_Mat[1][0]*id_pred_k_3
					+ A_Mat[1][1]*iq_pred_k_3
					+ iq_induction
					+ one_over_L*uq[idx];
		/* Calculate the change of the current within one sampling period delta_i/t_sample */
		delta_id[idx] = d_id[idx]*sampling_period;
		delta_iq[idx] = d_iq[idx]*sampling_period;
		/* Debug output */
		printf("%d: ud = %8.4f,\tuq = %8.4f,\td_id = %8.4f,\td_iq = %8.4f\n",
				idx, ud[idx]*.002814433, uq[idx]*.002814433, delta_id[idx], delta_iq[idx]);
	}
/*########## Calculate the switching effort for all possible switch positions ##########*/
	uint8_t sw_eff[8] = {0};
	CAL_SW_EFF_OUTTER_LOOP:for (int idx = 0; idx < 8; idx++)			// iterate through all switch positions
		CAL_SW_EFF_INNER_LOOP:for (int idx2 = 0; idx2 < 3; idx2++)	// iterate through all phase switches
			if (uk_pos[idx2][uk_0] != uk_pos[idx2][idx]) // if the phase switch is different from the previous...
				sw_eff[idx]++;					// ... increase the switching effort counter for that index

/*########## Calculate the optimal switch position with the cost function ##########*/
	uint8_t uk_1_opt = 0;	// variable to find and store the best switch position index
	int32_t J[8];			// variable to store all cost function runs
	CAL_J_LOOP:for (int idx = 0; idx < 8; idx++){
		J[idx] =    (id_pred_k_3+delta_id[idx]-id_SP)*(id_pred_k_3+delta_id[idx]-id_SP)
				  + (iq_pred_k_3+delta_iq[idx]-iq_SP)*(iq_pred_k_3+delta_iq[idx]-iq_SP)
				  +  sw_eff[idx]*lm_over_c_i_sqr;
		if (J[idx] < J[uk_1_opt])	// if the current cost function result is lower than the best so far...
			uk_1_opt = idx;			// save the current index as the new best index
		/* Debug output */
		printf("J(%d) = %d\n", idx, J[idx]);
	}
	/* Debug output */
	printf("J_opt = %d, idx = %d\n",J[uk_1_opt], uk_1_opt);

/*########## UPDATE THE STATIC SIGNALS FOR THE NEXT ROUND ##########*/
	delta_id_pred_k_1 = delta_id_pred_k_2;	// pull the previous predictions on step back
	delta_iq_pred_k_1 = delta_iq_pred_k_2;	// k+1 = k+2
	delta_id_pred_k_2 = delta_id_pred_k_3;	// k+2 = k+3
	delta_iq_pred_k_2 = delta_iq_pred_k_3;
	delta_id_pred_k_3 = delta_id[uk_1_opt];	// save the current prediction for t = k+3
	delta_iq_pred_k_3 = delta_iq[uk_1_opt];
	uk_0 = uk_1_opt;						// save the optimal switch position as applied switch position

/*########## SET THE OUTPUTS WITH THE CALCULATED VALUES		##########*/
	/* The Gate Signals are inverted so e.g. in order to
	 * turn only phase A on GH has to be 0b110 and GL 0b001*/
	*GL = uk_1_opt & 0b111;
	*GH = ~*GL;
	/* For debugging and optimization:
	 * The predicted currents after two more sampling periods */
	*id_exp = id_pred_k_3;
	*iq_exp = iq_pred_k_3;
}


