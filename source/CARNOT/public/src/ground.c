/***********************************************************************
 * This file is part of the CARNOT Blockset.
 *
 *  CARNOT is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as 
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  CARNOT is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy (copying_lesser.txt) of the GNU Lesser
 *  General Public License along with CARNOT.
 *  If not, see <http://www.gnu.org/licenses/>.
 *
 ***********************************************************************
 *  M O D E L    O R    F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * underground heat exchanger pipe "ground collector" for heat pumps
 *
 * Syntax  [sys, x0] = ground(t,x,u,flag)
 *
 * Version  Author              Changes                             Date
 * 0.1.0    Bernd Hafner (hf)   created                             30mar98
 * 0.5.0    hf              toolbox name changed to CARNOT          30apr98
 * 0.5.1    hf              material properties from carlib         20mai98
 * 0.7.0    hf              switch pressure calculation             12jun98
 *                          ID <=10000 no pressure calculation
 *                          ID <=20000 only pressure drop
 *                          ID > 20000 pressure drop and static pressure
 * 0.7.1    hf              correct energy balance of heat          30jun98
 *                          exchanger before setting output vector
 * 0.8.0    hf              new pressure drop calculation           09jul98
 *                          dp = dp0 + dp1*mdot + dp2*mdot^2
 *                          function has new outputs dp0, dp1, dp2
 * 6.1.0    aw              added SimStateCompiliance               09oct17
 *                          ssSupportsMultipleExecInstances enabled
 *                          RWork and IWork vectors converted to
 *                          DWork vectors
 *                          converted to level 2 S-function
 *
 * Copyright (c) 1998 Solar-Institut Juelich, Germany
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  D E S C R I P T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * modified from mex file for multi-input, multi-output state-space system.
 *         
 * The storage is devided into ZNODES nodes in z-direction, RNODES nodes in
 * radial direction and 6 nodes in angular direction.
 * The energy-balance for every node is:
 *
 * rho*c*dT/dt =  cond/(dz*Dz) * (Tnode_up    + Tnode_down  - 2*Tnode)
 *              + cond/(dx*Dx) * (Tnode_east  + Tnode_west  - 2*Tnode)
 *              + cond/(dy*Dy) * (Tnode_north + Tnode_south - 2*Tnode)
 *
 *  symbol      used for                                        unit
 *	cond        effective heat conductivity                     W/(m*K)
 *  c           heat capacity                                   J/(kg*K)
 *  dx          x-extension of node                             m
 *  dy          y-extension of node                             m
 *  dz          z-extension of node                             m
 *  Dx          x-distance between two nodes                    m
 *  Dy          y-distance between two nodes                    m
 *  Dz          z-distance between two nodes                    m
 *  rho         density                                         kg/m^3
 *  T           temperature                                     K
 *  t           time                                            s
 *
 * Because we need to know the temperature at fixed places inside the
 * storage, a number of measurement points (M_PTS) is placed at
 * equidistant locations inside the storage, no matter how many nodes
 * are used for the calculation.
 *
 * The output vector y[] starts with the top-temperature (y[0]) and
 * ends with the bottom-temperature (y[M_PTS]).
 *
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Definiton of inputs and outputs 
 *
 * structure of u (input vector)
 *  see defines below
 *
 *
 * structure of y (output vector): all temperatures (T) in degree centigrade
 *  index       use                                         
 *  0           T 0.(top) measurement point, inlet column
 *  1           T 1. measurement point (MP), inlet column
 *  ...
 *  M_PTS-1     T M_PTS (lowest) MP, inlet column
 *
 *  M_PTS       T 0. MP, at center
 *  ...
 *  2*M_PTS-1   T M_PTS (lowest)MP, at center
 *
 *  2*M_PTS     T 0. MP, at outlet
 *  ...
 *  3*M_PTS-1   T M_PTS (lowest)MP, at outlet
 *
 *  3*M_PTS     outlet temperature of fluid
 *  3*M_PTS+1   pressure at outlet in Pascal
 *  3*M_PTS+2   constant pressure drop term
 *  3*M_PTS+3   linear pressure drop term
 *  3*M_PTS+4   quadratic pressure drop term
 *
 *
 * parameters
 *  see defines below
 *  
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * structure of the temperature-array (state-space vector x)
 *
 *  temperature(slice, radial_pos, angular_pos)
 *   = x(6*RNODES*slice + 6*radial_pos + angular_pos)
 */


#define S_FUNCTION_NAME ground
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "tmwtypes.h"
#include "carlib.h"
#include <math.h>

#ifndef PI
    #define PI       3.14159265358979
#endif

/* 
 * x-axis is perpendicular to pipes
 * y-axis is parallel to pipes
 * z-axis is vertical downwards
 *
 * all temperatures T are in degree centigrade
 *
 * filling is between and above pipes 
 */

#define X_STORE    *mxGetPr(ssGetSFcnParam(S,0))  /* x - extension [m] */
#define Y_STORE    *mxGetPr(ssGetSFcnParam(S,1))  /* y - extension [m] */
#define Z_STORE    *mxGetPr(ssGetSFcnParam(S,2))  /* z - extension [m] */
#define CAP_GROUND *mxGetPr(ssGetSFcnParam(S,3))  /* capacity ground J/(kg*K) */
#define CON_GROUND *mxGetPr(ssGetSFcnParam(S,4))  /* conductivity ground W/(m*K) */
#define D_PIPE     *mxGetPr(ssGetSFcnParam(S,5))  /* diameter of pipe [m] */
#define K_PIPE     *mxGetPr(ssGetSFcnParam(S,6))  /* roughness of pipe [m] */
#define N_PIPE     *mxGetPr(ssGetSFcnParam(S,7))  /* number of pipes */
#define Z_PIPE     *mxGetPr(ssGetSFcnParam(S,8))  /* z-position of pipe [m] */
#define CAP_FILL   *mxGetPr(ssGetSFcnParam(S,9))  /* capacity filling J/(kg*K) */
#define CON_FILL   *mxGetPr(ssGetSFcnParam(S,10)) /* cond. filling W/(m*K) */
#define T0         *mxGetPr(ssGetSFcnParam(S,11)) /* initial temperature */
#define REFINE     *mxGetPr(ssGetSFcnParam(S,12)) /* refine (2 half grid spacing)*/
#define M_PTS      *mxGetPr(ssGetSFcnParam(S,13)) /* number T measurement points */
#define N_PARAMETER                    14   /* number of parameters */
 
#define T_TOP_PIPE  (*u[0])     /* T above pipes (ambient or building) */
#define U_TOP_PIPE  (*u[1])     /* heat transfer above pipes W/(m^2*K) */
#define I_TOP_PIPE  (*u[2])     /* radiation on surface above pipes W/m^2 */
#define T_TOP_OUT   (*u[3])     /* T above earth outside of pipe-section */
#define U_TOP_OUT   (*u[4])     /* heat transfer outside of pipe-section */
#define I_TOP_OUT   (*u[5])     /* radiation outside of pipe-section */
#define FLOW_ID     (*u[6])     /* identifier of entering flow */
#define TFLUIDIN    (*u[7])     /* inlet temperature heat exchanger */
#define MDOT        (*u[8])     /* massflow in heat exchanger */
#define PRESS       (*u[9])     /* pressure */
#define FLUID_ID    (*u[10])    /* fluid ID */
#define PERCENTAGE  (*u[11])    /* mixture */
#define D_INLET     (*u[12])    /* diameter at inlet */
#define DPCON       (*u[13])    /* constant term in pressure drop */
#define DPLIN       (*u[14])    /* linear term in pressure drop */
#define DPQUA       (*u[15])    /* quadratic term in pressure drop */
#define T_OUTSIDE   (*u[16])    /* temperature at top boundary */
#define T_BOTTOM    (*u[17])    /* temperature at bottom boundary */
#define N_INPUTS      18


#define SEGMENTS   5        /* number of nodes for one pipe */
#define PIPENODES  (npipe*SEGMENTS*refine)  /* number of pipenodes */

#define DWORK_TFLUID_NO            0 /* fluid temperature in pipe is stored in DWork */
#define DWORK_TCON_G_NO            1 /* temperature conductivity ground */
#define DWORK_TCON_F_NO            2 /* temperature conductivity filling */
#define DWORK_OLDTIME_NO           3
#define DWORK_OLDENERGY_NO         4
#define DWORK_XNODES_NO            5 /* number of nodes in x-direction */
#define DWORK_YNODES_NO            6 /* number of nodes in y-direction */
#define DWORK_ZNODES_NO            7 /* number of nodes in z-direction */

#define TFLUID(n)   DWork_TFluid[n] /* fluid temperature in pipe is stored in RWork */
#define TCON_G      DWork_TCON_G[0] /* temperature conductivity ground */
#define TCON_F      DWork_TCON_F[0] /* temperature conductivity filling */
#define OLDTIME     DWork_OLDTIME[0]
#define OLDENERGY   DWork_OLDENERGY[0]

#define XNODES      DWork_XNODES[0]    /* number of nodes in x-direction */
#define YNODES  	DWork_YNODES[0]    /* number of nodes in y-direction */
#define ZNODES  	DWork_ZNODES[0]    /* number of nodes in z-direction */

#define TIME        ssGetT(S)

#define TP      x[XNODES*YNODES*nz+XNODES*ny+nx]     /* node */
#define TEAST   x[XNODES*YNODES*nz+XNODES*ny+nx-1]   /* backward in x */
#define TWEST   x[XNODES*YNODES*nz+XNODES*ny+nx+1]   /* foreward in x */
#define TUP     x[XNODES*YNODES*(nz-1)+XNODES*ny+nx] /* upward in z */
#define TDOWN   x[XNODES*YNODES*(nz+1)+XNODES*ny+nx] /* downward in z */
#define TSOUTH  x[XNODES*YNODES*nz+XNODES*(ny-1)+nx] /* backward in y */
#define TNORTH  x[XNODES*YNODES*nz+XNODES*(ny+1)+nx] /* foreward in y */

#define DTDT    dx[XNODES*YNODES*nz+XNODES*ny+nx]    /* dT/dt */

#define ENERGY  x[XNODES*YNODES*ZNODES] /* energy input by heat exchanger */
#define DEDT    dx[XNODES*YNODES*ZNODES]


double diameterchange(double dpipe, double dinlet)
/* pressure drop for diameter change at pipe inlet
 * dpipe is inner pipe diameter, dinlet diameter of last piece
 * from VDI Waermeatlas, 1988
 */
{   double k;
    if (dinlet-0.001 > dpipe)
	{
        k = 0.5;    /* entry from tank to pipe */
	}
    else if (dpipe > dinlet+0.001)
	{
        k = square(1.0-square(dpipe/MAX(dinlet, 0.001)));
	}
    else 
	{
        k = 0.0;
	}
    return k;
}



/*
 * mdlInitializeSizes - initialize the sizes array
 *
 * The sizes array is used by SIMULINK to determine the S-function block's
 * characteristics (number of inputs, outputs, states, etc.).
 */

static void mdlInitializeSizes(SimStruct *S)
{
    double zpipe  = Z_PIPE;
    double zstore = Z_STORE;
    int    refine = (int)REFINE;
    int    npipe  = (int)N_PIPE;
    double h;
    int    xnodes, ynodes, znodes;

    xnodes = refine * (4 + max(1, 2*npipe-1));
    if (npipe == 0)
    {
        ynodes = refine * 5;
    }
    else
    {
        ynodes = refine * (4+SEGMENTS);
    }
    znodes = 2;
    h = zpipe;
    while (h < zstore)
    {
        h += (znodes-1) * zpipe/2.0;
        znodes++;
    }
    znodes = refine*znodes;

    ssSetNumSFcnParams(S, N_PARAMETER);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        /* Return if number of expected != number of actual parameters */
        return;
    }
    /* number of continuous states */
    ssSetNumContStates(S, xnodes*ynodes*znodes+1);
    ssSetNumDiscStates(S, 0);      /* number of discrete states */
    if (!ssSetNumInputPorts(S, 1))
	{
		return;
	}
    ssSetInputPortWidth(S, 0, N_INPUTS);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    
    if (!ssSetNumOutputPorts(S, 1))
	{
		return;
	}
    ssSetOutputPortWidth(S, 0, 3*(int_T)M_PTS+5);

    ssSetNumSampleTimes(S, 1);     /* number of sample times */
    /* number real work vector elements */
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0); /* number of integer work vector elements */
    ssSetNumPWork(S, 0); /* number of pointer work vector elements */
    
    
    ssSetNumDWork(S, 8);
    ssSetDWorkWidth(S, DWORK_TFLUID_NO, npipe*SEGMENTS*refine+1);
    ssSetDWorkDataType(S, DWORK_TFLUID_NO, SS_DOUBLE);
    ssSetDWorkName(S, DWORK_TFLUID_NO, "DWORK_TFLUID");
    ssSetDWorkUsageType(S, DWORK_TFLUID_NO, SS_DWORK_USED_AS_DSTATE);
    
    ssSetDWorkWidth(S, DWORK_TCON_G_NO, 1);
    ssSetDWorkDataType(S, DWORK_TCON_G_NO, SS_DOUBLE);
    ssSetDWorkName(S, DWORK_TCON_G_NO, "DWORK_TCON_G");
    ssSetDWorkUsageType(S, DWORK_TCON_G_NO, SS_DWORK_USED_AS_DSTATE);
    
    ssSetDWorkWidth(S, DWORK_TCON_F_NO, 1);
    ssSetDWorkDataType(S, DWORK_TCON_F_NO, SS_DOUBLE);
    ssSetDWorkName(S, DWORK_TCON_F_NO, "DWORK_TCON_F");
    ssSetDWorkUsageType(S, DWORK_TCON_F_NO, SS_DWORK_USED_AS_DSTATE);
    
    ssSetDWorkWidth(S, DWORK_OLDTIME_NO, 1);
    ssSetDWorkDataType(S, DWORK_OLDTIME_NO, SS_DOUBLE);
    ssSetDWorkName(S, DWORK_OLDTIME_NO, "DWORK_OLDTIME");
    ssSetDWorkUsageType(S, DWORK_OLDTIME_NO, SS_DWORK_USED_AS_DSTATE);
    
    ssSetDWorkWidth(S, DWORK_OLDENERGY_NO, 1);
    ssSetDWorkDataType(S, DWORK_OLDENERGY_NO, SS_DOUBLE);
    ssSetDWorkName(S, DWORK_OLDENERGY_NO, "DWORK_OLDENERGY");
    ssSetDWorkUsageType(S, DWORK_OLDENERGY_NO, SS_DWORK_USED_AS_DSTATE);
    
    ssSetDWorkWidth(S, DWORK_XNODES_NO, 1);
    ssSetDWorkDataType(S, DWORK_XNODES_NO, SS_UINT32);
    ssSetDWorkName(S, DWORK_XNODES_NO, "DWORK_XNODES");
    ssSetDWorkUsageType(S, DWORK_XNODES_NO, SS_DWORK_USED_AS_DSTATE);
    
    ssSetDWorkWidth(S, DWORK_YNODES_NO, 1);
    ssSetDWorkDataType(S, DWORK_YNODES_NO, SS_UINT32);
    ssSetDWorkName(S, DWORK_YNODES_NO, "DWORK_YNODES");
    ssSetDWorkUsageType(S, DWORK_YNODES_NO, SS_DWORK_USED_AS_DSTATE);
    
    ssSetDWorkWidth(S, DWORK_ZNODES_NO, 1);
    ssSetDWorkDataType(S, DWORK_ZNODES_NO, SS_UINT32);
    ssSetDWorkName(S, DWORK_ZNODES_NO, "DWORK_ZNODES");
    ssSetDWorkUsageType(S, DWORK_ZNODES_NO, SS_DWORK_USED_AS_DSTATE);
    
    
    
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    ssSetSimStateVisibility(S, 1);
    
    ssSupportsMultipleExecInstances(S, true);
}


/*
 * mdlInitializeSampleTimes - initialize the sample times array
 *
 * This function is used to specify the sample time(s) for your S-function.
 * If your S-function is continuous, you must specify a sample time of 0.0.
 * Sample times must be registered in ascending order.
 */

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


/*
 * mdlInitializeConditions - initialize the states
 *
 * In this function, you should initialize the continuous and discrete
 * states for your S-function block.  The initial states are placed
 * in the x0 variable.  You can also perIWork any other initialization
 * activities that your S-function may require.
 */

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    double t0 = T0;             /* initial temperature */
    double zstore = Z_STORE;
    double zpipe  = Z_PIPE;
    double cap_g = CAP_GROUND;  /* capacity of ground [J/(kg*K)] */
    double con_g = CON_GROUND;  /* conductivity of ground [W/(m*K)] */
    double cap_f = CAP_FILL;    /* heat cap. filling [J/(kg*K)] */
    double con_f = CON_FILL;    /* heat cond. filling  [W/(m*K)] */
    int    npipe  = (int)N_PIPE;
    int    refine = (int)REFINE;
    
	real_T   *DWork_TFluid     = (real_T   *)ssGetDWork(S, DWORK_TFLUID_NO);
    real_T   *DWork_TCON_G     = (real_T   *)ssGetDWork(S, DWORK_TCON_G_NO);
    real_T   *DWork_TCON_F     = (real_T   *)ssGetDWork(S, DWORK_TCON_F_NO);
    real_T   *DWork_OLDTIME    = (real_T   *)ssGetDWork(S, DWORK_OLDTIME_NO);
    real_T   *DWork_OLDENERGY  = (real_T   *)ssGetDWork(S, DWORK_OLDENERGY_NO);
    uint32_T *DWork_XNODES     = (uint32_T *)ssGetDWork(S, DWORK_XNODES_NO);
    uint32_T *DWork_YNODES     = (uint32_T *)ssGetDWork(S, DWORK_YNODES_NO);
    uint32_T *DWork_ZNODES     = (uint32_T *)ssGetDWork(S, DWORK_ZNODES_NO);
    
    real_T *x0   = ssGetContStates(S);

    int n;
    double h;

    
    /* temperature conductivities */
    TCON_F = con_f/cap_f;
    TCON_G = con_g/cap_g;

    /* number of x and y nodes (4 outside of pipe section) */
    XNODES = refine * (4 + max(1, 2*npipe-1));
    if (npipe == 0)
    {
        YNODES = refine * 5;
    }
    else
    {
        YNODES = refine * (4+SEGMENTS);
    }

    /* number of z nodes */
    ZNODES = 2;
    h = zpipe;
    while (h < zstore)
    {
        h += (ZNODES-1) * zpipe/2.0;
        ZNODES++;
    }
    ZNODES = refine*ZNODES;

    for (n = 0; n < XNODES*YNODES*ZNODES; n++)
    {
        x0[n] = t0;     /* state-vector is initialized with T0 */
    }

    for (n = 0; n <= PIPENODES; n++)
    {
        TFLUID(n) = t0; /* Tfluid (DWork) is initialized with T0 */
    }

    OLDTIME = TIME;
    OLDENERGY = 0.0;
}


/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType  u    = ssGetInputPortRealSignalPtrs(S, 0);
    real_T            *y    = ssGetOutputPortRealSignal(S, 0);
    
    double ystore = Y_STORE;
    double dpipe  = D_PIPE;
    double p      = PRESS;
    double rough  = K_PIPE;
    double time   = TIME;
    double dplin  = 0.0;
    double dpqua  = 0.0;

    int    npipe  = (int)N_PIPE;
    int    mpoints = (int)M_PTS;  /* numer of measurement points */
    int    refine = (int)REFINE;
    

    real_T   *DWork_TFluid     = (real_T   *)ssGetDWork(S, DWORK_TFLUID_NO);
    real_T   *DWork_TCON_G     = (real_T   *)ssGetDWork(S, DWORK_TCON_G_NO);
    real_T   *DWork_TCON_F     = (real_T   *)ssGetDWork(S, DWORK_TCON_F_NO);
    real_T   *DWork_OLDTIME    = (real_T   *)ssGetDWork(S, DWORK_OLDTIME_NO);
    real_T   *DWork_OLDENERGY  = (real_T   *)ssGetDWork(S, DWORK_OLDENERGY_NO);
    uint32_T *DWork_XNODES     = (uint32_T *)ssGetDWork(S, DWORK_XNODES_NO);
    uint32_T *DWork_YNODES     = (uint32_T *)ssGetDWork(S, DWORK_YNODES_NO);
    uint32_T *DWork_ZNODES     = (uint32_T *)ssGetDWork(S, DWORK_ZNODES_NO);
    
    real_T *x   = ssGetContStates(S);
    

    double interval_size, flimit, rho, vis, v, re, fh, k, leq, tmean, hh;
    int    n, nx, ny, nz;
    
    /* friction, calculate only if there is massflow */
    if (MDOT > 0.0 && FLOW_ID > 10000.0)  {

        /* average pipe temperature */
        tmean = 0.0;
        for (n = 0; n < PIPENODES; n++)
        {
            tmean += TFLUID(n);
        }
        tmean = tmean/(double)PIPENODES;

        flimit = 0.1*pow(rough/dpipe,0.22); /* lowest value of fh */
        rho = density(FLUID_ID, PERCENTAGE, tmean, PRESS);
        vis = viscosity(FLUID_ID, PERCENTAGE, tmean, PRESS);
        v = 4.0*MDOT/(rho*PI*dpipe*dpipe);
        re = v*dpipe/vis;
        fh = 64.0/re;
        leq = ystore*npipe;

        /* friction from big diameter to pipe diameter */
        k = diameterchange(dpipe, D_INLET);

        /* developing flow correction */
        /* from Bohl: technische Stroemungslehre, Vogel Verlag */
        if (re < 2000.0)
        {
            fh = max(flimit, 64.0/re);
            k += 1.2;
            leq += 60.0*npipe*dpipe;
        }
        else if (re < 3000.0)
        {
            fh = max(flimit, 3.2e-2);
            k += 1.2 - 0.00114*(re-2000.0) + 2.0*npipe;
        }
        else
        {
            fh = max(flimit, (re <= 7000.0)? 3.2e-2 : 0.25*pow(re, -0.23));
            k += 0.06 + 2.0*npipe;
        }

        if (re < 100.0)  /* low reynolds number correction */
        {
            k = 100.0*k/max(1.0,re);
        }

        /* printf("tmean %g vis %g, v %g re %g leq %g rho %g, dia %g fh %g k %g flimit %g \n",
         tmean, vis, v, re, leq, rho, dia, fh, k, flimit); */

        /* sum of pressure losses */
        hh = rho*v*v*0.5;
        p -= (fh*leq/dpipe+k)*hh;
        if (re < 2000.0)
        {
            dplin = fh*leq/dpipe*hh/MDOT;
            dpqua = k*hh/(MDOT*MDOT);
        }
        else
        {
            dpqua = (fh*leq/dpipe+k)*hh/(MDOT*MDOT);
            dplin = 0.0;
        }

    } /* end if mdot > 0 */

    /* set temperature of every measurement-point from bottom (0) to top */
    interval_size = (double)ZNODES/(double)mpoints; /* nodes in measurement point */

    for(n = 0; n < mpoints; n++)
    {
        nz = (int)((double)n*interval_size+0.5);

        nx = 2*refine;
        ny = 2*refine;
        y[n] = TP;

        nx = XNODES/2;
        ny = YNODES/2;
        y[n+mpoints] = TP;

        nx = XNODES - 2*refine - 1;
        ny = YNODES - 2*refine - 1;
        y[n+2*mpoints] = TP;
    }

    /* temperatures and pressures */
    if (MDOT > 0.0 && time > OLDTIME)
    {
        TFLUID(PIPENODES) = TFLUIDIN-(ENERGY-OLDENERGY)/(time-OLDTIME);
        OLDENERGY = ENERGY;
    }
    y[3*mpoints]   = TFLUID(PIPENODES);
    y[3*mpoints+1] = p;
    y[3*mpoints+2] = DPCON;
    y[3*mpoints+3] = dplin + DPLIN;
    y[3*mpoints+4] = dpqua + DPQUA;

    OLDTIME = time;
} /* end mdlOutputs */



#define MDL_DERIVATIVES 
/*
 * mdlDerivatives - compute the derivatives
 *
 * In this function, you compute the S-function block's derivatives.
 * The derivatives are placed in the dx variable.
 *
 */
static void mdlDerivatives(SimStruct *S)
{
    InputRealPtrsType  u    = ssGetInputPortRealSignalPtrs(S, 0);
    /* get model parameters with ssGetParam(S), see define at top of file */
    double xstore = X_STORE;
    double ystore = Y_STORE;
    double zstore = Z_STORE;
    double zpipe  = Z_PIPE;
    double toutside = T_OUTSIDE;
    double tbottom = T_BOTTOM;
    double dpipe  = D_PIPE;
    double cap_g = CAP_GROUND;  /* capacity of ground [J/(kg*K)] */
    double cap_f = CAP_FILL;    /* heat cap. filling [J/(kg*K)] */
    int    npipe  = (int)N_PIPE;
    int    refine = (int)REFINE;

    real_T   *DWork_TFluid     = (real_T   *)ssGetDWork(S, DWORK_TFLUID_NO);
    real_T   *DWork_TCON_G     = (real_T   *)ssGetDWork(S, DWORK_TCON_G_NO);
    real_T   *DWork_TCON_F     = (real_T   *)ssGetDWork(S, DWORK_TCON_F_NO);
    real_T   *DWork_OLDTIME    = (real_T   *)ssGetDWork(S, DWORK_OLDTIME_NO);
    real_T   *DWork_OLDENERGY  = (real_T   *)ssGetDWork(S, DWORK_OLDENERGY_NO);
    uint32_T *DWork_XNODES     = (uint32_T *)ssGetDWork(S, DWORK_XNODES_NO);
    uint32_T *DWork_YNODES     = (uint32_T *)ssGetDWork(S, DWORK_YNODES_NO);
    uint32_T *DWork_ZNODES     = (uint32_T *)ssGetDWork(S, DWORK_ZNODES_NO);
    
    real_T *x   = ssGetContStates(S);
    real_T *dx  = ssGetdX(S);

    double ls, ln, lu, ld, le, lw, d_x, dy, dz, dxw, dxe, dyn, dys, dzu, dzd;
    double uhx, cp, heatex, dxcenter, dycenter, dztop, Apipe, h;
    double tbound, capaf;
    int    i, nz, nx, ny, dir;

    cp = heat_capacity (FLUID_ID, PERCENTAGE, TFLUIDIN, PRESS);
    Apipe = PI*dpipe*dpipe*0.25*ystore*npipe/PIPENODES;

    /* start of main calculation loop */

    dxcenter = xstore/(XNODES-4*refine);
    dycenter = ystore/(YNODES-4*refine);
    dztop    = 0.25*zpipe/refine; /* half node distance */
    dzd      = dztop;             /* distance to next node downwards */
    dz       = 2.0*dztop;         /* z-extension of node */

    h = 0.0; /* relative depth of layer */

    for (nz = 0; nz < ZNODES; nz++) 
    {
        dzu = dzd;   /* distance to next node upwards */

        if (nz < 3)
        {
            dzd = dz;
        }
        else
        {
            dz += dztop;
            dzd = 2.0*dz - dzu;
        }

        /*    printf("nz %i dz %g, dzu %g, dzd %g\n", nz, dz, dzu, dzd);
        */

        /* boundary temperature linear interpolated between top and bottom */
        tbound = toutside*(1.0-h) + tbottom*h;
        h += dz/zstore;

        for (ny = 0; ny < YNODES; ny++) 
        {
            if (ny == 0)
            {
                dy  = 1.5*dycenter; /* y-extension of node */
                dys = 2.0*dycenter; /* y-distance to south node */
                dyn = dycenter;     /* y-distance to north node */
            }
            else if (ny == YNODES-1)
            {
                dy  = 1.5*dycenter; /* y-extension of node */
                dys = dycenter;     /* y-distance to south node */
                dyn = 2.0*dycenter; /* y-distance to north node */
            }
            else
            {
                dy = dycenter;      /* y-extension of node */
                dys = dycenter;     /* y-distance to south node */
                dyn = dycenter;     /* y-distance to north node */
            }

            for (nx = 0; nx < XNODES; nx++) 
            {
                if (nx == 0)
                {
                    d_x = 1.5*dxcenter;  /* x-extension of node */
                    dxe = 2.0*dxcenter;  /* x-distance to east node */
                    dxw = dxcenter;      /* x-distance to west node */
                }
                else if (nx == XNODES-1)
                {
                    d_x  = 1.5*dxcenter; /* x-extension of node */
                    dxe = dxcenter;      /* x-distance to east node */
                    dxw = 2.0*dycenter;  /* x-distance to west node */
                }
                else
                {
                    d_x = dxcenter;      /* x-extension of node */
                    dxe = dycenter;      /* x-distance to east node */
                    dxw = dycenter;      /* x-distance to west node */
                }

                DTDT = 0.0;

                le = TCON_G/(d_x*dxe);
                lw = TCON_G/(d_x*dxw);
                ln = TCON_G/(dy*dyn);
                ls = TCON_G/(dy*dys);
                lu = TCON_G/(dz*dzu);
                ld = TCON_G/(dz*dzd);


/*    printf("nx %i, ny %i, nz %i, d_x %g, dxe %g, dxw %g, dy %g, dyn %g, dys %g \n",
        nx, ny, nz, d_x, dxe ,dxw, dy, dyn, dys);
*/
                /* check if element is in area with filling */
                if (nz > 2)
                {
                    DTDT += lu*(TUP-TP);
                } else if (nz == 2)
                {
                    lu = 0.5*(TCON_G+TCON_F)/(dz*dzu);
                    DTDT += lu*(TUP-TP);
                }
                else if (nz == 1)
                {
                    ld = 0.5*(TCON_G+TCON_F)/(dz*dzd);
                    lu = TCON_G/(dz*dzu);
                    DTDT += lu*(TUP-TP);
                    capaf = d_x*dy*dz*cap_f;
                }
                else
                {   /* nz == 0 */
                    ld = TCON_G/(dz*dzd);

                    if (ny <= 2*refine-1 || ny >= YNODES-2*refine ||
                        nx <= 2*refine-1 || nx >= XNODES-2*refine)
                    {   /* outside in x- and y-direction */
                        lu = (TCON_F/dzu + (I_TOP_OUT + U_TOP_OUT)/cap_g)/dz;
                        DTDT += lu*(T_TOP_OUT-TP);
                    }
                    else
                    {   /* inside of pipe section */
                        le = TCON_F/(d_x*dxe);
                        lw = TCON_F/(d_x*dxw);
                        ln = TCON_F/(dy*dyn);
                        ls = TCON_F/(dy*dys);
                        lu = (TCON_F/dzu + (I_TOP_PIPE + U_TOP_PIPE)/cap_f)/dz;
                        DTDT += lu*(T_TOP_PIPE-TP);
                    }

                    /* correct for borders */
                    if (nx >= 2*refine && nx < XNODES-2*refine)
                    {   /* x-direction is in pipe section */
                        if (ny == 2*refine-1 || ny == YNODES-2*refine-1)
                        {
                            /* southern node outside or north node inside */
                            ln = 0.5*(TCON_F+TCON_G)/(dy*dyn);
                        }
                        else if (ny == 2*refine || ny == YNODES-2*refine)
                        {
                            /* south node inside or northern node outside */
                            ls = 0.5*(TCON_F+TCON_G)/(dy*dys);
                        }
                    }

                    if (ny >= 2*refine && ny < XNODES-2*refine)
                    {   /* y-direction is in pipe section */
                        if (nx == 2*refine-1 || nx == XNODES-2*refine-1)
                        {
                            /* eastern node outside or west node inside */
                            lw = 0.5*(TCON_F+TCON_G)/(d_x*dxw);
                        }
                        else if (nx == 2*refine || nx == XNODES-2*refine)
                        {
                            /* east node inside or western node outside */
                            le = 0.5*(TCON_F+TCON_G)/(d_x*dxe);
                        }
                    }
                } /* end if nz == 0 */

                if (nz < ZNODES-1)
                {
                    DTDT += ld*(TDOWN-TP);
                }
                else
                {
                    DTDT += ld*(tbound-TP);
                }

                if (nx > 0)
                {
                    DTDT += le*(TEAST-TP);
                }
                else
                {
                    DTDT += le*(tbound-TP);
                }

                if (nx < XNODES-1)
                {
                    DTDT += ld*(TWEST-TP);
                }
                else
                {
                    DTDT += ld*(tbound-TP);
                }

                if (ny > 0)
                {
                    DTDT += ls*(TSOUTH-TP);
                }
                else
                {
                    DTDT += ls*(tbound-TP);
                }

                if (ny < YNODES-1)
                {
                    DTDT += ln*(TNORTH-TP);
                }
                else
                {
                    DTDT += ln*(tbound-TP);
                }

            } /* end for nx */
        } /* end for ny */
    } /* end for nz */

    /* convective heat transfer */
    DEDT = 0.0; /* energy balance */
    if (MDOT == 0.0)
    {
        nx = (3 + (int)(PIPENODES/SEGMENTS))*2*refine - 1;
        ny = 0; /* not very correct, but a guess */
        nz = 0;
        TFLUID(PIPENODES) = TP;
    }
    else
    {
        dir = -1;
        ny = 2*refine;
        nz = 1; /* pipe layer is second layer */
        TFLUID(0) = TFLUIDIN;

        for (i = 0; i < PIPENODES; i++) 
        {
            /* change direction every five nodes */
            if (i - SEGMENTS*(int)(i/SEGMENTS) == 0)
            {
                ny += dir;
                dir = -dir;
            }
            nx = (3 + (int)(i/SEGMENTS))*2*refine - 1;
            ny += dir;

            /* equations from: 
               Wagner: Waermeuebertragung, Vogel-Verlag, 1991 */
            /* nuss = 4 for laminar flow in pipes */
            /* heat transfer in W/(m^2*K) = (nuss*co)/dpipe; */
            uhx = 30; /* approximate value */
            
            /* following equation is derived from
                mdot * cp * dThx = U * dA * (Tnode - Thx)
               replace (Tnode-Thx) by teta, than dThx is -dteta
                mdot * cp * dteta = - U * dA * teta
                dteta / teta = - U * dA / (mdot * cp)
               integrate from inlet position to outlet position
                ln(teta(out)/teta(in)) = - U * A / (mdot * cp)
               exponentiate and solve for teta(out)
                 teta(out) = teta(in) * exp(-U*A/(mdot*cp))
               replace teta by (Tnode - Thx) and solve for 
               Thx(out), the outlet temperature of the 
               heat exchanger in one node
                 Thx(out) = Tnode(out) +
                    ((Thx(in) - Tnode(in)) * exp(-U*A/(mdot*cp))
               Tnode(in) and Tnode(out) are the same since nodes
               are fully mixed. Remember that in the following
               equation Tnode must refer to one node upwars in
               flowdirection.
            */
            
            heatex = uhx*Apipe;
            DTDT += heatex*(TFLUID(i)-TP)/capaf;
            DEDT += heatex*(TFLUID(i)-TP)/(MDOT*cp);

            /* new heat exchanger temperature for next node */
            TFLUID(i+1) = TP + (TFLUID(i)-TP)*exp(-heatex/(MDOT*cp));

        } /* for i */
    } /* if mdot */

} /* mdlDerivatives()... */



/*
 * mdlTerminate - called when the simulation is terminated.
 *
 * In this function, you should perIWork any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */

static void mdlTerminate(SimStruct *S)
{}       /* NOP */

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
