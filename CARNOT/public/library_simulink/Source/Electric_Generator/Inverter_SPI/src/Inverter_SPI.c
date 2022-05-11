/***********************************************************************
 * This file is part of the CARNOT Blockset.
 * Copyright (c) 1998-2018, Solar-Institute Juelich of the FH Aachen.
 * Additional Copyright for this file see list auf authors.
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 * $Revision: 372 $
 * $Author: patrick-kefer $
 * $Date: 2018-01-11 07:38:48 +0100 (Do, 11 Jan 2018) $
 * $HeadURL: https://svn.noc.fh-aachen.de/carnot/branches/carnot_7_00_01/public/src/Inverter_SPI.c $
 * 
 * Original Model by:
 * MIT License
 *  Copyright (c) 2019 Johannes Weniger, Tjarko Tjaden, Nico Orth, Selina Maier
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.

 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE. /*
 ***********************************************************************
 *
 *  M O D E L    O R    F U N C T I O N
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * This MEX-file performs the model of a DC-Battery Inverter. 
 * Parts of the model were taken from (see licence above):
 * Johannes Weniger, Tjarko Tjaden, Nico Orth, Selina Maier; 2019; Performance Simulation Model for PV-Battery Systems (PerMod);
 *  Research group Solar Storage Systems University of Applied Sciences Berlin (HTW Berlin)
 *
 *     Syntax  [sys, x0] = (t,x,u,flag)
 *
 * related header files:
 *
 * author list:     pk -> Patrick Kefer
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * Version  Author          Changes                             Date
 * 7.1.0    pk   created                           06_2021
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *
 *	-->math. model
 *
 *  symbol      used for                                    unit
 *
 *
 *
 * structure of u (input vector)
 * port use
 * 0	pv-power						W
 * 1	load power						W
 * 2	POWER TARGET					W
 * 3	activate chargeing from AC		-
 *
 *
 * structure of y (output vector)
 *  port    use
 *  0		Ppvbs						W
 *  1		power - PV to AC			W
 *  2		power - battery to AC		W
 *  3		power - AC to battery		W
 *  4		power - PV to battery		W
 *  5		battery-power to AC			W
 *  6		battery-power				W
 *  7		state of charge				-
 *  8		battery energy				J
 */

#define S_FUNCTION_NAME Inverter_SPI
#define S_FUNCTION_LEVEL 2

 //#define MATLAB_MEX_FILE // only for intellisense in Visual Studio

#include "tmwtypes.h"
#include "simstruc.h"
#include "matrix.h"
#include "carlib.h"
#include <math.h>
#include <string.h>

// PARAMS
#define SOC0          *mxGetPr(ssGetSFcnParam(S, 0)) // initial state of charge: 0 <= Soc0 <= 1
#define CAP_BAT_USR   *mxGetPr(ssGetSFcnParam(S, 1)) // user defined Battery Capacity in kWh overrides SPI Parameter if > 0
#define SOC_MIN       *mxGetPr(ssGetSFcnParam(S, 2)) // min state of charge
#define SOC_MAX       *mxGetPr(ssGetSFcnParam(S, 3)) // max state of charge

#define SPI_PARAMS     ssGetSFcnParam(S, 4) // SPI Parameter array
#define I_P_PV2AC_in	0
#define I_P_PV2AC_out	1 //
#define I_P_PV2BAT_in	2 //
#define I_P_PV2BAT_out	3 //
#define I_P_BAT2AC_out	4 //
#define I_P_AC2BAT_in	5 //
#define I_PV2AC_a_in	6 //
#define I_PV2AC_b_in	7 //
#define I_PV2AC_c_in    8 //
#define I_PV2AC_a_out   9 //
#define I_PV2AC_b_out   10 //
#define I_PV2AC_c_out   11 //
#define I_PV2BAT_a_in   12 //
#define I_PV2BAT_b_in   13 //
#define I_PV2BAT_c_in   14 //
#define I_BAT2AC_a_out  15 //
#define I_BAT2AC_b_out  16 //
#define I_BAT2AC_c_out  17 //
#define I_AC2BAT_a_out  18 //
#define I_AC2BAT_b_out  19 //
#define I_AC2BAT_c_out  20 //
#define I_AC2BAT_a_in   21 //
#define I_AC2BAT_b_in   22 //
#define I_AC2BAT_c_in   23 //
#define I_SOC_h         24 //
#define I_t_DEAD        25 //
#define I_t_CONSTANT    26 //
#define I_P_SYS_SOC1_DC 27 //
#define I_P_SYS_SOC1_AC 28 //
#define I_P_SYS_SOC0_AC 29 //
#define I_P_SYS_SOC0_DC 30 //
#define I_P_PERI_AC     31 //
#define I_CAP_BAT		32 //
#define I_ETA_BAT		33 //
#define N_SPI_PAR   34 // number of inverter parameters

#define TSAMPLE       *mxGetPr(ssGetSFcnParam(S, 5)) // sample time as parameter
#define NPARAMS 	6 //number of parameters of s-function

// INPUTS
#define P_PV         *u0[0] // PV power
#define P_LOAD       *u0[1] // Load
#define POWER_TARGET *u0[2] // setpoint grid power
#define AC_CHARGE_ON *u0[3] // ctrl Mode > 0 = allow charging from AC
#define NUM_INPUTS 4
#define NUM_IN_PORTS 1

//OUTPUT DESCRIPTION
#define y_Ppvbs			y0[0] // AC Power of inverter [W]
#define y_Pac2bat_in	y0[3] // Battery power to AC at battery-node [W]
#define y_Pbat2ac_out	y0[2] // Battery power to AC at AC-node [W]
#define y_Ppv2ac_out	y0[1] // PV power to AC at AC-node [W]
#define y_Ppv2bat_in    y0[4] // PV power to AC at PV-node) [W]
#define y_Pbat			y0[5] // battery power [W]
#define y_Soc			y0[6] // state of charge [-]
#define y_Ebat		y0[7] // battery charge  [Ws]
#define NUM_OUTPUTS 8
#define NUM_OUT_PORTS 1

#define TIME	ssgetT(S)
/*working vector */
#define SOC					dwork[0] /*previous state of charge used for hysteresis*/
#define P_BAT_ACT			dwork[1] // buffer for Battery power mdlOutput to mdlUpdate
#define P_PV2BAT_IN_PREV	dwork[2] // buffers for DT1 control beaviour
#define P_BAT2AC_OUT_PREV	dwork[3]  
#define P_AC2BAT_OUT_PREV	dwork[4] // not used
#define P_AC2BAT_IN_PREV	dwork[5] // not used
#define FTDE				dwork[6] // time constant factor
#define DWORK_NO 0
#define LEN_DWORK 7

// ringbuffers for control deadtime - length dep. on sample time
#define DWORK_RES_DISCH_NO 1
#define DWORK_RES_CHARGE_NO 2
#define DWORK_CHARGE_AC_NO 3
#define DWORK_CHARGE_PV_NO 4

/*charging hysteresis*/
#define SOC_HYST		dwork_hyst[0]
#define DWORK_HYST_NO 5
#define LEN_DWORK_HYST 1

#define NUM_DWORK 6

/* state: stored electric energy */
#define EBAT x[0]
#define NUM_DISC_STATES	1


#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlCheckParameters =============================================
 * Abstract:
 *    Validate our parameters to verify they are okay.
 */
static void mdlCheckParameters(SimStruct* S)
{
	mxDouble* parPtr;//double* parPtr;
	const mxArray* spi_params = SPI_PARAMS;
	mxClassID parID;
	mwSize nElements;
	int_T eIdx = 1;
	char strbuffer[100];
	static char errorstr[100];

	parID = mxGetClassID(spi_params);// != mxDOUBLE_CLASS)
	if (!mxIsDouble(spi_params)) {//no double array type
		ssSetErrorStatus(S, "Parameter must be matlab double array");
		return;
	}
	else {
		nElements = (mwSize)mxGetNumberOfElements(spi_params);
		if (nElements != N_SPI_PAR) {// stop on parameter count mismatch
			ssSetErrorStatus(S, "SPI Parameter array should be of size ");
			return;
		}
#if MX_HAS_INTERLEAVED_COMPLEX // new api with mex "-R2018a" option
		parPtr = mxGetDoubles(spi_params);
#else// old api
		parPtr = mxGetPr(spi_params);
#endif
	}
	if (parPtr[I_P_PV2AC_in] <= 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_PV2AC_out);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_PV2AC_out < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_P_PV2AC_out] <= 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_PV2AC_out);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_PV2AC_out < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_P_PV2BAT_in] <= 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_PV2BAT_in);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_PV2BAT_in < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_P_PV2BAT_out] <= 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_PV2BAT_out);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_PV2BAT_out < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_P_BAT2AC_out] <= 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_BAT2AC_out);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_BAT2AC_out < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_P_BAT2AC_out] <= 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_BAT2AC_out);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_BAT2AC_out < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_P_AC2BAT_in] < 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_AC2BAT_in);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_AC2BAT_in < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if ((parPtr[I_SOC_h] < 0) || (parPtr[I_SOC_h] > 1)) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_SOC_h);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": SOC_h < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_t_DEAD] < 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_t_DEAD);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": t_DEAD < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_t_CONSTANT] < 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_t_CONSTANT);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": t_CONSTANT < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_P_SYS_SOC1_DC] < 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_SYS_SOC1_DC);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_SYS_SOC1_DC < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_P_SYS_SOC1_AC] < 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_SYS_SOC1_AC);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_SYS_SOC1_AC < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_P_SYS_SOC0_AC] < 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_SYS_SOC0_AC);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_SYS_SOC0_AC < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_P_SYS_SOC0_DC] < 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_SYS_SOC0_DC);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_SYS_SOC0_DC < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_P_PERI_AC] < 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_P_PERI_AC);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": P_PERI_AC < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if (parPtr[I_CAP_BAT] < 0) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_CAP_BAT);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": E_BAT < 0", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	if ((parPtr[I_ETA_BAT] <= 0) || (parPtr[I_ETA_BAT] < 0)) {
		snprintf(strbuffer, sizeof(strbuffer), "%d", I_ETA_BAT);
		strncpy(errorstr, "Parameter Value violation - Spi Parameter  ", sizeof(errorstr));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		strncpy(strbuffer, ": 0 > eta_BAT <= 1", sizeof(strbuffer));
		strncat(errorstr, strbuffer, sizeof(errorstr) - strlen(errorstr) - 1);
		ssSetErrorStatus(S, errorstr);
		return;
	}
	/* Check param  initial state of charge */
	if ((SOC0 < 0.0) || (SOC0 > 1.0)) {
		ssSetErrorStatus(S, "Parameter Value violation: 0 >= SOC0 >= 1");
		return;
	}
	/* Check param battery capacity */
	if (CAP_BAT_USR > 0.0) {
		ssWarning(S, "Parameter Value: User Battery Capacity > 0 --> overriding default value ");		
		return;
	}
	/* Check param min Soc */
	if ((SOC_MAX < 0.0) || (SOC_MAX > 1.0)) {
		ssSetErrorStatus(S, "Parameter Value violation: 0 >= SOC_max >= 1");
		return;
	}
	if (SOC_MAX < SOC_MIN) {
		ssSetErrorStatus(S, "Parameter Value violation: SOC_max < Soc_min");
		return;
	}
	/* Check param min Soc */
	if ((SOC_MIN < 0.0) || (SOC_MAX > 1.0)) {
		ssSetErrorStatus(S, "Parameter Value violation: 0 >= SOC_min >= 1");
		return;
	}
}
#endif /* MDL_CHECK_PARAMETERS */

static void mdlInitializeSizes(SimStruct* S)
{
	ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters is one */
	/* check if the number of parameters is correct */
#if defined(MATLAB_MEX_FILE)
	if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
		mdlCheckParameters(S);
		if (ssGetErrorStatus(S) != NULL) {
			return;
		}
	}
	else {
		return; /* Parameter mismatch will be reported by Simulink */
	}
#endif

	real_T tsample = TSAMPLE;
	int_T lenPrev;
	mxDouble* parPtr;//double* parPtr;
	const mxArray* spi_params = SPI_PARAMS;
#if MX_HAS_INTERLEAVED_COMPLEX // new api with mex "-R2018a" option
	parPtr = mxGetDoubles(spi_params);
#else// old api
	parPtr = mxGetPr(spi_params);
#endif

	/* Continuous states are used for integration.
	 * Here we define one integrator.
	 * Integrators are called continuous states in Simulink */
	ssSetNumContStates(S, 0);  /* number of continuous states */

	/* We do not consider discrete systems */
	ssSetNumDiscStates(S, NUM_DISC_STATES);      /* number of discrete states    */

	/* Now we set the number of inports (2 here) */
	if (!ssSetNumInputPorts(S, NUM_IN_PORTS))   /* number of inputs    */
	{
		return;
	}
	/* Set number of elements to 2 for each inport */
	ssSetInputPortWidth(S, 0, NUM_INPUTS);
	ssSetInputPortDirectFeedThrough(S, 0, 1);
	
	 /* Set the number of outputs to 2 */
	if (!ssSetNumOutputPorts(S, NUM_OUT_PORTS))
	{
		return;
	}
	/* Set the number of elements for each outport to one */
	ssSetOutputPortWidth(S, 0, NUM_OUTPUTS);

	/* We only have one sample time */
	ssSetNumSampleTimes(S, 1);  /* number of sample times       */

	ssSetNumRWork(S, 0); /* number of real work vector elements    */
	ssSetNumIWork(S, 0); /* number of integer work vector elements */
	ssSetNumPWork(S, 0); /* number of pointer work vector elements */

	ssSetNumDWork(S, NUM_DWORK); /* number of D work vector elements */

	ssSetDWorkWidth(S, DWORK_NO, LEN_DWORK); /* there should be one element */
	ssSetDWorkDataType(S, DWORK_NO, SS_DOUBLE); /* type double */
	ssSetDWorkName(S, DWORK_NO, "DWORK_PREV"); /* give it a name */
	ssSetDWorkUsageType(S, DWORK_NO, SS_DWORK_USED_AS_DWORK); /* use it as state */

	lenPrev = round( (parPtr[I_t_DEAD]) / tsample + 1);
	lenPrev = max(lenPrev, 1);/* min. one element */
	ssSetDWorkWidth(S, DWORK_RES_DISCH_NO, lenPrev);
	ssSetDWorkDataType(S, DWORK_RES_DISCH_NO, SS_DOUBLE);
	ssSetDWorkName(S, DWORK_RES_DISCH_NO, "DWORK_DISCH");
	ssSetDWorkUsageType(S, DWORK_RES_DISCH_NO, SS_DWORK_USED_AS_DWORK);

	ssSetDWorkWidth(S, DWORK_RES_CHARGE_NO, lenPrev);
	ssSetDWorkDataType(S, DWORK_RES_CHARGE_NO, SS_DOUBLE);
	ssSetDWorkName(S, DWORK_RES_CHARGE_NO, "DWORK_CHARGE");
	ssSetDWorkUsageType(S, DWORK_RES_CHARGE_NO, SS_DWORK_USED_AS_DWORK);

	ssSetDWorkWidth(S, DWORK_CHARGE_AC_NO, lenPrev);
	ssSetDWorkDataType(S, DWORK_CHARGE_AC_NO, SS_DOUBLE);
	ssSetDWorkName(S, DWORK_CHARGE_AC_NO, "DWORK_CHARGE_AC");
	ssSetDWorkUsageType(S, DWORK_CHARGE_AC_NO, SS_DWORK_USED_AS_DWORK);

	ssSetDWorkWidth(S, DWORK_CHARGE_PV_NO, lenPrev);
	ssSetDWorkDataType(S, DWORK_CHARGE_PV_NO, SS_DOUBLE);
	ssSetDWorkName(S, DWORK_CHARGE_PV_NO, "DWORK_CHARGE_PV");
	ssSetDWorkUsageType(S, DWORK_CHARGE_PV_NO, SS_DWORK_USED_AS_DWORK);

	ssSetDWorkWidth(S, DWORK_HYST_NO, LEN_DWORK_HYST);
	ssSetDWorkDataType(S, DWORK_HYST_NO, SS_BOOLEAN);
	ssSetDWorkName(S, DWORK_HYST_NO, "DWORK_HYST");
	ssSetDWorkUsageType(S, DWORK_HYST_NO, SS_DWORK_USED_AS_DWORK);

	ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
	ssSetSimStateVisibility(S, 1);

	/* This flag is needed for ForEach subsystems */
	ssSupportsMultipleExecInstances(S, true);
}

static void mdlInitializeSampleTimes(SimStruct* S)
{	
	real_T tsample = TSAMPLE;

	//ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
	ssSetSampleTime(S, 0, tsample);
	//ssSetSampleTime(S, 0, TSAMPLE);
	ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct* S)
{
	real_T* x = ssGetDiscStates(S);
	int_T NumDiscStates = ssGetNumDiscStates(S);
	time_T tsample = ssGetSampleTime(S, 0);
	mxDouble* parPtr;
	const mxArray* spi_params = SPI_PARAMS;

#if MX_HAS_INTERLEAVED_COMPLEX // new api with mex "-R2018a" option
	parPtr = mxGetDoubles(spi_params);
#else // old api
	parPtr = mxGetPr(spi_params);
#endif	
	real_T* dwork = (real_T*)ssGetDWork(S, DWORK_NO);
	real_T* res_charge = (real_T*)ssGetDWork(S, DWORK_RES_CHARGE_NO);
	real_T* res_disch = (real_T*)ssGetDWork(S, DWORK_RES_DISCH_NO);
	real_T* charge_ac = (real_T*)ssGetDWork(S, DWORK_CHARGE_AC_NO);
	real_T* charge_pv = (real_T*)ssGetDWork(S, DWORK_CHARGE_PV_NO);
	real_T cap_bat;
	int_T len_Prev = ssGetDWorkWidth(S, DWORK_RES_CHARGE_NO);
	boolean_T* dwork_hyst = (boolean_T*)ssGetDWork(S, DWORK_HYST_NO);
	int_T n;
	
	if (CAP_BAT_USR > 0)
	{	cap_bat = CAP_BAT_USR * 1000 * 3600;}
	else
	{
		cap_bat = parPtr[I_CAP_BAT] * 1000 * 3600;
	}
	EBAT = SOC0 * cap_bat;
	SOC = SOC0;
	SOC_HYST = 0;

	for (n = 0; n < len_Prev; n++)
	{
		res_charge[n] = 0;
		res_disch[n] = 0;
		charge_ac[n] = 0;
		charge_pv[n] = 0;
	}
	// DT1 factor for one calc. step --> dep. on sample time
	if (parPtr[I_t_CONSTANT] > 0) {
		FTDE = 1 - exp(-tsample / parPtr[I_t_CONSTANT]);
	}
	else {
		FTDE = 0;
	}
}

/*
 * mdlOutputs - compute the outputs
 */
static void mdlOutputs(SimStruct* S, int_T tid)
{
	InputRealPtrsType  u0 = ssGetInputPortRealSignalPtrs(S, 0);
	real_T* y0 = ssGetOutputPortRealSignal(S, 0);
	real_T* x = ssGetDiscStates(S);
	mxDouble* parPtr;
	time_T tsample = ssGetSampleTime(S, 0);
	const mxArray* spi_params = SPI_PARAMS;
#if MX_HAS_INTERLEAVED_COMPLEX // new api with mex "-R2018a" option
	parPtr = mxGetDoubles(spi_params);
#else// old api
	parPtr = mxGetPr(spi_params);
#endif
	/* access DWork vector */
	real_T* dwork = (real_T*)ssGetDWork(S, DWORK_NO);
	real_T* res_charge = (real_T*)ssGetDWork(S, DWORK_RES_CHARGE_NO);
	real_T* res_disch = (real_T*)ssGetDWork(S, DWORK_RES_DISCH_NO);
	real_T* charge_ac = (real_T*)ssGetDWork(S, DWORK_CHARGE_AC_NO);
	real_T* charge_pv = (real_T*)ssGetDWork(S, DWORK_CHARGE_PV_NO);

	boolean_T* dwork_hyst = (boolean_T*)ssGetDWork(S, DWORK_HYST_NO);
	int_T n_dead = ssGetDWorkWidth(S, DWORK_RES_CHARGE_NO) - 1;// last index of ringbuffer i.e. Value after dead-time

	/* Parameter Values*/
	real_T	P_PV2AC_in, P_PV2AC_out, P_PV2BAT_in, P_BAT2AC_out, P_PV2BAT_out, P_AC2BAT_in, P_AC2BAT_out,
		PV2AC_a_in, PV2AC_b_in, PV2AC_c_in, PV2AC_a_out, PV2AC_b_out, PV2AC_c_out, PV2BAT_a_in, PV2BAT_b_in, PV2BAT_c_in,
		BAT2AC_a_out, BAT2AC_b_out, BAT2AC_c_out, AC2BAT_a_out, AC2BAT_b_out, AC2BAT_c_out, AC2BAT_a_in, AC2BAT_b_in, AC2BAT_c_in,
		SOC_h, t_DEAD, t_CONSTANT, P_SYS_SOC1_DC, P_SYS_SOC1_AC, P_SYS_SOC0_AC, P_SYS_SOC0_DC, P_PERI_AC, cap_BAT,
		Ppv, PowerTarget, Pload, soc_max, soc_min;
	/*local variables*/
	real_T	P_PV2AC_min, P_pv2ac_out_max, P_pv2ac_in_Target, P_pv2bat_out,
		Pac_Target, P_pv2ac_in, relPow, P_bat2ac_in, P_ac2bat_out, P_ac2bat_out_Target, P_pv2bat_out_max,
		P_pvbs, P_bat, P_ac2bat_in, P_pv2bat_in, P_pv2ac_out, P_bat2ac_out, Pres_charge, Pres_disch;
	int_T n;

	/*access inputs*/
	Ppv = P_PV;
	PowerTarget = POWER_TARGET;
	Pload = P_LOAD;

	/*access parameters*/
	soc_max = SOC_MAX;// max state of charge
	soc_min = SOC_MIN;// min state of charge

	P_PV2AC_in = parPtr[I_P_PV2AC_in];// nominal output power PV2AC pathway
	P_PV2AC_out = parPtr[I_P_PV2AC_out];// nominal output power PV2AC pathway
	P_PV2BAT_in = parPtr[I_P_PV2BAT_in];// nominal input power PV2BAT pathway
	P_BAT2AC_out = parPtr[I_P_BAT2AC_out];// nominal output power BAT2AC pathway
	P_PV2BAT_out = parPtr[I_P_PV2BAT_out];// nominal output power PV2BAT pathway
	P_AC2BAT_in = parPtr[I_P_AC2BAT_in]; // nominal input power AC2BAT pathway
	PV2AC_a_in = parPtr[I_PV2AC_a_in]; // PV2AC loss coefficients at PV-node
	PV2AC_b_in = parPtr[I_PV2AC_b_in]; 
	PV2AC_c_in = parPtr[I_PV2AC_c_in]; 
	PV2AC_a_out = parPtr[I_PV2AC_a_out]; //PV2AC loss coefficients at AC-node 
	PV2AC_b_out = parPtr[I_PV2AC_b_out]; 
	PV2AC_c_out = parPtr[I_PV2AC_c_out]; 
	PV2BAT_a_in = parPtr[I_PV2BAT_a_in]; //PV2BAT loss coefficients at PV-node
	PV2BAT_b_in = parPtr[I_PV2BAT_b_in]; 
	PV2BAT_c_in = parPtr[I_PV2BAT_c_in]; 
	BAT2AC_a_out = parPtr[I_BAT2AC_a_out]; //PV2BAT loss coefficients at Battery-node
	BAT2AC_b_out = parPtr[I_BAT2AC_b_out]; 
	BAT2AC_c_out = parPtr[I_BAT2AC_c_out]; 
	AC2BAT_a_out = parPtr[I_AC2BAT_a_out]; //AC2BAT loss coefficients at Battery-node
	AC2BAT_b_out = parPtr[I_AC2BAT_b_out]; 
	AC2BAT_c_out = parPtr[I_AC2BAT_c_out]; 
	AC2BAT_a_in = parPtr[I_AC2BAT_a_in]; //AC2BAT loss coefficients at AC-node
	AC2BAT_b_in = parPtr[I_AC2BAT_b_in]; 
	AC2BAT_c_in = parPtr[I_AC2BAT_c_in]; 
	t_DEAD = parPtr[I_t_DEAD];			// control dead time
	t_CONSTANT = parPtr[I_t_CONSTANT];  // control time constant, modelled as first order time delay
	P_SYS_SOC1_DC = parPtr[I_P_SYS_SOC1_DC]; // DC standby losses - charged battery
	P_SYS_SOC1_AC = parPtr[I_P_SYS_SOC1_AC]; // AC standby losses - charged battery
	P_SYS_SOC0_AC = parPtr[I_P_SYS_SOC0_AC]; // AC standby losses - empty battery
	P_SYS_SOC0_DC = parPtr[I_P_SYS_SOC0_DC]; // DC standby losses - empty battery
	P_PERI_AC = parPtr[I_P_PERI_AC];		// losses accouning for peripheral components (f.e. smart meters)	
	
		
	/************************************
	*  MODEL 
	*************************************/
	/*	DC power output of the PV generator taking into account the maximum
		DC input power of the PV2AC conversion pathway*/
	Ppv = MIN(P_PV, MAX(P_PV2AC_in, P_PV2BAT_in) * 1000);

	relPow = MIN(P_PV, P_PV2AC_in * 1000) / P_PV2AC_in / 1000;/*Normalized DC input power of the PV2AC conversion pathway*/
	P_pv2ac_out_max = MAX(0, MIN(P_PV, P_PV2AC_in * 1000) - (PV2AC_a_in * relPow * relPow + PV2AC_b_in * relPow + PV2AC_c_in));/*available AC output power of the PV2AC conversion pathway*/

	relPow = MIN(P_PV, P_PV2BAT_in * 1000) / P_PV2BAT_in / 1000;/*Normalized DC input power of the PV2BAT conversion pathway*/
	P_pv2bat_out_max = MAX(0, MIN(P_PV, P_PV2BAT_in * 1000) - (PV2BAT_a_in * relPow * relPow + PV2AC_b_in * relPow + PV2AC_c_in));/*available DC output power of the PV2BAT conversion pathway*/

	P_PV2AC_min = PV2AC_c_in; // Minimum input power of the PV2AC conversion pathway
	P_AC2BAT_out = (P_AC2BAT_in * 1000 - (AC2BAT_a_in + AC2BAT_b_in + AC2BAT_c_in)) / 1000;
	
	Pac_Target = PowerTarget - Pload + P_PERI_AC;/*Power demand on the AC side*/
	if (AC_CHARGE_ON == 0)
	{
		Pac_Target = MAX(Pac_Target, 0);
	}
	if (Pac_Target >= 0)
	{	/*Target DC input power of the PV2AC conversion pathway*/
		relPow = MIN(ABS(Pac_Target), P_PV2AC_out * 1000) / P_PV2AC_out / 1000; /*Normalized AC output power of the PV2AC conversion pathway to cover the AC power demand*/
		P_pv2ac_in_Target = MIN(ABS(Pac_Target), P_PV2AC_out * 1000) + (PV2AC_a_out * relPow * relPow + PV2AC_b_out * relPow + PV2AC_c_out);
		P_ac2bat_out_Target = 0;
	}
	else
	{	/*Target DC output power of the AC2BAT conversion pathway in AC-Charge Mode*/
		relPow = MIN(ABS(Pac_Target), P_AC2BAT_in * 1000) / P_AC2BAT_in / 1000;/*Normalized AC input power of the AC2BAT conversion pathway to cover the AC power demand*/
		//P_ac2bat_out_Target = MIN(ABS(Pac_Target), P_AC2BAT_out * 1000) - (AC2BAT_a_out * relPow * relPow + AC2BAT_b_out * relPow + AC2BAT_c_out);
		P_ac2bat_out_Target = MIN(ABS(Pac_Target), P_AC2BAT_in * 1000) - (AC2BAT_a_in * relPow * relPow + AC2BAT_b_in * relPow + AC2BAT_c_in);
		P_pv2ac_in_Target = 0;
	}
	/* P_residual for charge/discharge with deadtime to be used by following code*/
	for (n = n_dead; n > 0; n--)
	{	// update ringbuffer for dead time
		res_charge[n] = res_charge[n - 1];
		res_disch[n] = res_disch[n - 1];
		charge_ac[n] = charge_ac[n - 1];
		charge_pv[n] = charge_pv[n - 1];
	}
	res_charge[0] = MIN(P_PV, P_PV2AC_in * 1000) - P_pv2ac_in_Target; // residual power for PV2BAT pathway
	res_disch[0] = Pac_Target - P_pv2ac_out_max; // required power output AC2BAT pathway
	charge_ac[0] = P_ac2bat_out_Target + P_pv2bat_out_max; //battery charging power in ac-charging mode
	charge_pv[0] = Ppv; // time delayed PV-charge input
	
	if (Pac_Target >= 0)/* feedin */
	{	
		if ((res_charge[n_dead] > 0) && (SOC < soc_max) && !SOC_HYST) /*P_pv2ac_out >= Pac charge battery from PV*/
		{
			P_pv2bat_in = MIN(res_charge[n_dead], P_PV2BAT_in * 1000);
			/*------------- TIME DELAY----------------------------*/
			if (t_CONSTANT > 0) {/* only if time constant*/
				P_pv2bat_in = P_PV2BAT_IN_PREV + (P_pv2bat_in - P_PV2BAT_IN_PREV) * FTDE;				
				/*Limit the charging power to the current power output of the PV generator*/
				P_pv2bat_in = MIN(P_pv2bat_in, Ppv);
			}
			relPow = P_pv2bat_in / P_PV2BAT_in / 1000;
			/*idle losses covered by PV */
			/*pv2bat idle losses are not taken into account*/
			P_pv2bat_out = MAX(0, P_pv2bat_in - (PV2BAT_a_in * relPow * relPow + PV2BAT_b_in * relPow));
			/*Set power at battery*/
			P_bat = MIN(P_pv2bat_out, P_PV2BAT_out * 1000);
			P_pv2ac_in = MAX(P_PV2AC_in, Ppv - P_pv2bat_in);
			relPow = P_pv2ac_in / P_PV2AC_in / 1000;
			P_pv2ac_out = MAX(0, P_pv2ac_in - (PV2AC_a_in * relPow * relPow + PV2AC_b_in * relPow + PV2AC_c_in));
			P_pvbs = P_pv2ac_out;
			P_bat2ac_out = 0;
		}		
		else if ((res_charge[n_dead] < 0) && (SOC > soc_min)) /*discharge battery*/
		{
			/*P_bat2ac_out = Pac_Target - P_pv2ac_out_max;*/
			P_bat2ac_out = res_disch[n_dead];
			P_bat2ac_out = MIN(P_bat2ac_out, P_BAT2AC_out * 1000);
			/*------------- TIME DELAY ----------------------------*/
			if (t_CONSTANT > 0) {/* only if time constant*/
				P_bat2ac_out = P_BAT2AC_OUT_PREV + (P_bat2ac_out - P_BAT2AC_OUT_PREV) * FTDE;
				//P_BAT2AC_OUT_PREV = P_bat2ac_out;
			}
			P_bat2ac_out = MIN(P_PV2AC_out * 1000 - P_pv2ac_out_max, P_bat2ac_out);
			relPow = P_bat2ac_out / P_BAT2AC_out / 1000;
			if (Ppv > P_PV2AC_min)/*idle losses covered by PV */
			{					  /*--> no idle losses in BAT2AC*/
				P_bat2ac_in = (P_bat2ac_out + (BAT2AC_a_out * relPow * relPow + BAT2AC_b_out * relPow));
				P_bat = -P_bat2ac_in;
			}
			else
			{
				P_bat2ac_in = (P_bat2ac_out + (BAT2AC_a_out * relPow * relPow + BAT2AC_b_out * relPow + BAT2AC_c_out));
				P_bat = -P_bat2ac_in + Ppv;
			}
			/*Set power at battery*/
			P_pv2bat_in = 0;
			P_pv2ac_out = P_pv2ac_out_max;
			P_pvbs = P_bat2ac_out + P_pv2ac_out_max;
		}
		else/*Set the DC power of the battery to zero Realized AC power of the PV - battery system*/
		{
			P_bat = 0;
			P_bat2ac_out = 0;
			P_pv2bat_in = 0;
			P_pvbs = P_pv2ac_out_max;
			P_pv2ac_out = P_pv2ac_out_max;
		}
		P_ac2bat_in = 0;
	}
	else/*Pac_Target < 0*/
	{ // time delay and DT1 to be done
		if ((charge_ac[n_dead] > 0) && (SOC < soc_max) && !SOC_HYST) /*charge battery*/
		{
			if (charge_pv[n_dead] > P_PV2BAT_in*1000)
			{// max. charge from PV; rest ist PV2AC
				real_T temp;
				P_pv2bat_in = P_PV2BAT_in*1000;
				P_bat = charge_ac[n_dead];
				if (t_CONSTANT > 0)
				{/* only if control time constant is activated*/
					P_pv2bat_in = P_PV2BAT_IN_PREV + (P_pv2bat_in - P_PV2BAT_IN_PREV) * FTDE;
					/*Limit the charging power to the current power output of the PV generator might be higher due to time delay + time constant*/
					P_pv2bat_in = MIN(P_pv2bat_in, Ppv);
				}
				P_pv2ac_in = MAX(0, Ppv - P_pv2bat_in);// residual pv energy goes to AC-node
				relPow = P_pv2ac_in / P_PV2AC_in / 1000;
				P_pv2ac_out = MAX(0, P_pv2ac_in - (PV2AC_a_in * relPow * relPow + PV2AC_b_in * relPow + PV2AC_c_in));

				relPow = P_pv2bat_in / P_PV2BAT_in / 1000;
				if (P_pv2ac_in > P_PV2AC_min)/*idle losses covered by PV */
				{	/*--> no idle losses in pv2bat*/
					P_pv2bat_out = MAX(0, P_pv2bat_in - (PV2BAT_a_in * relPow * relPow + PV2BAT_b_in * relPow));/*PV2BAT no IDLE losses*/
				}
				else
				{
					P_pv2bat_out = MAX(0, P_pv2bat_in - (PV2BAT_a_in * relPow * relPow + PV2BAT_b_in * relPow + PV2BAT_c_in)) + P_pv2ac_in;
				}
				P_bat = P_pv2bat_out;
				P_ac2bat_in = 0;
				P_bat2ac_out = 0;
				P_pvbs = P_pv2ac_out;
			}
			else // PV2BAT; rest ist AC
			{
				P_pv2bat_in = charge_pv[n_dead];
				if (t_CONSTANT > 0)
				{/* only if control time constant is activated*/
					P_pv2bat_in = P_PV2BAT_IN_PREV + (P_pv2bat_in - P_PV2BAT_IN_PREV) * FTDE;
					P_pv2bat_in = MAX(0, P_pv2bat_in);					
					/*Limit the charging power to the ! CURRENT PV power output
					- necessary due to time delay + time constant*/
					P_pv2bat_in = MIN(P_pv2bat_in, Ppv);
				}
				P_pv2ac_in = MAX(0, Ppv - P_pv2bat_in);// residual PV power ? --> AC-node
				relPow = P_pv2ac_in / P_PV2AC_in / 1000;
				P_pv2ac_out = MAX(0, P_pv2ac_in - (PV2AC_a_in * relPow * relPow + PV2AC_b_in * relPow + PV2AC_c_in));

				if (P_pv2ac_in > P_PV2AC_min)/*idle losses covered by PV */
				{	/*--> no idle losses in pv2bat*/
					relPow = P_pv2bat_in / P_PV2BAT_in / 1000;
					P_pv2bat_out = MAX(0, P_pv2bat_in - (PV2BAT_a_in * relPow * relPow + PV2BAT_b_in * relPow));/*PV2BAT no IDLE losses*/
					P_ac2bat_out = 0;
				}
				else// P_pv2ac = 0 --> ac2bat>0
				{
					P_pv2bat_out = MAX(0, P_pv2bat_in - (PV2BAT_a_in * relPow * relPow + PV2BAT_b_in * relPow + PV2BAT_c_in)) + P_pv2ac_in;
					P_ac2bat_out = MIN(charge_ac[n_dead] - P_pv2bat_out, P_ac2bat_out_Target);// passt noch nicht --> Pac_out Target limitieren auf max possible
					//P_ac2bat_out = -Pac_Target;//P_ac2bat_out_Target;
					relPow = (P_AC2BAT_out > 0) ? (P_ac2bat_out / P_AC2BAT_out / 1000) : 0;
					if (Ppv > PV2BAT_c_in)
					{	
						P_ac2bat_in = P_ac2bat_out + AC2BAT_a_out * relPow * relPow + AC2BAT_b_out * relPow;// idle covered by pv2bat					
					}
					else
					{						
						P_ac2bat_in = P_ac2bat_out + AC2BAT_a_out * relPow * relPow + AC2BAT_b_out * relPow + AC2BAT_c_out;
					}
				}
				P_bat = P_pv2bat_out + P_ac2bat_out;
				P_bat2ac_out = 0;
				P_pvbs = P_pv2ac_out - P_ac2bat_in;
			}			
		}
		else
		{/* Set the DC power of the battery to zero
			   Realized AC power of the PV - battery system*/
			P_bat = 0;
			P_ac2bat_in = 0;			
			P_pv2bat_in = 0;
			P_pvbs = P_pv2ac_out_max;
			P_pv2ac_out = P_pv2ac_out_max;
		}
		P_bat2ac_out = 0;
	}
		
	if ((P_bat == 0) && (P_pvbs == 0) && (SOC <= 0)) { // Standby mode in discharged state
		/*DC and AC power consumption of the PV - battery inverter*/		
		P_pvbs = -P_SYS_SOC0_AC;
		P_bat = -MAX(0, P_SYS_SOC0_DC);
	}
	else if ((P_bat == 0) && (P_pvbs == 0) && (SOC > 0)) { //Standby mode in charged state -> can occur with activated AC-charge mode
		/*DC power consumption of the PV - battery inverter*/
		P_pvbs = -P_SYS_SOC1_AC;
		P_bat = -MAX(0, P_SYS_SOC1_DC);
	}
	else if ((P_bat == 0) && (P_pvbs !=0) && (SOC > 0)) { // changed from //Standby mode in charged state
		/*DC power consumption of the PV - battery inverter*/				
		P_bat = -MAX(0, P_SYS_SOC1_DC);
	}
	
	P_BAT_ACT = P_bat; // buffer for mdlUpdate
	/* buffers for FTDE - First order timer delay */
	//P_PV2AC_OUT_PREV = P_pv2ac_out;// not used
	P_BAT2AC_OUT_PREV = P_bat2ac_out;
	//P_AC2BAT_IN_PREV= P_ac2bat_in;// not used
	P_PV2BAT_IN_PREV = P_pv2bat_in;

	/* set output port 0 */
	y_Ppvbs = P_pvbs;
	y_Ppv2ac_out = P_pv2ac_out;
	y_Pbat2ac_out = P_bat2ac_out;
	y_Pac2bat_in = P_ac2bat_in;
	y_Ppv2bat_in = P_pv2bat_in;
	y_Pbat = P_bat;
	y_Soc = SOC;
	y_Ebat = EBAT;//Battery Energy in Ws
		
} /* end mdlOutputs */

/*
 * mdlUpdate - compute discrete states
 */
#define MDL_UPDATE
static void mdlUpdate(SimStruct* S, int_T tid)
{
	InputRealPtrsType  u0 = ssGetInputPortRealSignalPtrs(S, 0);
	real_T* y0 = ssGetOutputPortRealSignal(S, 0);
	real_T* x = ssGetDiscStates(S);
	mxDouble* parPtr;
	time_T tsample = ssGetSampleTime(S, 0);
	const mxArray* spi_params = SPI_PARAMS;
#if MX_HAS_INTERLEAVED_COMPLEX // new api with mex "-R2018a" option
	parPtr = mxGetDoubles(spi_params);
#else// old api
	parPtr = mxGetPr(spi_params);
#endif
	/* access DWork, param and state vectors */
	real_T *dwork = (real_T*)ssGetDWork(S, DWORK_NO);
	boolean_T *dwork_hyst = (boolean_T*)ssGetDWork(S, DWORK_HYST_NO);	 
	real_T SOC_hyst = parPtr[I_SOC_h];
	real_T eta_BAT = parPtr[I_ETA_BAT];
	real_T P_bat = P_BAT_ACT;
	real_T Ebat_next, cap_BAT;

	if (CAP_BAT_USR > 0)
	{
		cap_BAT = CAP_BAT_USR * 1000 * 3600;
	}
	else
	{
		cap_BAT = parPtr[I_CAP_BAT] * 1000 * 3600;
	}

	/*Change the energy content of the battery*/
	if (P_bat > 0) {//Energy in Ws
		Ebat_next = EBAT + P_bat * sqrt(eta_BAT / 100) * tsample;
	}
	else if (P_bat < 0) {
		Ebat_next = EBAT + P_bat / sqrt(eta_BAT / 100) * tsample;
	}
	else {
		Ebat_next = EBAT;
	}
	
	/*Calculate the state of charge of the battery*/

	SOC = Ebat_next / cap_BAT; 
	/*Adjust the hysteresis threshold to avoid alternation between charging
	and standby mode due to the DC power consumption of the	PV - battery inverter*/
	SOC_HYST = ((SOC_HYST == 1) && (SOC > SOC_hyst)) || (SOC >= 1);
	EBAT = Ebat_next;
}

static void mdlTerminate(SimStruct* S)
{
	/* nothing to do */
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif