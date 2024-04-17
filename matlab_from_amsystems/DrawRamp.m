%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    DrawRamp.m
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
function DrawRamp()
%DrawRamp takes the window object and adds a moveable ramp event
%waveform graph.
global OKtoGraph;
h=guidata(gcf); %get graphic data
f=get(h.Igraph,'Parent');
set (f, 'WindowButtonUpFcn', @stopDragFcn);
 values=ComConstants;

ymax=str2double(get(h.Ymax,'string'));
ymin=str2double(get(h.Ymin,'string'));
Eper=str2double(get(h.EventPeriod,'string'));
Edur1=str2double(get(h.EventDur1,'string'));
Edur2=str2double(get(h.EventDur2,'string'));
Edur3=str2double(get(h.EventDur3,'string')); 
EID=int16(get(h.EventID,'Value'));

 [Atp, AmpNoDur ,AmpDur1, AmpDur2, AmpDur3]=getOffsetAmps(EID);

 xmax=Eper+Eper/5;
cla(h.Igraph,'reset');   
plot(h.Igraph,[0 0],[ymin ymax],'k','LineWidth',2);
ylim(h.Igraph,[ymin,ymax]);
xlim(h.Igraph, [-Eper/20,xmax]);
 grid(h.Igraph,'minor');
     
%% Begin time lines     
     Begin_line=line([0,0],[AmpNoDur-ymax/10 AmpNoDur+ymax/10], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'Parent', h.Igraph);

%********  Event Amp1 line   
    D1_line=line([0,Edur1],[AmpNoDur AmpDur1], ...
        'color' , 'magenta', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragD1, ...
        'Parent', h.Igraph);
 
%******* Edur1 time    
    Edur1_line=line([Edur1,Edur1],[AmpDur1-ymax/10 AmpDur1+ymax/10], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragEdur1, ...
        'Parent', h.Igraph); 
      
%********  Event Amp1 to Amp2 line   
    D2_line=line([Edur1,Edur1+Edur2],[AmpDur1 AmpDur3], ...
        'color' , 'green', ...
        'linewidth', 3, ...
        'Parent', h.Igraph);  
%******* Edur2 time    
    Edur2_line=line([Edur1+Edur2,Edur1+Edur2],[AmpDur3-ymax/10 AmpDur3+ymax/10], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragEdur2, ...
        'Parent', h.Igraph);
    
%********  Event Dur3 line   
      mycolor='cyan';
    D3_line=line([Edur1+Edur2,Edur1+Edur2+Edur3],[AmpDur3 AmpNoDur], ...
        'color' , mycolor, ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragD3, ...
        'Parent', h.Igraph);       

%******* Edur3 time    
    Edur3_line=line([Edur1+Edur2+Edur3,Edur1+Edur2+Edur3],[AmpNoDur-ymax/10 AmpNoDur+ymax/10], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragEdur3, ...
        'Parent', h.Igraph);    
    
%********  Event pp line   
    PP_line=line([Edur1+Edur2+Edur3,Eper],[AmpNoDur AmpNoDur], ...
        'color' , 'yellow', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragTLev, ...
        'Parent', h.Igraph); 
    
%******* End PP time    
    EndPP_line=line([Eper,Eper],[AmpNoDur-ymax/10 AmpNoDur+ymax/10], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragEndPP, ...
        'Parent', h.Igraph); 

    %% start Dragging functions
    function startDragTLev(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingTLev)
    end
    function startDragD1(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingD1)
    end
    function startDragD3(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingD3)
    end
    function startDragEndPP(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingEndPP)
    end
    function startDragEdur1(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingEdur1)
    end
    function startDragEdur2(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingEdur2)
    end
    function startDragEdur3(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingEdur3)
    end

%% Dragging functions
    function draggingTLev(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        y=ylimits(pt(3), ymax, ymin);
        set(Begin_line, 'YData', [y-ymax/10 y+ymax/10]);
        set(D1_line, 'YData', [y A1]);
        set(D3_line, 'YData', [A3 y]);
        set(PP_line, 'YData', y*[1 1] );
        set(EndPP_line, 'YData', [y-ymax/10 y+ymax/10]);
    end
    function draggingD1(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        y=ylimits(pt(3), ymax, ymin);
        set(D1_line, 'YData', [An y]);
        set(Edur1_line,'YData', [y-ymax/10 y+ymax/10]);
       set(D2_line, 'YData', [y A3]);          
    end    
    function draggingEdur1(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        D1plusD2=str2double(get(h.EventDur1,'String')) + ...
              str2double(get(h.EventDur2,'String'));
        if get(h.EventType,'Value') == values.event.type.biphasic+1
             x=xlimits(pt(1),D1plusD2-Edur2/2,0); 
        else
            x=xlimits( pt(1) ,D1plusD2 ,0 ); 
        end
        
        set(Edur1_line, 'XData', x*[1 1]);
        set(D1_line, 'XData', [0 x ]);
        set(D2_line, 'XData', [x D1plusD2]);        
    end 
 function draggingEdur2(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        D1plusD2=str2double(get(h.EventDur1,'String')) + ...
        str2double(get(h.EventDur2,'String'));
        D1plusD2plusD3=str2double(get(h.EventDur1,'String')) + ...
        str2double(get(h.EventDur2,'String')) + ...
        str2double(get(h.EventDur3,'String'));
        x=xlimits( pt(1) ,D1plusD2plusD3, str2double(get(h.EventDur1,'String')) ); 

        set(Edur2_line, 'XData', x*[1 1]);
        set(D3_line, 'XData', [x D1plusD2plusD3]);
        set(D2_line, 'XData', [str2double(get(h.EventDur1,'String'))  x]);        
    end 
function draggingEdur3(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        D1plusD2=str2double(get(h.EventDur1,'String')) + ...
              str2double(get(h.EventDur2,'String'));
          
            x=xlimits( pt(1) ,str2double(get(h.EventPeriod,'String')), D1plusD2 ); 
        
        set(Edur3_line, 'XData', x*[1 1]);
        set(D3_line, 'XData', [D1plusD2 x ]);
        set(PP_line, 'XData', [x  str2double(get(h.EventPeriod,'String'))]);
    end 
    function draggingD3(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        y=ylimits(pt(3), ymax, ymin);
        set(D3_line, 'YData', [y An]);
        set(Edur2_line,'YData', [y-ymax/10 y+ymax/10]);
        set(D2_line, 'YData', [A1 y]);              
    end    
    function draggingEndPP(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        D1plusD2plusD3=str2double(get(h.EventDur1,'String')) + ...
              str2double(get(h.EventDur2,'String')) + ...
              str2double(get(h.EventDur3,'String'));
        x=xlimits( pt(1) ,xmax ,D1plusD2plusD3 );
        set(EndPP_line, 'XData', x*[1 1]);
        set(PP_line, 'XData', [D1plusD2plusD3 x ]);
    end 

%% Dragging has stoped function (where all the work is done)
    function stopDragFcn(varargin)
    %         b = get(b_line, 'XData');
    %         sprintf('X coordinate of blue line: %5.5f\n',b(1))
    %         r = get(r_line, 'XData');
    %         sprintf('X coordinate of red line: %5.5f\n',r(1))
    [Atp, Atw ,A1, A2, A3]=getOffsetAmps(EID);
    OKtoGraph=0;
    oORh=get(h.OffsetOrHold,'Value');
    TLy = get(PP_line, 'YData');
    if abs(TLy(1)-Atw) >0.0001
        switch oORh 
           case 1  % offset
               set(h.TrainLevel,'String', num2str(TLy(1)));
               set(h.EventAmp1,'String', num2str(A1-TLy(1)));
               if get(h.EventType,'Value') == values.event.type.biphasic+1
                   set(h.EventAmp2,'String', num2str(A3-TLy(1)));
                   processUserInput(h.EventAmp2);
               end
                processUserInput(h.TrainLevel);
                processUserInput(h.EventAmp1);
           case 2   %hold
                set(h.TrainLevel,'String', num2str(TLy(1)));
                processUserInput(h.TrainLevel);
           case 3   %none
                set(h.OffsetOrHold,'Value',2)
                set(h.TrainLevel,'String', num2str(TLy(1)));
                processUserInput(h.TrainLevel);
        end 
    end

    D1y = get(D1_line, 'YData');
    if abs(D1y(2)- A1)>0.0001
        Eamp1=RetEamp1(D1y(2));
        set(h.EventAmp1,'String', num2str(Eamp1) );
        processUserInput(h.EventAmp1);
    end
    
    D3y = get(D3_line, 'YData');
    if abs(D3y(1)- A3) >0.0001
        Eamp2=RetEamp3(D3y(1));
        set(h.EventAmp2,'String', num2str(Eamp2) );
        processUserInput(h.EventAmp2);
    end        

        
    Dur1x=get(D1_line,'XDATA');
    if abs((Dur1x(2)-Dur1x(1)) - str2double(get(h.EventDur1,'string')))>0.0001
        set(h.EventDur1,'String',num2str(Dur1x(2)-Dur1x(1)));
        processUserInput(h.EventDur1);
    end
    Dur2x=get(D2_line,'XDATA');
    if abs((Dur2x(2)-Dur2x(1))- str2double(get(h.EventDur2,'string')))>0.0001
        set(h.EventDur2,'String',num2str(Dur2x(2)-Dur2x(1)));
        processUserInput(h.EventDur2);
    end  
    Dur3x=get(D3_line,'XDATA');
    if abs((Dur3x(2)-Dur3x(1)) - str2double(get(h.EventDur3,'string')))>0.0001
        set(h.EventDur3,'String',num2str(Dur3x(2)-Dur3x(1)));
        processUserInput(h.EventDur3);
    end     

    PPx=get(PP_line,'XDATA');
    PPlinelength=   str2double(get(h.EventPeriod,'string')) - ...
                    str2double(get(h.EventDur1,'string')) - ...
                    str2double(get(h.EventDur2,'string')) - ...
                    str2double(get(h.EventDur3,'string'));         
   
    if abs(PPx(2)-PPx(1)-PPlinelength) > 0.0001 
        set(h.EventPeriod,'String',num2str(PPx(2)));
        processUserInput(h.EventPeriod);
    end      
    
    set(f,'WindowButtonMotionFcn', '');
    Plotit();
    OKtoGraph=1;
    end

%% limit functions
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
