function MaskIcon(block)
    set_param(block, 'MaskDisplay',...
        sprintf('plot(-20,0,120,100,[10,70,70,10,10],[10,10,70,70,10],[70,90,90,30,10],[10,30,90,90,70],[90,70],[90,70],[50,30],[60,60],[40,40],[30,60])'));
    set_param(block,'BackgroundColor','white');
end
