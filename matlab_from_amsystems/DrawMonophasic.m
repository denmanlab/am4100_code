%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    DrawMonophasic.m
%
% Copyright:   A-M Systems
%
% Author:      DHM
%
% Description:
%   This is a MATLAB script that takes the event parameters and draws an
%   editable graph where the lines can be moved to new event values
%
%	Ensure that the location of this file is in your MATLAB Path.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DrawMonophasic()
%DrawMonophasic takes the window object and adds a moveable biphasic event
%waveform graph.
global OKtoGraph;
h=guidata(gcf); %get graphic data
f=get(h.Igraph,'Parent');
set (f, 'WindowButtonUpFcn', @stopDragFcn);


ymax=str2double(get(h.Ymax,'string'));
ymin=str2double(get(h.Ymin,'string'));


   Eper=str2double(get(h.EventPeriod,'string'));
   Edur1=str2double(get(h.EventDur1,'string'));
%    Edur2=str2double(get(h.EventDur2,'string'));
%    Edur3=str2double(get(h.EventDur3,'string'));
   EID=int16(get(h.EventID,'Value'));
 [Atp, AmpNoDur ,AmpDur1, AmpDur2, AmpDur3]=getOffsetAmps(EID);

 if get(h.Auto,'Value')==3  %Auto = Square
        Eper=2*Edur1;
 end
 xmax=Eper+Eper/5;
cla(h.Igraph,'reset');   
           plot(h.Igraph,[0 0],[ymin ymax],'k','LineWidth',2);
    ylim(h.Igraph,[ymin,ymax]);
    xlim(h.Igraph, [-Eper/20,xmax]);

     grid(h.Igraph,'minor');

     Ed2D1_line=line([0,0],[AmpNoDur AmpDur1], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'Parent', h.Igraph);
%********  Event Amp1 line   
    D1_line=line([0,Edur1],[AmpDur1 AmpDur1], ...
        'color' , 'magenta', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragD1, ...
        'Parent', h.Igraph);
  %******** EDur1 to PP line
     D12PP_line=line([Edur1,Edur1],[AmpDur1 AmpNoDur], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragD12PP, ...
        'Parent', h.Igraph);  
   %********  Event pp line   
    PP_line=line([Edur1,Eper],[AmpNoDur AmpNoDur], ...
        'color' , 'yellow', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragTLev, ...
        'Parent', h.Igraph); 
    EndPP_line=line([Eper,Eper],[AmpNoDur-ymax/10 AmpNoDur+ymax/10], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragEndPP, ...
        'Parent', h.Igraph);  
    function startDragTLev(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingTLev)
    end
    function startDragD1(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingD1)
    end
    function startDragD12PP(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingD12PP)
    end
    function startDragEndPP(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingEndPP)
    end
    function draggingTLev(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        y=ylimits(pt(3), ymax, ymin);
        set(Ed2D1_line, 'YData', [y A1]);
        set(D12PP_line, 'YData', [A1 y]);
        set(PP_line, 'YData', y*[1 1] );
        set(EndPP_line, 'YData', [y-ymax/10 y+ymax/10]);
    end

    function draggingD1(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        y=ylimits(pt(3), ymax, ymin);
        set(Ed2D1_line, 'YData', [An y]);
        set(D1_line, 'YData', y*[1 1]);
        set(D12PP_line, 'YData', [y An]);
    end    

    function draggingD12PP(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        x=xlimits( pt(1) ,Eper,0 );   
        set(D12PP_line, 'XData', x*[1 1]);
        if get(h.Auto,'Value')==3  %Auto = Square
           set(PP_line, 'XData', [x  x*2]);
           set(EndPP_line, 'XData', (x*2)*[1 1]);
        else
           set(PP_line, 'XData', [x  Eper]); 
        end
        set(D1_line, 'XData', [0 x]);
    end 
    function draggingEndPP(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        x=xlimits( pt(1) ,xmax , Edur1 );
        if get(h.Auto,'Value')==3  %Auto = Square
            x=round(x/2*1000)/500;
            set
            set(EndPP_line, 'XData', x*[1 1]);
            set(PP_line, 'XData', [Edur1 x ]);
            set(D1_line, 'XData', [0 x/2]);
            set(D12PP_line, 'XData', (x/2)*[1 1]);
        else
            set(EndPP_line, 'XData', x*[1 1]);
            set(PP_line, 'XData', [Edur1 x ]);
        end

    end 

    function stopDragFcn(varargin)
    %         b = get(b_line, 'XData');
    %         sprintf('X coordinate of blue line: %5.5f\n',b(1))
    %         r = get(r_line, 'XData');
    %         sprintf('X coordinate of red line: %5.5f\n',r(1))
    
    OKtoGraph=0;
    [Atp, Atw ,A1, A2, A3]=getOffsetAmps(EID);
    oORh=get(h.OffsetOrHold,'Value');
    PPy = get(PP_line, 'YData');
    if abs(PPy(1)-Atw) >0.0001
        switch oORh 
           case 1  % offset
               set(h.TrainLevel,'String', num2str(PPy(1)));
               set(h.EventAmp1,'String', num2str(A1-PPy(1)));
                processUserInput(h.TrainLevel);
                processUserInput(h.EventAmp1);
           case 2   %hold
                set(h.TrainLevel,'String', num2str(PPy(1)));
                processUserInput(h.TrainLevel);
           case 3   %none
                set(h.OffsetOrHold,'Value',2)
                set(h.TrainLevel,'String', num2str(PPy(1)));
                processUserInput(h.TrainLevel);
        end 
    end
    D1y = get(D1_line, 'YData');
    if abs(D1y(1)- A1)>0.0001
        Eamp1=RetEamp1(D1y(1));
        set(h.EventAmp1,'String', num2str(Eamp1) );
        processUserInput(h.EventAmp1);
    end       
    Dur1x=get(D1_line,'XDATA');
    if abs((Dur1x(2)-Dur1x(1)) - str2double(get(h.EventDur1,'string')))>0.0001
        set(h.EventDur1,'String',num2str(Dur1x(2)-Dur1x(1)));
        processUserInput(h.EventDur1);
    end

    PPx=get(PP_line,'XDATA');
    PPlinelength=  Eper - Edur1;    
    if abs(PPx(2)-PPx(1)-PPlinelength) > 0.0001 
        set(h.EventPeriod,'String',num2str(PPx(2)));
        processUserInput(h.EventPeriod);
    end      
    
    set(f,'WindowButtonMotionFcn', '');
    Plotit();
        OKtoGraph=1;
    end

     function out=ylimits(y, ymax, ymin)
        yRes=str2double(get(h.ySteps,'string'));
        if yRes>ymax
            yRes=ymax/10;
        end    
        y=round(y/yRes)*yRes;
         if y>ymax
            y=ymax;
        end
        if y<ymin
          y=ymin;
        end
        out=y;
    end  
    function out=xlimits(x, xmax, xmin)
        xRes=str2double(get(h.xSteps,'string'));
        if xRes>xmax
            xRes=xmax/10;
        end
        x=round(x/xRes)*xRes;
        if x>xmax
            x=xmax;
        end
        if x<xmin
          x=xmin;
        end
        out=x;
    end 

end
