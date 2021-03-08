#include "FCSMPC_2.0.h"

int main(){
	ap_int<3> GH, GL;
	hls::stream<int64_t> inputStream;
	int64_t in_data;
	int16_t id_exp, iq_exp;
	int16_t id_in[] = {0,5,5,16,0,18,18,9,-13,-25,-27,-30,-17,-5,15},
			iq_in[] = {0,0,0,0,0,0,90,129,141,116,131,117,108,93,84},
			RPM[]   = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			angle[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

	for(int idx = 0; idx < 15; idx++){
		in_data = (int64_t(id_in[idx]) & 0x0000FFFF) | ((int64_t(iq_in[idx]) << 16 ) & 0xFFFF0000) |((int64_t(RPM[idx]) << 32) & 0xFFFF00000000) | ((int64_t(RPM[idx]) << 48) & 0xFFFF000000000000);
		inputStream << in_data;
		printf("\nRUN %d\n", idx+1);
/*		FCSMPC(	2762.430939,
				1178.349448,
				0.00000585,
				0,
				angle[idx],
				RPM[idx],
				id_in[idx],
				iq_in[idx],
				0, 100,
				&GH, &GL,
				&id_exp, &id_exp);

*/
		FCSMPC( 2762.430939,
				1178.349448,
				0.00000585,
				0,
				inputStream,
				0, 100,
				&GH, &GL,
				&id_exp, &id_exp
				);
		printf("GH: %x\n",  0b111 & (uint8_t)GH);
	}
	return 0;
}
