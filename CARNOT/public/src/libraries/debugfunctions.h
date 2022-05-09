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
 * $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_c/debugfunctions/src/debugfunctions.h $
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

#ifndef _DEBUGFUNCTIONS_
	#define _DEBUGFUNCTIONS_
	#include "tmwtypes.h"
	#include "simstruc.h"

	
	void debug_WriteToFile(char *filename, double time, char *message);
    
    
	boolean_T check_Inport(SimStruct *S, int_T port);
	boolean_T check_InportElement(SimStruct *S, int_T port, int_T element);
    boolean_T check_Outport(SimStruct *S, int_T port);
    boolean_T check_OutportElement(SimStruct *S, int_T port, int_T element);
    boolean_T check_ContState(SimStruct *S, int_T number);
	boolean_T check_ContStateDerivative(SimStruct *S, int_T number);
    boolean_T check_DiscState(SimStruct *S, int_T number);
	boolean_T check_DWork(SimStruct *S, int_T number);
    boolean_T check_DWorkElement(SimStruct *S, int_T number, int_T element);
    boolean_T check_RWork(SimStruct *S, int_T number);
    boolean_T check_IWork(SimStruct *S, int_T number);
    boolean_T check_PWork(SimStruct *S, int_T number);
	boolean_T check_Parameter(SimStruct *S, int_T number);
	boolean_T check_ParameterElement(SimStruct *S, int_T number, int_T element);
	
	
	boolean_T read_InportElement(SimStruct *S, int_T port, int_T element, real_T *value);
    boolean_T read_ContState(SimStruct *S, int_T element, real_T *value);
	boolean_T read_ContStateDerivative(SimStruct *S, int_T element, real_T *value);
	boolean_T read_DiscState(SimStruct *S, int_T element, real_T *value);
	boolean_T read_DWorkElement(SimStruct *S, int_T number, int_T element, void *value);
	boolean_T read_RWork(SimStruct *S, int_T number, real_T *value);
	boolean_T read_IWork(SimStruct *S, int_T number, int_T *value);
	boolean_T read_PWork(SimStruct *S, int_T number, void* ptr);
	boolean_T read_ParameterElement(SimStruct *S, int_T number, int_T element, real_T *value);
	
	
	boolean_T write_OutportElement(SimStruct *S, int_T port, int_T element, real_T value);
    boolean_T write_ContState(SimStruct *S, int_T element, real_T value);
	boolean_T write_ContStateDerivative(SimStruct *S, int_T element, real_T value);
	boolean_T write_DiscState(SimStruct *S, int_T element, real_T value);
	boolean_T write_DWorkElement_real(SimStruct *S, int_T number, int_T element, real_T value);
	boolean_T write_DWorkElement_real32(SimStruct *S, int_T number, int_T element, real32_T value);
	boolean_T write_DWorkElement_int8(SimStruct *S, int_T number, int_T element, int8_T value);
	boolean_T write_DWorkElement_int16(SimStruct *S, int_T number, int_T element, int16_T value);
	boolean_T write_DWorkElement_int32(SimStruct *S, int_T number, int_T element, int32_T value);
	boolean_T write_DWorkElement_uint8(SimStruct *S, int_T number, int_T element, uint8_T value);
	boolean_T write_DWorkElement_uint16(SimStruct *S, int_T number, int_T element, uint16_T value);
	boolean_T write_DWorkElement_uint32(SimStruct *S, int_T number, int_T element, uint32_T value);
	boolean_T write_DWorkElement_boolean(SimStruct *S, int_T number, int_T element, boolean_T value);
	boolean_T write_RWork(SimStruct *S, int_T number, real_T value);
	boolean_T write_IWork(SimStruct *S, int_T number, int_T value);
	boolean_T write_PWork(SimStruct *S, int_T number, void* ptr);
    
#endif
