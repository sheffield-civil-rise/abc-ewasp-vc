/***********************************************************************
 * This file is part of the CARNOT Blockset.
 * Copyright (c) 1998-2022, Solar-Institute Juelich of the FH Aachen.
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
 ***********************************************************************
 * list of authors
 *      tw : Thomas Wenzel
 *      hf : Bernd Hafner
 *
 * Version  Author  Changes                                     Date
 * 0.01.0   tw      created M-script                            18oct1999
 *                  based on the M-Skripte metcalc.m of Markus Werner
 * 0.02.0   tw      created S-function                          25nov1999
 * 4.1.0    hf      using carlib functions for solar position   02dec2008
 * 5.1.0    hf      changed unknown global-diffuse correlation  01jun2012
 *                  to the Orgill and Hollands Model (1977) 
 * 7.1.0    hf      solar position from carlib function         23apr2022
 * 7.1.1    hf      changed number of inports and outports      23apr2022
 *                  added clearness index as output
 ***********************************************************************
 *  F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * [Idir Idfu SunAngle Zenith Azimuth Clearness] = 
 *       metrad_s(Iglob, lat, long, long0)
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * FUNCTION: 
 * Calculate direct and diffuse solar radiation with the input of the global
 * solar radiaton. The model uses the Orgill & Hollands correlation, 
 * published by Duffie, Beckmann Solar Engineering 2006
 * INPUT
 *  Iglob    : global solar radiation on the horizontal surface in W/m²
 *  lat      : geographical latitude in degree (-90..90,North positiv)
 *  long     : longitude in degree (-180..180, West positiv)
 *  long0    : longitude of the timezone in degree (CET = -15)
 * 
 * OUTPUT
 *
 *  Idir     : direct solar radiation on the horizontal in W/m²
 *  Idfu     : diffuse solar radiation on the horizontal in W/m²
 *  SunAngle : solar height in degree (0° = at horizon)
 *  Zenith   : zenith angle of the sun in degree
 *  Azimuth  : azimuth anlge of the sun in degree (0 = south, west positive)
 *  Clearness: clearness index of the sky, ratio of global to
 *             extraterrestrial radiaton on the horizontal
 */

/*some defines for access to the parameters */
/*define PARA1 (*mxGetPr(ssGetSFcnParam(S,0))) */
#define N_PARA                              0
/*some defines for access to the input vector */
#define IGLOB          (*u0Ptrs[0])
#define LATITUDE       (*u1Ptrs[0])
#define LONGITUDE      (*u2Ptrs[0])    
#define LONGITUDENULL  (*u3Ptrs[0])    
#define N_INPORT          4         /* number of input ports */
/*some defines for access to the output vector */
#define IDIR       y0[0]    
#define IDFU       y1[0]    
#define SUNANGLE   y2[0]    
#define ZENITH     y3[0]    
#define AZIMUTH    y4[0]    
#define CLEARNESS  y5[0]    
#define N_OUTPORT   6               /* number of output ports */
/* other defines */
#define TIME     ssGetT(S)  /* simulation time */
#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME metrad_s
/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions. math.h is for function sqrt
 */
#include "simstruc.h"
#include <math.h>
#include "carlib.h"

/*====================*
 * S-function methods *
 *====================*/
/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T n;
    
    ssSetNumSFcnParams(S, N_PARA);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {   /* Return if number of expected != number of actual parameters */
        return;
    }
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, N_INPORT)) return;  
    for (n = 0; n < N_INPORT; n++)
    {
        ssSetInputPortWidth(S, n, 1);
        ssSetInputPortDirectFeedThrough(S, n, 1);
    }
    
    if (!ssSetNumOutputPorts(S, N_OUTPORT)) return;
    for (n = 0; n < N_OUTPORT; n++)
    {
        ssSetOutputPortWidth(S, n, 1);
    }
    
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    /* Take care when specifying exception free code - see sfuntmpl.doc */
#ifdef  EXCEPTION_FREE_CODE
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
#endif
}

/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}

#undef MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
  /* Function: mdlInitializeConditions ========================================
   * Abstract:
   *    In this function, you should initialize the continuous and discrete
   *    states for your S-function block.  The initial states are placed
   *    in the state vector, ssGetContStates(S) or ssGetRealDiscStates(S).
   *    You can also perform any other initialization activities that your
   *    S-function may require. Note, this routine will be called at the
   *    start of simulation and if it is present in an enabled subsystem
   *    configured to reset states, it will be call when the enabled subsystem
   *    restarts execution to reset the states.
   */
  static void mdlInitializeConditions(SimStruct *S)
  {
  }
#endif /* MDL_INITIALIZE_CONDITIONS */

#undef MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
  static void mdlStart(SimStruct *S)
  {
  }
#endif /*  MDL_START */

/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType u0Ptrs = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType u1Ptrs = ssGetInputPortRealSignalPtrs(S,1);
    InputRealPtrsType u2Ptrs = ssGetInputPortRealSignalPtrs(S,2);
    InputRealPtrsType u3Ptrs = ssGetInputPortRealSignalPtrs(S,3);
    
    real_T *y0 = ssGetOutputPortRealSignal(S,0);
    real_T *y1 = ssGetOutputPortRealSignal(S,1);
    real_T *y2 = ssGetOutputPortRealSignal(S,2);
    real_T *y3 = ssGetOutputPortRealSignal(S,3);
    real_T *y4 = ssGetOutputPortRealSignal(S,4);
    real_T *y5 = ssGetOutputPortRealSignal(S,5);
    
    real_T time = TIME;
    real_T Iglobal = IGLOB;             /* global radiation */
    real_T latitude = LATITUDE;         /* latitude */
    real_T longitude = LONGITUDE;       /* longitude */
    real_T longitude0 = LONGITUDENULL;  /* timezone */
    real_T solpos[5];
    real_T ClearIndex = 0.0;            /* clearness index */
    real_T zen, azi, sangle, Iextra;

    /* get the solar position from carlib function solar_position */
    solar_position(solpos, time, latitude, longitude, longitude0);
    zen = solpos[0];                /* zenith angle */
    azi = solpos[1];                /* azimut angle */
    sangle = RAD2DEG*zen;           /* solar zenith in degree */
    ZENITH = sangle;                /* output solar zenith angle */
    sangle = 90.0-sangle;           /* solar height */
    SUNANGLE = sangle;              /* output solar height */
    AZIMUTH = RAD2DEG*azi;          /* output solar azimuth angle */
    
    /* calulate only if it is worthwhile to do it */
    if (sangle > 1.0 && Iglobal > 0.01) /* if there is sun and global radiation */
    {
        /* extraterrestrial radiation is on normal surface */
        /* clearness index is defined by the ratio of radiaton on 
         * a horizontal surface so multiply with cos(zenith)
         */
        Iextra = extraterrestrial_radiation(time)*cos(zen);
        /* determine radiation on horizontal surface */
        if (Iextra > 0.01)      /* there extraterrestrial radiation */
        {
           ClearIndex = Iglobal/Iextra;
           ClearIndex = min(1.0, ClearIndex);   /* upper limit is 1.0 */
           /* Orgill & Hollands correlation 
            * from Duffie, Beckmann Solar Engineering 2006 */
            if (ClearIndex <= 0.35)
                IDFU = Iglobal * (1 - 0.249 * ClearIndex);
            else if (ClearIndex <= 0.75)
                IDFU = Iglobal * (1.557 - 1.84 * ClearIndex);
            else
                IDFU = Iglobal * 0.177;
        } 
        else                    /* no extraterrestrial radiaton */
        {
            IDFU = 0.0;
        }   
        IDIR = Iglobal - IDFU;  /* output direct radiation */
    }
    else                        /* (almost) no radiation or low sun */
    {
        IDFU = Iglobal;         /* diffuse radiation is the global rad. */
        IDIR = 0.0;             /* direct radiation is 0 */
    }
    CLEARNESS = ClearIndex;
} /* end mdloutputs */


#undef MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
  /* Function: mdlUpdate ======================================================
   * Abstract:
   *    This function is called once for every major integration time step.
   *    Discrete states are typically updated here, but this function is useful
   *    for performing any tasks that should only take place once per
   *    integration step.
   */
  static void mdlUpdate(SimStruct *S, int_T tid)
  {
  }
#endif /* MDL_UPDATE */


#undef MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
  /* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
  static void mdlDerivatives(SimStruct *S)
  {
  }
#endif /* MDL_DERIVATIVES */

/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlInitializeConditions, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}

/*======================================================*
 * See sfuntmpl.doc for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

