% SRC_M
%
% Files
%   acm_param                                 - This file calculates the characteristic paramaters A, E, s_e, r_e, s_g and r_g 

%   airmass                                   - This function calulates the airmass at a specific time and for a specific
%   angles2time                               - This function finds the time to two specified angles.
%   annualcosts                               - calculates the annual costs of a system all through its lifetime.
%   BlockIsInCarnotLibrary                    - BlockIsInCarnotLibrary checks if a block is in the Carnot library
%   calculate_pmv                             - calculate_pmv: predictive mean vote for room temperature comfort
%   calculate_ppd                             - calculate_ppd: percentage of dissatisfaction for room temperature comfort
%   calculate_verification_error              - calculate_verification_error of the verification of a function or model
%   CARLIB                                    - Carlib library for material properties and general functions of Carnot
%   Carnot_Fluid_Types                        - Definition of the fluid types                                            
%   CarnotCallbacks_Absorption_Chiller_LookUp - CarnotCallbacks_Absorption_Chiller_LookUp is used by the Carnot Absorption_Chiller_LookUp 
%   CarnotCallbacks_CollectorEN12975Conf      - Callback for Carnot model SolarCollector

%   CarnotCallbacks_CollectorUnglazedConf     - CarnotCallbacks_CollectorUnglazedConf Callback for Carnot model Collector_Unglazed
%   CarnotCallbacks_CondensingBoilerConf      - Callback for Carnot model Condensing_Boiler_CONF
%   CarnotCallbacks_CONFblocks                - CarnotCallbacks_CONFblocks handles the parameters of _CONF blocks
%   CarnotCallbacks_Data_from_File            - CarnotCallbacks_Data_from_File loads a variable from file and sets the name in a from workspace block
%   CarnotCallbacks_Density                   - varargout = CarnotCallbacks_Density(varargin)
%   CarnotCallbacks_EBCreator                 - function varargout = CarnotCallbacks_EBCreator(varargin) is used by the
%   CarnotCallbacks_Enthalpy                  - varargout = CarnotCallbacks_Enthalpy(varargin)
%   CarnotCallbacks_Enthalpy2Temperature      - varargout = CarnotCallbacks_Enthalpy2Temperature(varargin)
%   CarnotCallbacks_Entropy                   - varargout = CarnotCallbacks_Entropy(varargin)

%   CarnotCallbacks_Evaporation_Enthalpy      - varargout = CarnotCallbacks_Evaporation_Enthalpy(varargin)
%   CarnotCallbacks_FuelConf                  - Callback for Carnot model Fuel_CONF
%   CarnotCallbacks_GetFiles                  - CarnotCallbacks_GetFiles loads a variable from file and sets the name in a from workspace block
%   CarnotCallbacks_GlobalMessageLevel        - varargout = CarnotCallbacks_GlobalMessageLevel(varargin)
%   CarnotCallbacks_Grashof                   - varargout = CarnotCallbacks_Grashof(varargin)
%   CarnotCallbacks_Heat_Capacity             - varargout = CarnotCallbacks_Heat_Capacity(varargin)
%   CarnotCallbacks_HeatPump                  - Callback for Carnot model HeatPump
%   CarnotCallbacks_HouseSimple               - Callback for Carnot model House_simple
%   CarnotCallbacks_InverterConf              - Callback for Carnot model Inverter
%   CarnotCallbacks_Kinematic_Viscosity       - varargout = CarnotCallbacks_Kinematic_Viscosity(varargin)
%   CarnotCallbacks_LoadExamples              - Carnot_LoadExamples_Callbacks is a callback script to load the examples
%   CarnotCallbacks_Material                  - function varargout = CarnotCallbacks_Material(varargin) is used by the
%   CarnotCallbacks_mdot_annual_profile       - This functions opens a window to input the distribution of the water consumption.
%   CarnotCallbacks_ModelDoc                  - Callback for Carnot model ModelDoc
%   CarnotCallbacks_PMV_PPD                   - varargout = CarnotCallbacks_PMV_PPD(varargin)
%   CarnotCallbacks_Prandtl                   - varargout = CarnotCallbacks_Prandtl(varargin)
%   CarnotCallbacks_PumpAdditional            - Callback for Carnot model Pump_Additional
%   CarnotCallbacks_PumpMain                  - Callback for Carnot model Pump_Main
%   CarnotCallbacks_Saturation_Property       - varargout = CarnotCallbacks_Saturation_Property(varargin)
%   CarnotCallbacks_Saturation_Temperature    - varargout = CarnotCallbacks_Saturation_Temperature(varargin)
%   CarnotCallbacks_Saturation_Value_Water    - varargout = CarnotCallbacks_Saturation_Value_Water(varargin)
%   CarnotCallbacks_Specific_Volume           - varargout = CarnotCallbacks_Specific_Volume(varargin)
%   CarnotCallbacks_StorageConf               - CarnotCallbacks_StorageConf - Callback for Carnot model Storage_TypeN
%   CarnotCallbacks_StorageTypeN              - [standing, dh, height, mpts, tini] ...
%   CarnotCallbacks_THBCreator                - function varargout = CarnotCallbacks_THBCreator(varargin) is used by the
%   CarnotCallbacks_Thermal_Conductivity      - varargout = CarnotCallbacks_Thermal_Conductivity(varargin)
%   CarnotCallbacks_Vapour_Content            - varargout = CarnotCallbacks_Vapour_Content(varargin)
%   CarnotCallbacks_Vapour_Pressure           - varargout = CarnotCallbacks_Vapour_Pressure(varargin)
%   CarnotCallbacks_WindowWithShading         - CarnotCallbacks_WindowWithShading is a callback for the Window_with_Shading model
%   clothing_area_factor                      - $Revision: 81 $
%   clothing_surface_temperature              - surface temperature of the clothing - equation (2) of DIN EN ISO 7730:2005
%   cloudindex                                - cloudindex : calculation of the cloudiness degree in 1/8
%   colpdrop                                  - calculates the pressuredrop in an absorber per apertur surface
%   convert_weather                           - convert_weather converts old Carnot weather format into the new Carnot format. 
%   createDatafile                            - createDatafile creates a datafile for Carnot block Data_from_File
%   date2sec                                  - transforms a date to seconds of year
%   density                                   - density(temperature, pressure, fluid_ID, fluid_mix)
%   display_verification_error                - Function to plot the verification error creates 2 windows showing the
%   EB_format                                 - Format of the EB - Electric-Bus in CARNOT
%   ElectricEnum                              - $Revision: 81 $
%   enthalpy                                  - enthalpy(temperature, pressure, fluid_ID, fluid_mix)
%   enthalpy2temperature                      - enthalpy2temperature(enthalpy, pressure, fluid_ID, fluid_mix)                                                                  
%   entropy                                   - entropy(temperature, pressure, fluid_ID, fluid_mix)
%   evaporation_enthalpy                      - calculates the evaporation enthalpy [J/kg] according to the inputs:             
%   example_annualcosts                       - This m-script is an example how the input parameters can be set for the 
%   fitSineToTamb                             - fitSineToTamb - fits a sine curve to Tamb for ISO 13370 ground model
%   FluidEnum                                 - $Revision: 81 $
%   fluidprop                                 - fluidprop (temperature, pressure, fluid_type, fluid_mix,property_ID)
%   grashof                                   - grashof(tw, tinf, p, fluid_ID, fluid_mix, x)
%   heat_capacity                             - heat_capacity(temperature, pressure, fluid_ID, fluid_mix)
%   heat_transfer_clothing                    - static double calculate_h_c(double v_ar, double t_cl, double t_a)
%   helpcarnot                                - helpcarnot opens the CARNOT manual from the command line
%   hourangle2time                            - This function converts a given hourangle to a solar time. 
%   hp_param                                  - calculates the parameters K(1), K(2), K(3),
%   kinematic_viscosity                       - kinematic_viscosity(temperature, pressure, fluid_ID, fluid_mix)
%   legaltime2solartime                       - FUNCTION legaltime2solartime : Calculate solar time of a location on the
%   link_breaker                              - open all systems in a directory and save without library links
%   MessageLevelEnum                          - $Revision: 81 $
%   Meteonorm2wformat                         - Meteonorm2wformat converts weather data which is calculated by METEONORM,
%   MeteonormMinute2wformat                   - MeteonormMinute2wformat converts weather data in 1 minutes time 
%   path_carnot                               - path_carnot - management and definition of paths for carnot
%   PhaseEnum                                 - $Revision: 81 $
%   prandtl                                   - prandtl(temperature, pressure, fluid_ID, fluid_mix)
%   PropertyEnum                              - $Revision: 81 $
%   radiationdivision                         - FUNCTION: Berechnug von direkter und diffuser Strahlung auf die Horizontale
%   ratiograph                                - ratiograph plots a graph to show the ratio of direct radiation on tilted
%   rel_hum2x                                 - x = rel_hum2x(t, p, hum) calculates the water mass per dry air mass from 
%   repeat_timeseries                         - y = repeat_timeseries(u,n))
%   reynolds                                  - reynolds(temperature, velocity, pressure, fluid_type, fluid_mix, dimension)
%   root_carnot                               - root_carnot: Root directory of CARNOT installation.
%   saturationtemperature                     - saturationtemperature(pressure, fluid_ID, fluid_mix)
%   SearchWriteParams                         - gets mask parameters of Simulink models
%   sec2date                                  - transforms seconds in a year to a date in the form
%   skytemperature                            - FUNCTION:    calculation of the sky temperature
%   slblocks                                  - function to include the CARNOT library in the simulink library browser
%   solar_declination                         - solar_declination calculates the declination of the sun in degree.
%   solar_extraterrestrial                    - solar_extraterrestrial calculates the solar extraterrestrial 
%   solartime2legaltime                       - FUNCTION: Calculates legal time on the base of the solar time. In the
%   specific_volume                           - specific_volume(temperature, pressure, fluid_ID, fluid_mix)
%   sumtime                                   - sumtime(YEAR,MONTH,DAY,HOUR,MINUTE,SECOND) calculates for a given date 
%   sungraph                                  - plots a position diagram of the sun.
%   sunset                                    - [time_sunrise, time_sunset] 
%   taualfa                                   - taualfa(ncover,refin,teta,KL,alfa) calculates the 
%   temperature_conductivity                  - temperature_conductivity (temperature, pressure, fluid_ID, fluid_mix)
%   THB_format                                - Format of the THB - Thermo-Hydraulic-Bus in CARNOT
%   thermal_conductivity                      - thermal_conductivity (temperature, pressure, fluid_ID, fluid_mix)
%   time2hourangle                            - This function converts a given solar time to an hourangle. 
%   timecomment                               - timmecomment creates the timecomment for weather data
%   tmy2wdb                                   - tmy2wdb converts weather data from TMY2 to WDB
%   tmy2wformat                               - 
%   try2wdb                                   - try2wdb converts weather data from German DWD 2010 TRY-fromat to Carnot WDB
%   try2wformat                               - 
%   tvalue                                    - Functions   converts a date in seconds to the time comment format 
%   txt2mat                                   - read an ascii file and convert a data table to matrix
%   unitconv_carnot                           - unitconv_carnot (value, input_unit, output_unit, flag)
%   unitconv_temperature                      - This m-function converts a temperature form a unit to another.
%   vapourpressure                            - vapourpressure(temperature, pressure, fluid_ID, fluid_mix)
%   velocity                                  - function velocity(t,p,fluid,mix,d,mdot)                         
%   WDB_format                                - WDB_format - Format of weather data bus WDB in CARNOT
%   x2rel_hum                                 - x2rel_hum(t, p, x) calculates the relative humidity in percent from the
%   year_average                              - Function year_average calculates the average of a given weather data 
%   year_sum                                  - This function calculates the sum and average of a given weather data 
%   CarnotCallbacks_EU_Tapping_Cycle          - Callback for Carnot block EU_Tapping_Cycle
%   carnot_publish_mfiles                     - carnot_publish_mfiles calls the publish function for m-files in the Carnot Toolbox
%   dwd2wdb                                   - dwd2wdb converts weather data from German DWD 2016 TRY file format 
%   solar_angles                              - solar_angles calculates the position angles of the sun

%   CarnotCallbacks_CollectorUnglazedISO9806  - Callback for Carnot model Collector_Unglazed_ISO9806
%   epw2wdb                                   - epw2wdb converts weather data from EnergyPlus format epw to Carnot format WDB
%   extendData                                - Inputs:       Data - matrix with input Data without extension


