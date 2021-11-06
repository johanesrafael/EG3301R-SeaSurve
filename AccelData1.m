
a = ans;

%-- digital i/o 

zvect = [readVoltage(a,'A3')];
count = 0;
mcount=0;
localmax=0;
localmin=5;
localpeak = 0;
peakdiff=0;
avg =0;
zid = [count];

% bavg=0;
% while 1
%     readcount=0;
%     tic
%     while readcount<500
%         zval= readVoltage(a,'A3');
%         readcount=readcount+1;
%     end
%     cavg=toc;
%     bavg=bavg+cavg;
%     disp(['bavg = ' num2str(bavg)]);
% end

sampf = 36;%27.4;
T = 1/sampf;
L = 49;
t = (0:L-1)*T;
[rain_pred] = xlsread("C:\Users\JohnRaphaeL\noiseRain\predictions\pred_param_rain.xls"); % PreviousDataprediction
[hum_pred] = xlsread("C:\Users\JohnRaphaeL\noiseRain\predictions\pred_param_hum.xlsx");
[hum_rain_pred] = xlsread("C:\Users\JohnRaphaeL\noiseRain\predictions\pred_param_hum_rain.xlsx");
[hum_hand_metal_pred] = xlsread("C:\Users\JohnRaphaeL\noiseRain\predictions\pred_param_metal_hand_hum.xlsx");
[hum_hand_metal_pred2] = xlsread("C:\Users\JohnRaphaeL\noiseRain\predictions\pred_param_metal_hand_hum2.xlsx");
[hand_metal_pred] = xlsread("C:\Users\JohnRaphaeL\noiseRain\predictions\pred_param_metal_hand.xlsx");
[hum_hand_metal_pred_reduced] = xlsread("C:\Users\JohnRaphaeL\noiseRain\predictions\pred_param_metal_hand_hum_reduced.xlsx");
[hum_hand_metal_pred2_reduced] = xlsread("C:\Users\JohnRaphaeL\noiseRain\predictions\pred_param_metal_hand_hum2_reduced.xlsx");
[hand_metal_pred_reduced] = xlsread("C:\Users\JohnRaphaeL\noiseRain\predictions\pred_param_metal_hand_reduced.xlsx");
dual_1 = rain_pred(2:end,2);
dual_2 = hum_pred(2:end,2);
dual_3 = hum_rain_pred(2:end,2);
dual_4 = hum_hand_metal_pred(2:end,2);
dual_5 = hum_hand_metal_pred2(2:end,2);
dual_6 = hand_metal_pred(2:end,2);
dual_7 = hum_hand_metal_pred_reduced(2:end,2);
dual_8 = hum_hand_metal_pred2_reduced(2:end,2);
dual_9 = hand_metal_pred_reduced(2:end,2);
%disp(size(dual));
while 1>0
%-- analog i/o 
    if length(zvect)==50
        zvect(1)=[];
        zid(50)=[];
        count = count -1;
        avg = avg - zvect(1);
    end
       
    zval= readVoltage(a,'A3');
    zvect=[zvect zval];
    count = count +1;
    zid=[zid count];
    avg=avg+zval;
    %yval = readVoltage(a,'A4');
    %xval = readVoltage(a,'A5');
    %disp(['X = ' num2str(xval) ' Y= ' num2str(yval) ' Z= ' num2str(zval)])
    
    if localmax<zval
        localmax = zval;
    end
    if localmin>zval
        localmin = zval;
    end
    if (localmax-(avg/count))<((avg/count)-localmin)
        localpeak = localmin;
    else 
        localpeak = localmax;
    end
    disp(['count= ' num2str(count) ' avg = ' num2str(avg/count) ' localpeak = ' num2str(localpeak) ' peakdiff = ' num2str(localpeak-(avg/count))]);
    
    if count == 49
        n_zvect=zvect-avg/count;      %normalize values about local mean
        Y = fft(n_zvect);             %FFT the normalized values
        P2 = abs(Y/L);                %Obtain single-sided spectrum
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        f = sampf*(0:(L/2))/L;        %Frequencies over which magnitude data is available
        f2 = sampf*(0:L-1)/L;
        plot(f,P1)                    %Plots vibration signal in frequency domain
        ylim([0 0.5]);
%         writematrix(P1,'noiserainnew2.xls','WriteMode','append');
%         if (localpeak-(avg/count))>0.04
%             %writematrix(P1,'bangmetal1.xls','WriteMode','append');
%         end
%         if (localpeak-(avg/count))<=0.01
%             %writematrix(P1,'noise.xls','WriteMode','append');
%         end
        
        %disp(size(P1));
        D = x2fx(P1,'quadratic');
        %disp(size(D));
        is_alarm_1 = mtimes(D,dual_1);
        is_alarm_2 = mtimes(D,dual_2);
        is_alarm_3 = mtimes(D,dual_3);
        is_alarm_4 = mtimes(D,dual_4);
        is_alarm_5 = mtimes(D,dual_5);
        is_alarm_6 = mtimes(D,dual_6);
        is_alarm_7 = mtimes(D,dual_7);
        is_alarm_8 = mtimes(D,dual_8);
        is_alarm_9 = mtimes(D,dual_9);        
%         disp(is_alarm_1);
%         disp(is_alarm_2);
%         disp(is_alarm_3);
        if (is_alarm_4 > 0)
            writeDigitalPin(a, 'D7', 1);
%             pause(0.25);
            writeDigitalPin(a, 'D7', 0);
%         else
%             writeDigitalPin(a, 'D7', 0);
%             pause(0.5);         
        end
    end
    %plot(zid, zvect);
    %ylim([1.5 2.3]);
    mcount=mcount+1;
    if mcount ==30
        localmax = avg/count;
        localmin = localmax;
        mcount =0;
    end
end

