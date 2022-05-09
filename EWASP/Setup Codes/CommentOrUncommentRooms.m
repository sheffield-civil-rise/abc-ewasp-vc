function []=CommentOrUncommentRooms(roomCount,HPType,variableASHP)

if roomCount == 1 
set_param('Final_EWASP_VC/Subsystem_Room1','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room2','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room3','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room4','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room5','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room6','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room7','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room8','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room9','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room10','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room11','commented','on')
elseif roomCount == 2
set_param('Final_EWASP_VC/Subsystem_Room1','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room2','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room3','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room4','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room5','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room6','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room7','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room8','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room9','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room10','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room11','commented','on')
    elseif roomCount == 3 
set_param('Final_EWASP_VC/Subsystem_Room1','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room2','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room3','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room4','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room5','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room6','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room7','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room8','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room9','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room10','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room11','commented','on')
    elseif roomCount == 4 
set_param('Final_EWASP_VC/Subsystem_Room1','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room2','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room3','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room4','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room5','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room6','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room7','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room8','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room9','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room10','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room11','commented','on')
    elseif roomCount == 5 
set_param('Final_EWASP_VC/Subsystem_Room1','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room2','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room3','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room4','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room5','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room6','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room7','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room8','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room9','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room10','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room11','commented','on')
    elseif roomCount == 6 
set_param('Final_EWASP_VC/Subsystem_Room1','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room2','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room3','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room4','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room5','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room6','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room7','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room8','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room9','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room10','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room11','commented','on')
    elseif roomCount == 7 
set_param('Final_EWASP_VC/Subsystem_Room1','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room2','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room3','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room4','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room5','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room6','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room7','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room8','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room9','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room10','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room11','commented','on')
    elseif roomCount == 8 
set_param('Final_EWASP_VC/Subsystem_Room1','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room2','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room3','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room4','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room5','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room6','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room7','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room8','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room9','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room10','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room11','commented','on')
    elseif roomCount == 9 
set_param('Final_EWASP_VC/Subsystem_Room1','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room2','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room3','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room4','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room5','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room6','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room7','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room8','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room9','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room10','commented','on')
set_param('Final_EWASP_VC/Subsystem_Room11','commented','on')
    elseif roomCount == 10 
set_param('Final_EWASP_VC/Subsystem_Room1','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room2','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room3','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room4','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room5','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room6','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room7','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room8','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room9','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room10','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room11','commented','on')
    elseif roomCount == 11 
set_param('Final_EWASP_VC/Subsystem_Room1','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room2','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room3','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room4','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room5','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room6','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room7','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room8','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room9','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room10','commented','off')
set_param('Final_EWASP_VC/Subsystem_Room11','commented','off')
    else
        error('Definition of matrices infers room count is not between 1 and 11 - check for errors in matrix definitions')
end


if HPType=='G'
    
set_param('Final_EWASP_VC/GSHP_Subsystem','commented','off')
set_param('Final_EWASP_VC/ASHP_Subsystem','commented','on')
set_param('Final_EWASP_VC/ASHP_Subsystem_Variable','commented','on')

    
elseif and(HPType=='A',variableASHP==1)
    
set_param('Final_EWASP_VC/GSHP_Subsystem','commented','on')
set_param('Final_EWASP_VC/ASHP_Subsystem','commented','on')
set_param('Final_EWASP_VC/ASHP_Subsystem_Variable','commented','off')

elseif HPType=='A'
    
set_param('Final_EWASP_VC/GSHP_Subsystem','commented','on')
set_param('Final_EWASP_VC/ASHP_Subsystem','commented','off')
set_param('Final_EWASP_VC/ASHP_Subsystem_Variable','commented','on')

else
    
    error('HPType must equal either G or A')
    
end




end