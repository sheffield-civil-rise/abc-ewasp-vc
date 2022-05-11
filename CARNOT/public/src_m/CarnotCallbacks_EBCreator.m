function varargout = CarnotCallbacks_EBCreator(varargin)
% function varargout = CarnotCallbacks_EBCreator(varargin) is used by the
% Carnot THBCreator blocks. 
% The file contains also other subfunctions:
% function CreateMaskAnnotations(block)
% function CreateMaskVisibilities(block)
% function CreateInports(block)
%
%
% ***********************************************************************
% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2018, Solar-Institute Juelich of the FH Aachen.
% Additional Copyright for this file see list auf authors.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
% THE POSSIBILITY OF SUCH DAMAGE.
% $Revision: 548 $
% $Author: carnot-kefer $
% $Date: 2018-07-24 21:12:32 +0200 (Di., 24 Jul 2018) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/src_m/CarnotCallbacks_EBCreator.m $
% **********************************************************************
% D O C U M E N T A T I O N
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% author list:      aw -> Arnold Wohlfeil
%                   hf -> Bernd Hafner
%                   pk -> Patrick Kefer 
% version: CarnotVersion.MajorVersionOfFunction.SubversionOfFunction
%
% Version   Author  Changes                                     Date
% 6.3.0      pk      created                                     30jan2019
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% Switch for command line calls
    if nargin >= 1 && ischar(varargin{1})
        FunctionName = varargin{1};

        % Call the function
        if nargout > 0
            [varargout{1:nargout}] = feval(FunctionName, varargin{2:end});
        else
            feval(FunctionName, varargin{2:end});
        end
    else
        error('First argument must be a valid function name. Second argument must be the blockpath.')
        
    end
end



function CreateMaskVisibilities(block) %#ok<DEFNU>
    MaskValues = get_param(block, 'MaskValues');
    MaskVisibilities={'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'; ...
                      'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'; ...
                      'on';'on';'on';'on';'on';'on';'on';'on';'on';'on'; ...
                      'on';'on';'on'};

    %deactivate parameters

    if strcmp(MaskValues{1},'on') %ID
        MaskVisibilities{12}='off';
        MaskVisibilities{23}='off';
    end
    
    if strcmp(MaskValues{2},'on') %voltage line 1
        MaskVisibilities{13}='off';
        MaskVisibilities{24}='off';
    end
    
    if strcmp(MaskValues{3},'on') %voltage line 1
        MaskVisibilities{14}='off';
        MaskVisibilities{25}='off';
    end
    
    if strcmp(MaskValues{4},'on') %active power line 1
        MaskVisibilities{15}='off';
        MaskVisibilities{26}='off';
    end
    
    if strcmp(MaskValues{5},'on') %power factor line 1
        MaskVisibilities{16}='off';
        MaskVisibilities{27}='off';
    end
    
    if strcmp(MaskValues{6},'on') %voltage line 2
        MaskVisibilities{17}='off';
        MaskVisibilities{28}='off';
    end
    
    if strcmp(MaskValues{7},'on') %active power line 2
        MaskVisibilities{18}='off';
        MaskVisibilities{29}='off';
    end
    
    if strcmp(MaskValues{8},'on') %power factor line 2
        MaskVisibilities{19}='off';
        MaskVisibilities{30}='off';
    end
    
    if strcmp(MaskValues{9},'on') %voltage line 3
        MaskVisibilities{20}='off';
        MaskVisibilities{31}='off';
    end
    
    if strcmp(MaskValues{10},'on') %active power line 3
        MaskVisibilities{21}='off';
        MaskVisibilities{32}='off';
    end
    
    if strcmp(MaskValues{11},'on') %voltage line 3
        MaskVisibilities{22}='off';
        MaskVisibilities{33}='off';
    end        
    set_param(block, 'MaskVisibilities', MaskVisibilities);
end



function CreateMaskAnnotations(block) %#ok<DEFNU>
    %annotations
    AnnotationString='';
    MaskValues = get_param(block, 'MaskValues');
    
    if ~strcmp(MaskValues{1},'on') && strcmp(MaskValues{23},'on') %ID
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,'ID ',MaskValues{12}];
    end
    
    if ~strcmp(MaskValues{2},'on') && strcmp(MaskValues{24},'on') %Frequency
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{13}, ' Hz frequency'];
    end
    
    if ~strcmp(MaskValues{3},'on') && strcmp(MaskValues{25},'on') %Voltage1
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{14}, ' V Voltage'];
    end
    
    if ~strcmp(MaskValues{4},'on') && strcmp(MaskValues{26},'on') %active power 1
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{15}, ' W active Power'];
    end

    if ~strcmp(MaskValues{5},'on') && strcmp(MaskValues{27},'on') %power factor 1
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{16},' power factor '];
    end
    
    if ~strcmp(MaskValues{6},'on') && strcmp(MaskValues{28},'on') %mix
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{17}, ' V Voltage'];
    end
    
    if ~strcmp(MaskValues{7},'on') && strcmp(MaskValues{29},'on') %mix2
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{18}, ' W  active Power'];
    end
    
    if ~strcmp(MaskValues{8},'on') && strcmp(MaskValues{30},'on') %mix3
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{19}, ' power factor'];
    end
    
    if ~strcmp(MaskValues{9},'on') && strcmp(MaskValues{31},'on') %d
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{20}, 'V Voltage'];
    end
    
    if ~strcmp(MaskValues{10},'on') && strcmp(MaskValues{32},'on') %c
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{21}, ' W active power'];
    end
    
    if ~strcmp(MaskValues{11},'on') && strcmp(MaskValues{33},'on') %l
        if ~isempty(AnnotationString)
            AnnotationString=[AnnotationString,sprintf('\n')];
        end
        AnnotationString=[AnnotationString,MaskValues{22}, ' power factor'];
    end
           
    set_param(block, 'AttributesFormatString',AnnotationString);
end


function CreateInports(block) %#ok<DEFNU>
    MaskValue = get_param(block,'MaskValues');

    if strcmp(MaskValue{1},'on') %ID
        if ~strcmp(get_param([block,'/ID'],'BlockType'),'Inport')
            delete_line(block,'ID/1','BusCreator/1'); %delete connection
            delete_block([block,'/ID']); %delete block
            add_block('built-in/Inport',[block,'/ID']); %add new block
            set_param([block, '/ID'],'Position',[50   1*50+8   50+30   1*50+8+14]); %set new block's position
            add_line(block,'ID/1','BusCreator/1'); %add new connection
            handles=get_param([block, '/ID'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','ID'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/ID'],'BlockType'),'Constant')
            delete_line(block,'ID/1','BusCreator/1'); %delete connection
            delete_block([block,'/ID']); %delete block
            add_block('built-in/Constant',[block,'/ID']); %add new block
            set_param([block, '/ID'],'Position',[50   1*50   50+30   1*50+30]); %set new block's position
            set_param([block, '/ID'],'Value','ID'); %set mask varible as value
            add_line(block,'ID/1','BusCreator/1'); %add new connection
            handles=get_param([block, '/ID'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','ID'); %set line name
        end
    end
    
    if strcmp(MaskValue{2},'on') %Frequency
        if ~strcmp(get_param([block,'/Frequency'],'BlockType'),'Inport')
            delete_line(block,'Frequency/1','BusCreator/2'); %delete connection
            delete_block([block,'/Frequency']); %delete block
            add_block('built-in/Inport',[block,'/Frequency']); %add new block
            set_param([block, '/Frequency'],'Position',[50   2*50+8   50+30   2*50+8+14]); %set new block's position
            add_line(block,'Frequency/1','BusCreator/2'); %add new connection
            handles=get_param([block, '/Frequency'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Frequency'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/Frequency'],'BlockType'),'Constant')
            delete_line(block,'Frequency/1','BusCreator/2'); %delete connection
            delete_block([block,'/Frequency']); %delete block
            add_block('built-in/Constant',[block,'/Frequency']); %add new block
            set_param([block, '/Frequency'],'Position',[50   2*50   50+30   2*50+30]); %set new block's position
            set_param([block, '/Frequency'],'Value','f'); %set mask varible as value
            add_line(block,'Frequency/1','BusCreator/2'); %add new connection
            handles=get_param([block, '/Frequency'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Frequency'); %set line name
        end
    end
    
    if strcmp(MaskValue{3},'on') %Voltage 1
        if ~strcmp(get_param([block,'/Voltage1'],'BlockType'),'Inport')
            delete_line(block,'Voltage1/1','BusCreator/3'); %delete connection
            delete_block([block,'/Voltage1']); %delete block
            add_block('built-in/Inport',[block,'/Voltage1']); %add new block
            set_param([block, '/Voltage1'],'Position',[50   3*50+8   50+30   3*50+8+14]); %set new block's position
            add_line(block,'Voltage1/1','BusCreator/3'); %add new connection
            handles=get_param([block, '/Voltage1'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Voltage1'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/Voltage1'],'BlockType'),'Constant')
            delete_line(block,'Voltage1/1','BusCreator/3'); %delete connection
            delete_block([block,'/Voltage1']); %delete block
            add_block('built-in/Constant',[block,'/Voltage1']); %add new block
            set_param([block, '/Voltage1'],'Position',[50   3*50   50+30   3*50+30]); %set new block's position
            set_param([block, '/Voltage1'],'Value','v1'); %set mask varible as value
            add_line(block,'Voltage1/1','BusCreator/3'); %add new connection
            handles=get_param([block, '/Voltage1'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Voltage1'); %set line name
        end
    end

    if strcmp(MaskValue{4},'on') %ActPower1
        if ~strcmp(get_param([block,'/ActPower1'],'BlockType'),'Inport')
            delete_line(block,'ActPower1/1','BusCreator/4'); %delete connection
            delete_block([block,'/ActPower1']); %delete block
            add_block('built-in/Inport',[block,'/ActPower1']); %add new block
            set_param([block, '/ActPower1'],'Position',[50   4*50+8   50+30   4*50+8+14]); %set new block's position
            add_line(block,'ActPower1/1','BusCreator/4'); %add new connection
            handles=get_param([block, '/ActPower1'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','ActPower1'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/ActPower1'],'BlockType'),'Constant')
            delete_line(block,'ActPower1/1','BusCreator/4'); %delete connection
            delete_block([block,'/ActPower1']); %delete block
            add_block('built-in/Constant',[block,'/ActPower1']); %add new block
            set_param([block, '/ActPower1'],'Position',[50   4*50   50+30   4*50+30]); %set new block's position
            set_param([block, '/ActPower1'],'Value','p1'); %set mask varible as value
            add_line(block,'ActPower1/1','BusCreator/4'); %add new connection
            handles=get_param([block, '/ActPower1'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','ActPower1'); %set line name
        end
    end

    if strcmp(MaskValue{5},'on') %PowerFactor1
        if ~strcmp(get_param([block,'/PowerFactor1'],'BlockType'),'Inport')
            delete_line(block,'PowerFactor1/1','BusCreator/5'); %delete connection
            delete_block([block,'/PowerFactor1']); %delete block
            add_block('built-in/Inport',[block,'/PowerFactor1']); %add new block
            set_param([block, '/PowerFactor1'],'Position',[50   5*50+8   50+30   5*50+8+14]); %set new block's position
            add_line(block,'PowerFactor1/1','BusCreator/5'); %add new connection
            handles=get_param([block, '/PowerFactor1'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','PowerFactor1'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/PowerFactor1'],'BlockType'),'Constant')
            delete_line(block,'PowerFactor1/1','BusCreator/5'); %delete connection
            delete_block([block,'/PowerFactor1']); %delete block
            add_block('built-in/Constant',[block,'/PowerFactor1']); %add new block
            set_param([block, '/PowerFactor1'],'Position',[50   5*50   50+30   5*50+30]); %set new block's position
            set_param([block, '/PowerFactor1'],'Value','pf1'); %set mask varible as value
            add_line(block,'PowerFactor1/1','BusCreator/5'); %add new connection
            handles=get_param([block, '/PowerFactor1'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','PowerFactor1'); %set line name
        end
    end

    
    if strcmp(MaskValue{6},'on') %Voltage2
        if ~strcmp(get_param([block,'/Voltage2'],'BlockType'),'Inport')
            delete_line(block,'Voltage2/1','BusCreator/6'); %delete connection
            delete_block([block,'/Voltage2']); %delete block
            add_block('built-in/Inport',[block,'/Voltage2']); %add new block
            set_param([block, '/Voltage2'],'Position',[50   6*50+8   50+30   6*50+8+14]); %set new block's position
            add_line(block,'Voltage2/1','BusCreator/6'); %add new connection
            handles=get_param([block, '/Voltage2'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Voltage2'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/Voltage2'],'BlockType'),'Constant')
            delete_line(block,'Voltage2/1','BusCreator/6'); %delete connection
            delete_block([block,'/Voltage2']); %delete block
            add_block('built-in/Constant',[block,'/Voltage2']); %add new block
            set_param([block, '/Voltage2'],'Position',[50   6*50   50+30   6*50+30]); %set new block's position
            set_param([block, '/Voltage2'],'Value','v2'); %set mask varible as value
            add_line(block,'Voltage2/1','BusCreator/6'); %add new connection
            handles=get_param([block, '/Voltage2'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Voltage2'); %set line name
        end
    end

    if strcmp(MaskValue{7},'on') %ActPower2
        if ~strcmp(get_param([block,'/ActPower2'],'BlockType'),'Inport')
            delete_line(block,'ActPower2/1','BusCreator/7'); %delete connection
            delete_block([block,'/ActPower2']); %delete block
            add_block('built-in/Inport',[block,'/ActPower2']); %add new block
            set_param([block, '/ActPower2'],'Position',[50   7*50+8   50+30   7*50+8+14]); %set new block's position
            add_line(block,'ActPower2/1','BusCreator/7'); %add new connection
            handles=get_param([block, '/ActPower2'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','ActPower2'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/ActPower2'],'BlockType'),'Constant')
            delete_line(block,'ActPower2/1','BusCreator/7'); %delete connection
            delete_block([block,'/ActPower2']); %delete block
            add_block('built-in/Constant',[block,'/ActPower2']); %add new block
            set_param([block, '/ActPower2'],'Position',[50   7*50   50+30   7*50+30]); %set new block's position
            set_param([block, '/ActPower2'],'Value','p2'); %set mask varible as value
            add_line(block,'ActPower2/1','BusCreator/7'); %add new connection
            handles=get_param([block, '/ActPower2'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','ActPower2'); %set line name
        end
    end
    if strcmp(MaskValue{8},'on') %PowerFactor2
        if ~strcmp(get_param([block,'/PowerFactor2'],'BlockType'),'Inport')
            delete_line(block,'PowerFactor2/1','BusCreator/8'); %delete connection
            delete_block([block,'/PowerFactor2']); %delete block
            add_block('built-in/Inport',[block,'/PowerFactor2']); %add new block
            set_param([block, '/PowerFactor2'],'Position',[50   8*50+8   50+30   8*50+8+14]); %set new block's position
            add_line(block,'PowerFactor2/1','BusCreator/8'); %add new connection
            handles=get_param([block, '/PowerFactor2'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','PowerFactor2'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/PowerFactor2'],'BlockType'),'Constant')
            delete_line(block,'PowerFactor2/1','BusCreator/8'); %delete connection
            delete_block([block,'/PowerFactor2']); %delete block
            add_block('built-in/Constant',[block,'/PowerFactor2']); %add new block
            set_param([block, '/PowerFactor2'],'Position',[50   8*50   50+30   8*50+30]); %set new block's position
            set_param([block, '/PowerFactor2'],'Value','pf2'); %set mask varible as value
            add_line(block,'PowerFactor2/1','BusCreator/8'); %add new connection
            handles=get_param([block, '/PowerFactor2'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','PowerFactor2'); %set line name
        end
    end


    if strcmp(MaskValue{9},'on') %Voltage3
        if ~strcmp(get_param([block,'/Voltage3'],'BlockType'),'Inport')
            delete_line(block,'Voltage3/1','BusCreator/9'); %delete connection
            delete_block([block,'/Voltage3']); %delete block
            add_block('built-in/Inport',[block,'/Voltage3']); %add new block
            set_param([block, '/Voltage3'],'Position',[50   9*50+8   50+30   9*50+8+14]); %set new block's position
            add_line(block,'Voltage3/1','BusCreator/9'); %add new connection
            handles=get_param([block, '/Voltage3'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Voltage3'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/Voltage3'],'BlockType'),'Constant')
            delete_line(block,'Voltage3/1','BusCreator/9'); %delete connection
            delete_block([block,'/Voltage3']); %delete block
            add_block('built-in/Constant',[block,'/Voltage3']); %add new block
            set_param([block, '/Voltage3'],'Position',[50   9*50   50+30   9*50+30]); %set new block's position
            set_param([block, '/Voltage3'],'Value','v3'); %set mask varible as value
            add_line(block,'Voltage3/1','BusCreator/9'); %add new connection
            handles=get_param([block, '/Voltage3'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','Voltage3'); %set line name
        end
    end

    if strcmp(MaskValue{10},'on') %ActPower3
        if ~strcmp(get_param([block,'/ActPower3'],'BlockType'),'Inport')
            delete_line(block,'ActPower3/1','BusCreator/10'); %delete connection
            delete_block([block,'/ActPower3']); %delete block
            add_block('built-in/Inport',[block,'/ActPower3']); %add new block
            set_param([block, '/ActPower3'],'Position',[50   10*50+8   50+30   10*50+8+14]); %set new block's position
            add_line(block,'ActPower3/1','BusCreator/10'); %add new connection
            handles=get_param([block, '/ActPower3'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','ActPower3'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/ActPower3'],'BlockType'),'Constant')
            delete_line(block,'ActPower3/1','BusCreator/10'); %delete connection
            delete_block([block,'/ActPower3']); %delete block
            add_block('built-in/Constant',[block,'/ActPower3']); %add new block
            set_param([block, '/ActPower3'],'Position',[50   10*50   50+30   10*50+30]); %set new block's position
            set_param([block, '/ActPower3'],'Value','p3'); %set mask varible as value
            add_line(block,'ActPower3/1','BusCreator/10'); %add new connection
            handles=get_param([block, '/ActPower3'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','ActPower3'); %set line name
        end
    end

    if strcmp(MaskValue{11},'on') %PowerFactor3
        if ~strcmp(get_param([block,'/PowerFactor3'],'BlockType'),'Inport')
            delete_line(block,'PowerFactor3/1','BusCreator/11'); %delete connection
            delete_block([block,'/PowerFactor3']); %delete block
            add_block('built-in/Inport',[block,'/PowerFactor3']); %add new block
            set_param([block, '/PowerFactor3'],'Position',[50   11*50+8   50+30   11*50+8+14]); %set new block's position
            add_line(block,'PowerFactor3/1','BusCreator/11'); %add new connection
            handles=get_param([block, '/PowerFactor3'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','PowerFactor3'); %set line name
        end
    else
        if ~strcmp(get_param([block,'/PowerFactor3'],'BlockType'),'Constant')
            delete_line(block,'PowerFactor3/1','BusCreator/11'); %delete connection
            delete_block([block,'/PowerFactor3']); %delete block
            add_block('built-in/Constant',[block,'/PowerFactor3']); %add new block
            set_param([block, '/PowerFactor3'],'Position',[50   11*50   50+30   11*50+30]); %set new block's position
            set_param([block, '/PowerFactor3'],'Value','pf3'); %set mask varible as value
            add_line(block,'PowerFactor3/1','BusCreator/11'); %add new connection
            handles=get_param([block, '/PowerFactor3'],'LineHandles'); %get line handles
            set(handles.Outport(1),'Name','PowerFactor3'); %set line name
        end
    end
end