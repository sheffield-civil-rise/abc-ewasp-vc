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
 * $Revision: 81 $
 * $Author: goettsche $
 * $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
 * $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_c/debugfunctions/src/debugfunctions.c $
 ***********************************************************************
 *  M O D E L    O R    F U N C T I O N
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * This is an auxiliary library for debugging and safe access to SimStruct
 * elements.
 *
 * author list: aw -> Arnold Wohlfeil
 *
 * version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
 *
 * Version  Author  Changes                                     Date
 * 6.1.0    aw      created                                     27feb2017
 * 6.1.1	aw		added read/write functions					01mar2017
 *
 * Copyright by the authors and (c) 1998 Solar-Institut Juelich, Germany
 *
 */

#include <stdio.h>
#include "debugfunctions.h"



/*-----------------------------------------------------------------------*/
/*---------------------------- miscellaneous ----------------------------*/
/*-----------------------------------------------------------------------*/

/* other functions */
void debug_WriteToFile(char *filename, double time, char *message)
{
	FILE *fid;
	
	fid = fopen(filename, "at");
	fprintf(fid, "%f\t%s\n", time, message);
	fclose(fid);
}


/*-----------------------------------------------------------------------*/
/*---------------------- Checks for Accessibility -----------------------*/
/*-----------------------------------------------------------------------*/


/* checks for inports */

boolean_T check_Inport(SimStruct *S, int_T port)
/* checks if an inport is accessible */
{
    if (port < 0)
    {
        return(false);
    }
    else if (port > ssGetNumInputPorts(S)-1)
	{
		return(false);
	}
	else
	{
		return(true);
	}
}

boolean_T check_InportElement(SimStruct *S, int_T port, int_T element)
/* checks if the element of an inport is accessible */
{
    if (port < 0)
    {
        return(false);
    }
    else if (port > ssGetNumInputPorts(S)-1)
	{
		return(false);
	}
	else
	{
		if (element < 0)
        {
            return(false);
        }
        else if (element > ssGetInputPortWidth(S, port)-1)
		{
			return(false);
		}
		else
		{
			return(true);
		}
	}
}

/*-----------------------------------------------------------------------*/


/* checks for outports */
boolean_T check_Outport(SimStruct *S, int_T port)
/* checks if an outport is accessible */
{
    if (port < 0)
    {
        return(false);
    }
    else if (port > ssGetNumOutputPorts(S)-1)
	{
		return(false);
	}
	else
	{
		return(true);
	}
}




boolean_T check_OutportElement(SimStruct *S, int_T port, int_T element)
/* checks if the element of an outport is accessible */
{
    if (port < 0)
    {
        return(false);
    }
    else if (port > ssGetNumOutputPorts(S)-1)
	{
		return(false);
	}
	else
	{
		if (element < 0)
        {
            return(false);
        }
        else if (element > ssGetOutputPortWidth(S, port)-1)
		{
			return(false);
		}
		else
		{
			return(true);
		}
	}
}



/*-----------------------------------------------------------------------*/

/* checks continuous states */
boolean_T check_ContState(SimStruct *S, int_T number)
/* checks if a continuous state is accessible */
{
    if (number < 0)
    {
        return(false);
    }
    else if (number > ssGetNumContStates(S)-1)
	{
		return(false);
	}
	else
	{
		return(true);
	}
}

/*-----------------------------------------------------------------------*/


/* checks continuous states derivative */
boolean_T check_ContStateDerivative(SimStruct *S, int_T number)
/* checks if a continuous state derivative is accessible */
{
    if (number < 0)
    {
        return(false);
    }
    else if (number > ssGetNumContStates(S)-1)
	{
		return(false);
	}
	else
	{
		return(true);
	}
}



/*-----------------------------------------------------------------------*/

/* checks for discrete states */
boolean_T check_DiscState(SimStruct *S, int_T number)
/* checks if a discrete state is accessible */
{
    if (number < 0)
    {
        return(false);
    }
    else if (number > ssGetNumDiscStates(S)-1)
	{
		return(false);
	}
	else
	{
		return(true);
	}
}


/*-----------------------------------------------------------------------*/


/* checks for DWork Vectors */
boolean_T check_DWork(SimStruct *S, int_T number)
/* checks if an DWork Vector is accessible */
{
    if (number < 0)
    {
        return(false);
    }
    else if (number > ssGetNumDWork(S)-1)
	{
		return(false);
	}
	else
	{
		return(true);
	}
}


boolean_T check_DWorkElement(SimStruct *S, int_T number, int_T element)
/* checks if the element of an DWork vector is accessible */
{
    if (number < 0)
    {
        return(false);
    }
    else if (number > ssGetNumDWork(S)-1)
	{
		return(false);
	}
	else
	{
		if (element < 0)
        {
            return(false);
        }
        else if (element > ssGetDWorkWidth(S, number)-1)
		{
			return(false);
		}
		else
		{
			return(true);
		}
	}
}



/*-----------------------------------------------------------------------*/

/* checks for RWork Vectors */
boolean_T check_RWork(SimStruct *S, int_T number)
/* checks if a RWork element is accessible */
{
    if (number < 0)
    {
        return(false);
    }
    else if (number > ssGetNumRWork(S)-1)
	{
		return(false);
	}
	else
	{
		return(true);
	}
}

/*-----------------------------------------------------------------------*/



/* checks for IWork Vectors */
boolean_T check_IWork(SimStruct *S, int_T number)
/* checks if a IWork element is accessible */
{
    if (number < 0)
    {
        return(false);
    }
    else if (number > ssGetNumIWork(S)-1)
	{
		return(false);
	}
	else
	{
		return(true);
	}
}

/*-----------------------------------------------------------------------*/



/* checks for PWork Vectors */
boolean_T check_PWork(SimStruct *S, int_T number)
/* checks if a PWork element is accessible */
{
    if (number < 0)
    {
        return(false);
    }
    else if (number > ssGetNumPWork(S)-1)
	{
		return(false);
	}
	else
	{
		return(true);
	}
}

/*-----------------------------------------------------------------------*/


/* checks for parameters */
boolean_T check_Parameter(SimStruct *S, int_T number)
/* checks if a parameter is accessible */
{
    if (number < 0)
    {
        return(false);
    }
    else if (number > ssGetNumSFcnParams(S)-1)
	{
		return(false);
	}
	else
	{
		return(true);
	}
}


boolean_T check_ParameterElement(SimStruct *S, int_T number, int_T element)
/* checks if the element of a parameter vector is accessible */
{
    if (number < 0)
    {
        return(false);
    }
    else if (number > ssGetNumSFcnParams(S)-1)
	{
		return(false);
	}
	else
	{
		if (element < 0)
        {
            return(false);
        }
        else if (element > (int_T)mxGetNumberOfElements(ssGetSFcnParam(S, number))-1)
		{
			return(false);
		}
		else
		{
			return(true);
		}
	}
}



/*-----------------------------------------------------------------------*/




/*-----------------------------------------------------------------------*/
/*--------------------- Access function for reading ---------------------*/
/*-----------------------------------------------------------------------*/


boolean_T read_InportElement(SimStruct *S, int_T port, int_T element, real_T *value)
/* reads an inport element */
/* returns true if the inport element is accessible, otherwise false */
{
	InputRealPtrsType Inport = NULL;
	
    if (check_InportElement(S, port, element))
	{
		Inport = ssGetInputPortRealSignalPtrs(S, port);
		*value = *Inport[element];
		return(true);
	}
	else
	{
		return(false);
	}
}

/*-----------------------------------------------------------------------*/


boolean_T read_ContState(SimStruct *S, int_T element, real_T *value)
/* reads a continuous state */
/* returns true if the continuous state is accessible, otherwise false */
{
    real_T *ContStates = NULL;
    
    if (check_ContState(S, element))
    {
		ContStates = ssGetContStates(S);
        *value = ContStates[element];
        return(true);
    }
    else
    {
        return(false);
    }
}

/*-----------------------------------------------------------------------*/


boolean_T read_ContStateDerivative(SimStruct *S, int_T element, real_T *value)
/* reads a continuous state derivative */
/* returns true if the continuous state derivative is accessible, otherwise false */
{
    real_T *ContStateDerivatives = NULL;
    
    if (check_ContStateDerivative(S, element))
    {
		ContStateDerivatives = ssGetdX(S);
        *value = ContStateDerivatives[element];
        return(true);
    }
    else
    {
        return(false);
    }
}

/*-----------------------------------------------------------------------*/

boolean_T read_DiscState(SimStruct *S, int_T element, real_T *value)
/* reads a discrete state */
/* returns true if the discrete state is accessible, otherwise false */
{
    real_T *DiscStates = NULL;
    
    if (check_DiscState(S, element))
    {
		DiscStates = ssGetDiscStates(S);
        *value = DiscStates[element];
        return(true);
    }
    else
    {
        return(false);
    }
}



/*-----------------------------------------------------------------------*/


boolean_T read_DWorkElement(SimStruct *S, int_T number, int_T element, void *value)
/* reads a DWork-Vector element */
/* returns true if the DWork-Vector element is accessible, otherwise false */
{
    void *DWork = NULL;
    
    if (check_DWorkElement(S, number, element))
    {
        DWork = ssGetDWork(S, number);
        switch ssGetDWorkDataType(S, number)
        {
            case SS_DOUBLE : *(real_T*)value=((real_T*)DWork)[element];
                             return(true);
            case SS_SINGLE : *(real32_T*)value=((real32_T*)DWork)[element];
                             return(true);
            case SS_INT8   : *(int8_T*)value=((int8_T*)DWork)[element];
                             return(true);
            case SS_UINT8  : *(uint8_T*)value=((uint8_T*)DWork)[element];
                             return(true);
            case SS_INT16  : *(int16_T*)value=((int16_T*)DWork)[element];
                             return(true);
            case SS_UINT16 : *(uint16_T*)value=((uint16_T*)DWork)[element];
                             return(true);
            case SS_INT32  : *(int32_T*)value=((int32_T*)DWork)[element];
                             return(true);
            case SS_UINT32 : *(uint32_T*)value=((uint32_T*)DWork)[element];
                             return(true);
            case SS_BOOLEAN: *(boolean_T*)value=((boolean_T*)DWork)[element];
                             return(true);
            default        : return(false);
        }
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/



boolean_T read_RWork(SimStruct *S, int_T number, real_T *value)
/* reads a RWork-Vector element */
/* returns true if the RWork-Vector element is accessible, otherwise false */
{
    real_T *RWork = NULL;
    
    if (check_RWork(S, number))
    {
		RWork = ssGetRWork(S);
        *value = RWork[number];
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/


boolean_T read_IWork(SimStruct *S, int_T number, int_T *value)
/* reads a IWork-Vector element */
/* returns true if the IWork-Vector element is accessible, otherwise false */
{
    int_T *IWork = NULL;
    
    if (check_IWork(S, number))
    {
		IWork = ssGetIWork(S);
        *value = IWork[number];
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/



boolean_T read_PWork(SimStruct *S, int_T number, void *ptr)
/* reads a PWork vector element */
/* returns true if the PWork vector element is accessible, otherwise false */
{
	void **PWork = NULL;
	if (check_PWork(S, number))
    {
		PWork = ssGetPWork(S);
        ptr = PWork[number];
        return(true);
    }
    else
    {
        return(false);
    }
}

/*-----------------------------------------------------------------------*/


boolean_T read_ParameterElement(SimStruct *S, int_T number, int_T element, real_T *value)
/* reads a parameter element */
/* returns true if the parameter element is accessible, otherwise false */
{
	real_T *param = NULL;
	if (check_ParameterElement(S, number, element))
    {
        param = (real_T*)mxGetPr(ssGetSFcnParam(S, number));
		*value = param[number];
        return(true);
    }
    else
    {
        return(false);
    }
	
}



/*-----------------------------------------------------------------------*/
/*--------------------- Access function for writing ---------------------*/
/*-----------------------------------------------------------------------*/

boolean_T write_OutportElement(SimStruct *S, int_T port, int_T element, real_T value)
/* writes an outport element */
/* returns true if the outport element is accessible, otherwise false */
{
    real_T *Outport = NULL;
    
    if (check_OutportElement(S, port, element))
    {
        Outport = ssGetOutputPortRealSignal(S, port);
		Outport[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}

/*-----------------------------------------------------------------------*/

boolean_T write_ContState(SimStruct *S, int_T element, real_T value)
/* writes a continuous state */
/* returns true if the continuous state is accessible, otherwise false */
{
    real_T *ContStates = NULL;
    
    if (check_ContState(S, element))
    {
		ContStates = ssGetContStates(S);
        ContStates[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/


boolean_T write_ContStateDerivative(SimStruct *S, int_T element, real_T value)
/* writes a continuous state derivative */
/* returns true if the continuous state derivative is accessible, otherwise false */
{
    real_T *ContStateDerivatives = NULL;
    
    if (check_ContStateDerivative(S, element))
    {
		ContStateDerivatives = ssGetdX(S);
        ContStateDerivatives[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/


boolean_T write_DiscState(SimStruct *S, int_T element, real_T value)
/* writes a discrete state */
/* returns true if the discrete state is accessible, otherwise false */
{
    real_T *DiscStates = NULL;
    
    if (check_DiscState(S, element))
    {
		DiscStates = ssGetDiscStates(S);
        DiscStates[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/


boolean_T write_DWorkElement_real(SimStruct *S, int_T number, int_T element, real_T value)
/* writes a real_T DWork vector element */
/* returns true if the DWork vector element is accessible, otherwise false */
{	
    real_T *DWork = NULL;
    
    if (check_DWorkElement(S, number, element))
    {
		DWork = (real_T*)ssGetDWork(S, number);
        DWork[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/


boolean_T write_DWorkElement_real32(SimStruct *S, int_T number, int_T element, real32_T value)
/* writes a real32_T DWork vector element */
/* returns true if the DWork vector element is accessible, otherwise false */
{	
    real32_T *DWork = NULL;
    
    if (check_DWorkElement(S, number, element))
    {
		DWork = (real32_T*)ssGetDWork(S, number);
        DWork[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/


boolean_T write_DWorkElement_int8(SimStruct *S, int_T number, int_T element, int8_T value)
/* writes a int8_T DWork vector element */
/* returns true if the DWork vector element is accessible, otherwise false */
{	
    int8_T *DWork = NULL;
    
    if (check_DWorkElement(S, number, element))
    {
		DWork = (int8_T*)ssGetDWork(S, number);
        DWork[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/



boolean_T write_DWorkElement_int16(SimStruct *S, int_T number, int_T element, int16_T value)
/* writes a int16_T DWork vector element */
/* returns true if the DWork vector element is accessible, otherwise false */
{	
    int16_T *DWork = NULL;
    
    if (check_DWorkElement(S, number, element))
    {
		DWork = (int16_T*)ssGetDWork(S, number);
        DWork[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/


boolean_T write_DWorkElement_int32(SimStruct *S, int_T number, int_T element, int32_T value)
/* writes a int32_T DWork vector element */
/* returns true if the DWork vector element is accessible, otherwise false */
{	
    int32_T *DWork = NULL;
    
    if (check_DWorkElement(S, number, element))
    {
		DWork = (int32_T*)ssGetDWork(S, number);
        DWork[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/



boolean_T write_DWorkElement_uint8(SimStruct *S, int_T number, int_T element, uint8_T value)
/* writes a uint8_T DWork vector element */
/* returns true if the DWork vector element is accessible, otherwise false */
{	
    uint8_T *DWork = NULL;
    
    if (check_DWorkElement(S, number, element))
    {
		DWork = (uint8_T*)ssGetDWork(S, number);
        DWork[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/



boolean_T write_DWorkElement_uint16(SimStruct *S, int_T number, int_T element, uint16_T value)
/* writes a uint16_T DWork vector element */
/* returns true if the DWork vector element is accessible, otherwise false */
{	
    uint16_T *DWork = NULL;
    
    if (check_DWorkElement(S, number, element))
    {
		DWork = (uint16_T*)ssGetDWork(S, number);
        DWork[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/


boolean_T write_DWorkElement_uint32(SimStruct *S, int_T number, int_T element, uint32_T value)
/* writes a uint32_T DWork vector element */
/* returns true if the DWork vector element is accessible, otherwise false */
{	
    uint32_T *DWork = NULL;
    
    if (check_DWorkElement(S, number, element))
    {
		DWork = (uint32_T*)ssGetDWork(S, number);
        DWork[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/



boolean_T write_DWorkElement_boolean(SimStruct *S, int_T number, int_T element, boolean_T value)
/* writes a boolean_T DWork vector element */
/* returns true if the DWork vector element is accessible, otherwise false */
{	
    boolean_T *DWork = NULL;
    
    if (check_DWorkElement(S, number, element))
    {
		DWork = (boolean_T*)ssGetDWork(S, number);
        DWork[element] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/



boolean_T write_RWork(SimStruct *S, int_T number, real_T value)
/* writes a RWork vector element */
/* returns true if the RWork vector element is accessible, otherwise false */
{	
    real_T *RWork = NULL;
    
    if (check_RWork(S, number))
    {
		RWork = ssGetRWork(S);
        RWork[number] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/



boolean_T write_IWork(SimStruct *S, int_T number, int_T value)
/* writes a IWork vector element */
/* returns true if the IWork vector element is accessible, otherwise false */
{	
    int_T *IWork = NULL;
    
    if (check_IWork(S, number))
    {
		IWork = ssGetIWork(S);
        IWork[number] = value;
        return(true);
    }
    else
    {
        return(false);
    }
}


/*-----------------------------------------------------------------------*/





boolean_T write_PWork(SimStruct *S, int_T number, void *ptr)
/* writes a PWork vector element */
/* returns true if the PWork vector element is accessible, otherwise false */
{
	void **PWork = NULL;
	if (check_PWork(S, number))
    {
		PWork = ssGetPWork(S);
        PWork[number] = ptr;
        return(true);
    }
    else
    {
        return(false);
    }
}

/*-----------------------------------------------------------------------*/









/*--------------------------------- EOF ---------------------------------*/
