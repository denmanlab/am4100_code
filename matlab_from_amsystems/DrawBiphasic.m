%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    DrawBiphasic.m
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

function DrawBiphasic()
%DrawBiphasic takes the window object and adds a moveable biphasic event
%waveform graph.
global OKtoGraph;  % when the graph is being made, values can not be updated.
values=ComConstants;
h=guidata(gcf); %get graphic data
f=get(h.Igraph,'Parent');  % get the parent window.
set (f, 'WindowButtonUpFcn', @stopDragFcn);
sym =0;
if get(h.EventType,'Value') == values.event.type.biphasic+1 
    sym=1;
end

ymax=str2double(get(h.Ymax,'string'));  %graph maximum y axis
ymin=str2double(get(h.Ymin,'string'));   %graph minimum y axis
   Eper=str2double(get(h.EventPeriod,'string'));
   Edur1=str2double(get(h.EventDur1,'string'));
   Edur2=str2double(get(h.EventDur2,'string'));
%   Edur3=str2double(get(h.EventDur3,'string'));  
   EID=int16(get(h.EventID,'Value'));

[Atp, AmpNoDur ,AmpDur1, AmpDur2, AmpDur3]=getOffsetAmps(EID);

if sym ==1 
    Edur3=Edur1;
    AmpDur3=-(AmpDur1-AmpNoDur)+AmpNoDur;
else
    Edur3=str2double(get(h.EventDur3,'string')); 
end   

xmax=Eper+Eper/5;  % graph maximum x value.
cla(h.Igraph,'reset');   % clear the graph
plot(h.Igraph,[0 0],[ymin ymax],'k','LineWidth',2); % make axis
ylim(h.Igraph,[ymin,ymax]);   % Set y axis limits
xlim(h.Igraph, [-Eper/20,xmax]); % Set x axis limits
grid(h.Igraph,'minor'); 

%% Draw Lines
Ed2D1_line=line([0,0],[AmpNoDur AmpDur1], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'Parent', h.Igraph);
    %         'ButtonDownFcn', @startDragEd2D1, ...
%********  Event Amp1 line   

    D1_line=line([0,Edur1],[AmpDur1 AmpDur1], ...
        'color' , 'magenta', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragD1, ...
        'Parent', h.Igraph);
    
%******** Eamp1 to EDur2 line
     D12D2_line=line([Edur1,Edur1],[AmpDur1 AmpDur2], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragD12D2, ...
        'Parent', h.Igraph);
    
%********  Event Dur2 line   

    D2_line=line([Edur1,Edur1+Edur2],[AmpDur2 AmpDur2], ...
        'color' , 'yellow', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragTLev, ...
        'Parent', h.Igraph);    
%******** EDur2 to EDur3 line
     D22D3_line=line([Edur1+Edur2,Edur1+Edur2],[AmpDur2 AmpDur3], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragD22D3, ...
        'Parent', h.Igraph);
 %********  Event Dur3 line   
 if sym ==1 
     mycolor='magenta';
 else
      mycolor='cyan';
 end
    D3_line=line([Edur1+Edur2,Edur1+Edur2+Edur3],[AmpDur3 AmpDur3], ...
        'color' , mycolor, ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragD3, ...
        'Parent', h.Igraph);       
  %******** EDur3 to PP line
     D32PP_line=line([Edur1+Edur2+Edur3,Edur1+Edur2+Edur3],[AmpDur3 AmpNoDur], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragD32PP, ...
        'Parent', h.Igraph);  
   %********  Event pp line   
    PP_line=line([Edur1+Edur2+Edur3,Eper],[AmpNoDur AmpNoDur], ...
        'color' , 'yellow', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragTLev, ...
        'Parent', h.Igraph); 
    
    EndPP_line=line([Eper,Eper],[AmpNoDur-ymax/10 AmpNoDur+ymax/10], ...
        'color' , 'black', ...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragEndPP, ...
        'Parent', h.Igraph); 
    
%% start Dragging Functions    
    function startDragTLev(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingTLev)
    end
    function startDragD1(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingD1)
    end
    function startDragD3(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingD3)
    end
    function startDragD12D2(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingD12D2)
    end
    function startDragD22D3(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingD22D3)
    end
    function startDragD32PP(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingD32PP)
    end
    function startDragEndPP(varargin)
            set(f, 'WindowButtonMotionFcn', @draggingEndPP)
    end

%% Dragging Functions
    function draggingTLev(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        y=ylimits(pt(3), ymax, ymin);
%         set(Ed_line, 'YData', y*[1 1]);
        set(Ed2D1_line, 'YData', [y A1]);
        %set(D1_line, 'YData', [? ?]);
        set(D12D2_line, 'YData', [A1 y]);
        set(D2_line, 'YData', y*[1 1] );
        set(D22D3_line, 'YData', [y A3]);
        %set(D3_line, 'YData', [? ?]);
        set(D32PP_line, 'YData', [A3 y]);
        set(PP_line, 'YData', y*[1 1] );
        set(EndPP_line, 'YData', [y-ymax/10 y+ymax/10]);
    end
    function draggingD1(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        y=ylimits(pt(3), ymax, ymin);
        set(Ed2D1_line, 'YData', [An y]);
        set(D1_line, 'YData', y*[1 1]);
        set(D12D2_line, 'YData', [y An]);
        if sym ==1 
            set(D22D3_line, 'YData', [An, -(y-An)+An]);
            set(D3_line, 'YData', (-(y-An)+An)*[1 ,1]);
            set(D32PP_line, 'YData', [-(y-An)+An, An]);            
        end
    end    
    function draggingD3(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        y=ylimits(pt(3), ymax, ymin);
        set(D22D3_line, 'YData', [An y]);
        set(D3_line, 'YData', y*[1 1]);
        set(D32PP_line, 'YData', [y An]);
        if sym ==1 
            set(Ed2D1_line, 'YData', [An, -(y-An)+An]);
            set(D1_line, 'YData', (-(y-An)+An)*[1 ,1]);
            set(D12D2_line, 'YData', [-(y-An)+An, An]);            
        end        
    end    
    function draggingD12D2(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        D1plusD2=str2double(get(h.EventDur1,'String')) + ...
              str2double(get(h.EventDur2,'String'));
        if sym == 1
             x=xlimits(pt(1),D1plusD2-Edur2/2,0); 
        else
             x=xlimits(pt(1),D1plusD2,0); 
        end
        set(D12D2_line, 'XData', x*[1 1]);
        set(D1_line, 'XData', [0 x]);
        set(D2_line, 'XData', [x D1plusD2 ]);
        if sym ==1
            D1plusD2plusD1=str2double(get(h.EventDur1,'String')) + ...
                  str2double(get(h.EventDur2,'String')) + ...
                  str2double(get(h.EventDur1,'String'));            
            set(D22D3_line, 'XData', (D1plusD2plusD1-x)*[1 1]);
            set(D2_line, 'XData', [x D1plusD2plusD1-x]);
            set(D3_line, 'XData', [D1plusD2plusD1-x D1plusD2plusD1 ]);
        end
    end    
    function draggingD22D3(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        if sym == 1
         D1plusD2plusD3=str2double(get(h.EventDur1,'String')) + ...
              str2double(get(h.EventDur2,'String')) + ...
              str2double(get(h.EventDur1,'String'));
             x=xlimits(pt(1),D1plusD2plusD3,str2double(get(h.EventDur1,'String'))+Edur2/2);
        else
         D1plusD2plusD3=str2double(get(h.EventDur1,'String')) + ...
              str2double(get(h.EventDur2,'String')) + ...
              str2double(get(h.EventDur3,'String'));
             x=xlimits(pt(1),D1plusD2plusD3,str2double(get(h.EventDur1,'String')));
        end         
        
        
        set(D22D3_line, 'XData', x*[1 1]);
        set(D2_line, 'XData', [str2double(get(h.EventDur1,'String')) x]);
        set(D3_line, 'XData', [x D1plusD2plusD3 ]);
        if sym ==1
            D1plusD2=str2double(get(h.EventDur1,'String')) + ...
                  str2double(get(h.EventDur2,'String')); 
            D1plusD2plusD1=str2double(get(h.EventDur1,'String')) + ...
              str2double(get(h.EventDur2,'String')) + ...
              str2double(get(h.EventDur1,'String'));
            set(D12D2_line, 'XData', (D1plusD2plusD1-x)*[1 1]);
            set(D1_line, 'XData', [0 D1plusD2plusD1-x]);
            set(D2_line, 'XData', [D1plusD2plusD1-x x ]);        
        end
        
    end    
    function draggingD32PP(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        D1plusD2=str2double(get(h.EventDur1,'String')) + ...
              str2double(get(h.EventDur2,'String')); 
        x=xlimits( pt(1) ,str2double(get(h.EventPeriod,'String')),D1plusD2 );
        
        set(D32PP_line, 'XData', x*[1 1]);
        set(D3_line, 'XData', [ D1plusD2 x]);
        set(PP_line, 'XData', [x  str2double(get(h.EventPeriod,'String'))]);
        if sym ==1
            set(D12D2_line, 'XData', (x-D1plusD2)*[1 1]);
            set(D1_line, 'XData', [0 x-D1plusD2]);
            set(D2_line, 'XData', [x-D1plusD2 D1plusD2 ]);
        end
        
    end 
    function draggingEndPP(varargin)
        [At, An ,A1, A2, A3]=getOffsetAmps(EID);
        pt=get(h.Igraph,'CurrentPoint');
        if sym == 1
          D1plusD2plusD3=str2double(get(h.EventDur1,'String')) + ...
              str2double(get(h.EventDur2,'String')) + ...
              str2double(get(h.EventDur1,'String'));
        else
          D1plusD2plusD3=str2double(get(h.EventDur1,'String')) + ...
              str2double(get(h.EventDur2,'String')) + ...
              str2double(get(h.EventDur3,'String'));
        end
         
        x=xlimits( pt(1) ,xmax ,D1plusD2plusD3 );
        
        set(EndPP_line, 'XData', x*[1 1]);
        set(PP_line, 'XData', [D1plusD2plusD3 x ]);
    end

%% Dragging has stopped function(where all the work is done )
    function stopDragFcn(varargin)
    %         b = get(b_line, 'XData');
    %         sprintf('X coordinate of blue line: %5.5f\n',b(1))
    %         r = get(r_line, 'XData');
    %         sprintf('X coordinate of red line: %5.5f\n',r(1))
    [Atp, Atw ,A1, A2, A3]=getOffsetAmps(EID);
    OKtoGraph=0;
    oORh=get(h.OffsetOrHold,'Value');
    D2y = get(D2_line, 'YData');
    if abs(D2y(1)-Atw) >0.0001
        switch oORh 
           case 1  % offset
               set(h.TrainLevel,'String', num2str(D2y(1)));
               set(h.EventAmp1,'String', num2str(A1-D2y(1)));
               if sym ~=  1
                   set(h.EventAmp2,'String', num2str(A3-D2y(1)));
                   processUserInput(h.EventAmp2);
               end
                processUserInput(h.TrainLevel);
                processUserInput(h.EventAmp1);
           case 2   %hold
                set(h.TrainLevel,'String', num2str(D2y(1)));
                processUserInput(h.TrainLevel);
           case 3   %none
                set(h.OffsetOrHold,'Value',2)
                set(h.TrainLevel,'String', num2str(D2y(1)));
                processUserInput(h.TrainLevel);
        end 
    end
    %     Ed2D1=get(Ed2D1_line,'XData');
    D1y = get(D1_line, 'YData');
    if abs(D1y(1)- A1)>0.0001
        Eamp1=RetEamp1(D1y(1));
        set(h.EventAmp1,'String', num2str(Eamp1) );
        processUserInput(h.EventAmp1);
    end
    
    if sym ~=1
        D3y = get(D3_line, 'YData');
        if abs(D3y(1)- A3) >0.0001
            Eamp2=RetEamp3(D3y(1));
            set(h.EventAmp2,'String', num2str(Eamp2) );
            processUserInput(h.EventAmp2);
        end        
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
    if sym ~=1
        Dur3x=get(D3_line,'XDATA');
        if abs((Dur3x(2)-Dur3x(1)) - str2double(get(h.EventDur3,'string')))>0.0001
            set(h.EventDur3,'String',num2str(Dur3x(2)-Dur3x(1)));
            processUserInput(h.EventDur3);
        end     
    end
    

    PPx=get(PP_line,'XDATA');
    if sym ==1
    PPlinelength=   str2double(get(h.EventPeriod,'string')) - ...
                    str2double(get(h.EventDur1,'string')) - ...
                    str2double(get(h.EventDur2,'string')) - ...
                    str2double(get(h.EventDur1,'string')); 
    else
    PPlinelength=   str2double(get(h.EventPeriod,'string')) - ...
                    str2double(get(h.EventDur1,'string')) - ...
                    str2double(get(h.EventDur2,'string')) - ...
                    str2double(get(h.EventDur3,'string'));         
    end
   
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
