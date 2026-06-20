clc; clear;

num_samples = 15000;   % 10k–20k
fs = 10000;
t = 0:1/fs:0.1;
f = 50;

data = [];

for i = 1:num_samples
    
    % Base signal
    V = sin(2*pi*f*t);
    
    % Random fault type (balanced)
    fault_type = mod(i,4) + 1;
    
    switch fault_type
        
        case 1  % Normal
            signal = V;
            label = "Normal";
            
        case 2  % Voltage Sag
            signal = V;
            idx = t > (0.01 + rand()*0.02) & t < (0.05 + rand()*0.02);
            depth = 0.2 + rand()*0.7;   % wide variation
            
            % overlap with normal
            if rand() < 0.3
                depth = 0.85 + rand()*0.1;
            end
            
            signal(idx) = depth * V(idx);
            label = "Sag";
            
        case 3  % Voltage Swell
            signal = V;
            idx = t > (0.01 + rand()*0.02) & t < (0.05 + rand()*0.02);
            swell = 1.1 + rand()*1.0;
            
            % overlap with normal
            if rand() < 0.3
                swell = 1.05 + rand()*0.1;
            end
            
            signal(idx) = swell * V(idx);
            label = "Swell";
            
        case 4  % Harmonics
            signal = V ...
                + (0.1 + rand()*0.4)*sin(2*pi*3*f*t) ...
                + (0.05 + rand()*0.3)*sin(2*pi*5*f*t);
            
            % slight overlap with normal
            if rand() < 0.3
                signal = V + 0.05*sin(2*pi*3*f*t);
            end
            
            label = "Harmonic";
    end
    
    noise = 0.05 * randn(size(signal));
    signal = signal + noise;
    
    rms_val = rms(signal);
    peak_val = max(signal);
    mean_val = mean(signal);
    std_val = std(signal);
    energy = sum(signal.^2);
    
    mu = mean(signal);
    sigma = std(signal);
    
    skewness_val = mean((signal - mu).^3) / (sigma^3 + eps);
    kurtosis_val = mean((signal - mu).^4) / (sigma^4 + eps);
    diff_signal = max(abs(diff(signal)));
    
    data = [data; rms_val, peak_val, mean_val, std_val, energy, ...
                    skewness_val, kurtosis_val, diff_signal, string(label)];
end

T = array2table(data, ...
    'VariableNames', {'RMS','Peak','Mean','STD','Energy', ...
                      'Skewness','Kurtosis','MaxDiff','Label'});


writetable(T, 'power_quality_fault_dataset.csv');

disp("Dataset Generated Successfully!");