%Code used in experiment 2

s = serialport("COM9",9600);
writeline(s,"MEASUREMENT:MEAS1:VALUE?")
tvect = [str2double(readline(s))];
zvect = [str2double(readline(s))];

count = 0;
%disp("here1");

sampf=65;
T = 1/sampf;
L = 49;
t = (0:L-1)*T;

[params] = xlsread("pred_experiment2.xlsx");
dual_1 = params(2:end,2);

while 1>0
    %disp("here2");
    if length(zvect)==49
            %disp("here3");
            zvect(1)=[];
            tvect(1)=[];
            count = count -1;
            %avg = avg - zvect(1);
            %plot(tvect,zvect)
            %ylim([0 700]);
            %writematrix(zvect,'15Hz_analogdata2.xls','WriteMode','append');
            %writematrix(tvect,'15Hz_timedata2.xls','WriteMode','append');
            
    end

    tval= str2double(readline(s));
    zval= str2double(readline(s));
    zvect=[zvect zval];
    tvect=[tvect tval];
    count = count +1;

    
    if length(zvect)==49
        %disp("before hereeee");
        Y = fft(zvect);             
        
        P2 = abs(Y/L);                
        P1 = P2(1:L/2+1);            %Obtain single-sided spectrum
        P1(2:end-1) = 2*P1(2:end-1);
        f = sampf*(0:(L/2))/L;        %Frequencies over which magnitude data is available
        f2 = sampf*(0:L-1)/L;
        %writematrix(P1,'15Hz_P12.xls','WriteMode','append');
        
        %plot(f,P1);                    %Plots vibration signal in frequency domain
        %disp("hereee")
        %ylim([0 500]);
        
        
        D = x2fx(P1,'quadratic');
        is_alarm_1 = mtimes(D,dual_1);
        %disp(is_alarm_1);
        if is_alarm_1>0
            disp("Detected");
        end
    end
end
    