% Radar_Target_Generation_and_Detection.m

clear all
clc;

%% Radar Specifications 
fc= 77e9;             %carrier freq
max_range = 200;
range_res = 1;
max_velocity = 100;
c = 3e8;              % speed of light

%% User Defined Range and Velocity of target
r_tgt = 110; % target's initial position
v_tgt = 30;  % target's constant velocity

%% FMCW Waveform Generation
B = c / (2 * range_res);                      % Bandwidth
Tchirp = 5.5 * 2 * max_range / c;            % Chirp Time
slope = B / Tchirp;                          % Slope of the chirp

Nd = 128;  % number of chirps
Nr = 1024; % number of samples per chirp
t=linspace(0,Nd*Tchirp,Nr*Nd); %total time for samples

Tx=zeros(1,length(t)); %transmitted signal
Rx=zeros(1,length(t)); %received signal
Mix = zeros(1,length(t)); %beat signal
r_t=zeros(1,length(t));
td=zeros(1,length(t));

%% Signal generation and Moving Target simulation
for i=1:length(t)
    r_t(i) = r_tgt + v_tgt * t(i); % update range for constant velocity
    td(i) = 2 * r_t(i) / c;        % time delay

    Tx(i) = cos(2 * pi * (fc * t(i) + (slope * t(i)^2)/2));
    Rx(i) = cos(2 * pi * (fc * (t(i) - td(i)) + (slope * (t(i) - td(i))^2)/2));

    Mix(i) = Tx(i) * Rx(i); % beat signal
end

%% RANGE MEASUREMENT
Mix_reshape = reshape(Mix,[Nr,Nd]);
sig_fft1 = fft(Mix_reshape,Nr);
sig_fft1 = abs(sig_fft1./Nr);
sig_fft1 = sig_fft1(1:Nr/2,1);

figure ('Name','Range from First FFT')
subplot(2,1,1)
plot(sig_fft1);
title('Range from First FFT');
xlabel('Range Bin'); ylabel('|FFT|');
axis ([0 200 0 1]);

%% RANGE DOPPLER RESPONSE
Mix=reshape(Mix,[Nr,Nd]);
sig_fft2 = fft2(Mix,Nr,Nd);
sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift (sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM);

% plot 2D FFT output
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure,surf(doppler_axis,range_axis,RDM);
title('Range Doppler Map');
xlabel('Doppler'); ylabel('Range'); zlabel('Amplitude (dB)');

%% CFAR implementation
Tr = 10; Tc = 8;
Gr = 4;  Gc = 4;
offset = 6;
CFAR = zeros(size(RDM));

for i = Tr+Gr+1:(Nr/2)-(Gr+Tr)
    for j = Tc+Gc+1:Nd-(Gc+Tc)
        noise_level = 0;
        for p = i-(Tr+Gr):i+(Tr+Gr)
            for q = j-(Tc+Gc):j+(Tc+Gc)
                if (abs(i-p) > Gr || abs(j-q) > Gc)
                    noise_level = noise_level + 10.^(RDM(p,q)/10);
                end
            end
        end
        threshold = 10*log10(noise_level / ((2*Tr+2*Gr+1)*(2*Tc+2*Gc+1) - (2*Gr+1)*(2*Gc+1)));
        threshold = threshold + offset;
        CUT = RDM(i,j);
        if CUT > threshold
            CFAR(i,j) = 1;
        else
            CFAR(i,j) = 0;
        end
    end
end

% plot CFAR output
figure,surf(doppler_axis,range_axis,CFAR);
title('2D CFAR Detection');
xlabel('Doppler'); ylabel('Range'); zlabel('CFAR Output');
colorbar;
