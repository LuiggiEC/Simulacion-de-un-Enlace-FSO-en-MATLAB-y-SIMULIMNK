%% CALCULADORA DE PARÁMETROS FSO PARA ENLACE EN PORTOVIEJO, ECUADOR
% Tesis: Análisis de Desvanecimientos Climáticos en Enlaces FSO

clear all;
close all;
clc;

%% ========================================================================
% PARTE 1: PARÁMETROS DEL SISTEMA FSO
%% ========================================================================

fprintf('=== CALCULADORA DE PARÁMETROS FSO - PORTOVIEJO ===\n\n');

% PARÁMETROS DEL ENLACE
distancia_km = 0.7; % Distancia del enlace en km
lambda_nm = 1550; % Longitud de onda en nm
lambda_m = lambda_nm * 1e-9; % Longitud de onda en metros
Pt_dBm = 10; % Potencia de transmisión en dBm
Pt_W = 10^((Pt_dBm - 30)/10); % Potencia en Watts
D_rx_cm = 20; % Diámetro apertura receptor (cm)
D_rx_m = D_rx_cm / 100; % Diámetro en metros
A_rx = pi * (D_rx_m/2)^2; % Área del receptor en m²
D_tx_cm = 8; % Diámetro apertura transmisor (cm)
D_tx_m = D_tx_cm / 100; % Diámetro en metros
divergence_mrad = 0.243; % Ángulo de divergencia del haz (mrad)
bit_rate_Gbps = 1; % Tasa de bits en Gbps
bit_rate_bps = bit_rate_Gbps * 1e9; % Tasa de bits en bps
APD = 10; % Factor de Multiplicacion del APD (M)
APD_gan_dB = 20; % Ganancia del APD en dB

% ATENUACIÓN GEOMÉTRICA (Divergencia + Pérdidas de Inserción)
% Esta pérdida es CONSTANTE en todos los escenarios y se aplica debido a divergencia del haz y pérdidas en lentes/acopladores
L_geo_dB = 1.95; % Pérdidas geométricas fijas (dB)

% Constantes
c = 3e8; % Velocidad de la luz (m/s)
h = 6.626e-34; % Constante de Planck (J·s)
frecuencia = c / lambda_m; % Frecuencia óptica (Hz)

fprintf('PARÁMETROS DEL SISTEMA:\n');
fprintf(' Distancia del Enlace: %.2f km\n', distancia_km);
fprintf(' Longitud de Onda: %d nm\n', lambda_nm);
fprintf(' Potencia de Transmisión: %.1f dBm (%.2e W)\n', Pt_dBm, Pt_W);
fprintf(' Diámetro del Transmisor (TX): %.f cm\n', D_tx_cm);
fprintf(' Divergencia del Haz (TX): %.3f mrad\n', divergence_mrad); 
fprintf(' Diámetro del Receptor (RX): %.f cm\n', D_rx_cm);
fprintf(' Área del Receptor: %.4f m²\n', A_rx);
fprintf(' Factor de Multiplicacion del APD (M): %.f\n', APD);
fprintf(' Ganancia del APD en dB: %.f dB\n', APD_gan_dB);
fprintf(' Tasa de Bits: 1 Gbps\n');
fprintf(' Atenuación Geométrica: %.2f dB \n\n', L_geo_dB);

%% ========================================================================
% PARTE 2: CÁLCULO DE ATENUACIONES POR CONDICIONES CLIMÁTICAS
%% ========================================================================

% CASO 1: CONDICIONES IDEALES (Cielo Despejado)
fprintf('CASO 1: CIELO DESPEJADO (Condiciones Ideales)\n');
fprintf('────────────────────────────────────────────\n');
alfa_clear_dB_km = 0.43; % Atenuación específica a 1550nm
L_atm_clear_dB = alfa_clear_dB_km * distancia_km;
L_total_clear_dB = L_atm_clear_dB + L_geo_dB;
factor_clear = 10^(-L_total_clear_dB/10);
Pr_clear_dBm = Pt_dBm - L_total_clear_dB;
Pr_clear_amp_dBm = Pr_clear_dBm + APD_gan_dB; 

fprintf(' Atenuación Atmosférica: %.3f dB/km\n', alfa_clear_dB_km);
fprintf(' Pérdidas Atmosféricas en %.2f km: %.3f dB\n', distancia_km, L_atm_clear_dB);
fprintf(' Pérdidas Geométricas (L_geo): %.2f dB\n', L_geo_dB);
fprintf(' Pérdida TOTAL: %.3f dB (%.3f atm + %.2f geo)\n', L_total_clear_dB, L_atm_clear_dB, L_geo_dB);
fprintf(' Factor de Transmisión: %.4f\n', factor_clear);
fprintf(' Potencia Recibida: %.2f dBm\n', Pr_clear_dBm);
fprintf(' Potencia Recibida Amplificada: %.2f dBm\n\n', Pr_clear_amp_dBm);

% CASO 2: BRISA/TURBULENCIA ATMOSFÉRICA
fprintf('CASO 2: BRISA CON TURBULENCIA ATMOSFÉRICA LEVE\n');
fprintf('─────────────────────────────────────────────\n');
alfa_turb_dB_km = 0.43; % Atenuación base
L_scint_dB = 2.0; % Pérdidas por scintilación
L_atm_turb_dB = alfa_turb_dB_km * distancia_km + L_scint_dB;
L_total_turb_dB = L_atm_turb_dB + L_geo_dB;
factor_turb = 10^(-L_total_turb_dB/10);
Pr_turb_dBm = Pt_dBm - L_total_turb_dB;
Pr_turb_amp_dBm = Pt_dBm - L_total_turb_dB + APD_gan_dB;

% Parámetros de turbulencia (para modelo log-normal)
Cn2_turb = 1e-14; % Índice de estructura refractiva (m^-2/3)
k = 2*pi/lambda_m; % Número de onda
sigma_R2_turb = 1.23 * Cn2_turb * k^(7/6) * (distancia_km*1000)^(11/6); % Índice de scintilación
sigma_lnI_turb = sqrt(sigma_R2_turb); % Desviación estándar log-intensidad

fprintf(' Atenuación Atmosférica Base: %.3f dB/km\n', alfa_turb_dB_km);
fprintf(' Pérdidas por Scintilación: %.1f dB\n', L_scint_dB);
fprintf(' Pérdidas Atmosféricas Totales: %.3f dB\n', L_atm_turb_dB);
fprintf(' Pérdidas Geométricas (L_geo): %.2f dB\n', L_geo_dB);
fprintf(' Pérdida TOTAL: %.3f dB (%.3f atm + %.2f geo)\n', L_total_turb_dB, L_atm_turb_dB, L_geo_dB);
fprintf(' Factor de Transmisión: %.4f\n', factor_turb);
fprintf(' Potencia Recibida: %.2f dBm\n', Pr_turb_dBm);
fprintf(' Potencia Recibida Amplificada: %.2f dBm\n', Pr_turb_amp_dBm);
fprintf(' Cn² (Turbulencia): %.2e m^-2/3\n', Cn2_turb);
fprintf(' σ²_R (Índice scintilación): %.4f\n', sigma_R2_turb);
fprintf(' σ_ln(I): %.4f\n\n', sigma_lnI_turb);

% CASO 3: LLUVIA MODERADA (25 mm/h)
fprintf('CASO 3: LLUVIA MODERADA (25 mm/h)\n');
fprintf('──────────────────────────────────\n');
R_mod = 25; % Intensidad de lluvia (mm/h)
alfa_rain_mod_dB_km = 1.076 * R_mod^0.67; % Modelo de Kim para 1550nm
L_atm_mod_dB = alfa_clear_dB_km * distancia_km + alfa_rain_mod_dB_km * distancia_km;
L_total_rain_mod_dB = L_atm_mod_dB + L_geo_dB;
factor_rain_mod = 10^(-L_total_rain_mod_dB/10);
Pr_rain_mod_dBm = Pt_dBm - L_total_rain_mod_dB;
Pr_rain_mod_amp_dBm = Pt_dBm - L_total_rain_mod_dB + APD_gan_dB;

fprintf(' Intensidad de lluvia: %.1f mm/h\n', R_mod);
fprintf(' Atenuación Específica por lluvia: %.3f dB/km\n', alfa_rain_mod_dB_km);
fprintf(' Pérdidas por lluvia en %.2f km: %.3f dB\n', distancia_km, alfa_rain_mod_dB_km * distancia_km);
fprintf(' Atenuación Atmosférica Base: %.3f dB\n', alfa_clear_dB_km * distancia_km);
fprintf(' Pérdidas Atmosféricas Totales: %.3f dB\n', L_atm_mod_dB);
fprintf(' Pérdidas Geométricas (L_geo): %.2f dB\n', L_geo_dB);
fprintf(' Pérdida TOTAL: %.3f dB (%.3f atm + %.2f geo)\n', L_total_rain_mod_dB, L_atm_mod_dB, L_geo_dB);
fprintf(' Factor de Transmisión: %.4f\n', factor_rain_mod);
fprintf(' Potencia Recibida: %.2f dBm\n', Pr_rain_mod_dBm);
fprintf(' Potencia Recibida Amplificada: %.2f dBm\n\n', Pr_rain_mod_amp_dBm);

% CASO 4: LLUVIA INTENSA + NIEBLA
fprintf('CASO 4: LLUVIA INTENSA (50 mm/h) + NIEBLA LIGERA\n');
fprintf('────────────────────────────────────────────────\n');
R_intense = 50; % Intensidad de lluvia (mm/h)
alfa_rain_int_dB_km = 1.076 * R_intense^0.67; % Atenuación por lluvia
alfa_fog_dB_km = 2.0; % Atenuación por niebla ligera
alfa_total_extreme_dB_km = alfa_clear_dB_km + alfa_rain_int_dB_km + alfa_fog_dB_km;
L_atm_extreme_dB = alfa_total_extreme_dB_km * distancia_km;
L_total_extreme_dB = L_atm_extreme_dB + L_geo_dB;
factor_extreme = 10^(-L_total_extreme_dB/10);
Pr_extreme_dBm = Pt_dBm - L_total_extreme_dB;
Pr_extreme_amp_dBm = Pt_dBm - L_total_extreme_dB + APD_gan_dB;

fprintf(' Intensidad de luvia: %.1f mm/h\n', R_intense);
fprintf(' Atenuación Específica por lluvia: %.3f dB/km\n', alfa_rain_int_dB_km);
fprintf(' Atenuación por Niebla: %.3f dB/km\n', alfa_fog_dB_km);
fprintf(' Atenuación Total Específica: %.3f dB/km\n', alfa_total_extreme_dB_km);
fprintf(' Pérdidas Atmosféricas totales en %.2f km: %.3f dB\n', distancia_km, L_atm_extreme_dB);
fprintf(' Pérdidas Geométricas (L_geo): %.2f dB\n', L_geo_dB);
fprintf(' Pérdida TOTAL: %.3f dB (%.3f atm + %.2f geo)\n', L_total_extreme_dB, L_atm_extreme_dB, L_geo_dB);
fprintf(' Factor de Transmisión: %.4f\n', factor_extreme);
fprintf(' Potencia Recibida: %.2f dBm\n', Pr_extreme_dBm);
fprintf(' Potencia Recibida Amplificada: %.2f dBm\n\n', Pr_extreme_amp_dBm);

%% ========================================================================
% PARTE 3: RESUMEN DE FACTORES PARA SIMULINK
%% ========================================================================

fprintf('=== RESUMEN: VALORES PARA BLOQUES GAIN EN SIMULINK ===\n\n');

fprintf('┌─────────────────────────────┬──────────────┬───────────────┐\n');
fprintf('│       ESCENARIO             │  GAIN VALUE  │  ATTEN. TOTAL │\n');
fprintf('├─────────────────────────────┼──────────────┼───────────────┤\n');
fprintf('│  Caso 1: Cielo Despejado    │    %.4f    │    %.2f dB    │\n', factor_clear, L_total_clear_dB);
fprintf('│  Caso 2: Brisa/Turbulencia  │    %.4f    │    %.2f dB    │\n', factor_turb, L_total_turb_dB);
fprintf('│  Caso 3: Lluvia Moderada    │    %.4f    │    %.2f dB    │\n', factor_rain_mod, L_total_rain_mod_dB);
fprintf('│  Caso 4: Lluvia + Niebla    │    %.4f    │   %.2f dB    │\n', factor_extreme, L_total_extreme_dB);
fprintf('└─────────────────────────────┴──────────────┴───────────────┘\n\n');

%% ========================================================================
% PARTE 4: PARÁMETROS DE TURBULENCIA LOG-NORMAL
%% ========================================================================

fprintf('=== PARÁMETROS PARA MODELO LOG-NORMAL (TURBULENCIA) ===\n\n');

% Diferentes niveles de turbulencia
Cn2_weak = 1e-15; % Turbulencia débil
Cn2_moderate = 1e-14; % Turbulencia moderada
Cn2_strong = 1e-13; % Turbulencia fuerte

sigma_R2_weak = 1.23 * Cn2_weak * k^(7/6) * (distancia_km*1000)^(11/6);
sigma_R2_moderate = 1.23 * Cn2_moderate * k^(7/6) * (distancia_km*1000)^(11/6);
sigma_R2_strong = 1.23 * Cn2_strong * k^(7/6) * (distancia_km*1000)^(11/6);

fprintf('TURBULENCIA DÉBIL - CASO 2:\n');
fprintf(' Cn² = %.2e m^-2/3\n', Cn2_weak);
fprintf(' σ²_R = %.4f\n', sigma_R2_weak);
fprintf(' σ_ln(I) = %.4f\n\n', sqrt(sigma_R2_weak));

fprintf('TURBULENCIA MODERADA - CASO 3:\n');
fprintf(' Cn² = %.2e m^-2/3\n', Cn2_moderate);
fprintf(' σ²_R = %.4f\n', sigma_R2_moderate);
fprintf(' σ_ln(I) = %.4f\n\n', sqrt(sigma_R2_moderate));

fprintf('TURBULENCIA FUERTE - CASO 4:\n');
fprintf(' Cn² = %.2e m^-2/3\n', Cn2_strong);
fprintf(' σ²_R = %.4f\n', sigma_R2_strong);
fprintf(' σ_ln(I) = %.4f\n\n', sqrt(sigma_R2_strong));

%% ========================================================================
% PARTE 5: CONFIGURACIÓN DEL RECEPTOR APD
%% ========================================================================

fprintf('=== CONFIGURACIÓN DEL RECEPTOR APD (AVALANCHE PHOTODIODE) ===\n\n');

% Parámetros del receptor APD
M_apd = 10; % Ganancia lineal del APD
M_apd_dB = 20 * log10(M_apd); % Ganancia en dB = 20 dB
R_base = 0.9; % Responsividad base (A/W) para 1550nm
R_detector = R_base * M_apd; % Responsividad efectiva del APD = 9.0 A/W
NEP = 1e-14; % Noise Equivalent Power (W/Hz^0.5)
B = bit_rate_bps; % Ancho de banda del receptor

fprintf('PARÁMETROS DEL RECEPTOR APD:\n');
fprintf(' Responsividad base (R_base): %.1f A/W\n', R_base);
fprintf(' Ganancia APD (M): %d (Lineal)\n', M_apd);
fprintf(' Ganancia APD en Decibelios: %.1f dB\n', M_apd_dB);
fprintf(' Responsividad efectiva (R_detector): %.1f A/W\n', R_detector);
fprintf(' NEP: %.2e W/Hz^0.5\n', NEP);
fprintf(' Ancho de banda: %.2e Hz\n\n', B);

%% ========================================================================
% PARTE 6: SNR EFECTIVO Y CAPACIDAD DEL CANAL
%% ========================================================================

fprintf('=== ANÁLISIS SNR EFECTIVO Y CAPACIDAD DE SHANNON ===\n\n');

scenarios = {'Cielo Despejado', 'Brisa/Turbulencia', 'Lluvia Moderada', 'Lluvia + Niebla'};

% 1. Configuración de cada SNR
SNR_target_dB = 30; % Valor base del AWGN

% Recuperamos las potencias ópticas (convertimos dBm a Watts)
Pr_W_vec = [10^((Pr_clear_dBm-30)/10), ...
            10^((Pr_turb_dBm-30)/10), ...
            10^((Pr_rain_mod_dBm-30)/10), ...
            10^((Pr_extreme_dBm-30)/10)];

% 2. Calcular el "Piso de Ruido" Fijo del Sistema
% SNR = P_senal / P_ruido --> P_ruido = P_senal / SNR

Pr_ref_electrica = (Pr_W_vec(1) * R_base * M_apd)^2; % Potencia eléctrica proporcional
SNR_linear_ref = 10^(SNR_target_dB/10);
Potencia_Ruido_Constante = Pr_ref_electrica / SNR_linear_ref;

fprintf('┌────────────────────┬────────────────┬──────────────┬────────────────────────┐\n');
fprintf('│     ESCENARIO      │  Pr_amp (dBm)  │   SNR (dB)   │  CAPACIDAD DE SHANOON  │\n');
fprintf('├────────────────────┼────────────────┼──────────────┼────────────────────────┤\n');

for i = 1:4
    % Potencia Óptica de llegada 
    Pr_opt_actual = Pr_W_vec(i);
    Pr_dBm_show = 10*log10(Pr_opt_actual) + 30 + M_apd_dB;

    % Potencia Eléctrica de la señal (Corriente al cuadrado)
    % I = R * P_optica * M
    P_elec_actual = (Pr_opt_actual * R_base * M_apd)^2;
    
    % Calculamos el SNR REAL
    SNR_linear_real = P_elec_actual / Potencia_Ruido_Constante;
    SNR_dB_real = 10*log10(SNR_linear_real);
    
    % Evitar logaritmos de cero o negativos si la señal muere
    if SNR_dB_real < -20, SNR_dB_real = -20; end
    
    % Capacidad de SHANNON
    Capacity_bps = B * log2(1 + SNR_linear_real);
    Capacity_Gbps = Capacity_bps / 1e9;
    
    fprintf('│ %-18s │ %9.2f      │ %9.2f    │ %10.2f Gbps        │\n', ...
        scenarios{i}, Pr_dBm_show, SNR_dB_real, Capacity_Gbps);
end

fprintf('└────────────────────┴────────────────┴──────────────┴────────────────────────┘\n');
fprintf('NOTA: SNR calculado asumiendo ruido constante y degradación por atenuación de señal.\n');
fprintf('Fórmula Utilizada: C = B * log2(1 + SNR)\n');
fprintf('B: Ancho de Banda = 1e9\n\n');

%% ========================================================================
% PARTE 7: COMPARATIVA - PIN vs APD 
%% ========================================================================
fprintf('\n=== ANÁLISIS COMPARATIVO DE RENDIMIENTO: PIN (M=1) vs APD (M=10) ===\n\n');

% Definición de Escenarios
scenarios = {'Cielo Despejado', 'Brisa/Turb.', 'Lluvia Mod.', 'Lluvia+Niebla'};

% --- CONFIGURACIÓN FÍSICA ---
SNR_target_APD_dB = 30; % Objetivo de diseño
M_apd = 10;             % Ganancia del APD (Lineal)
Gain_dB = 20*log10(M_apd); % Ganancia en dB (20 dB)
M_pin = 1;              % Referencia PIN sin ganancia
B = 1e9;                % Ancho de banda (1Gbps)

% Recuperar potencias (con L_geo ya incluida)
Pr_values_dBm = [Pr_clear_dBm, Pr_turb_dBm, Pr_rain_mod_dBm, Pr_extreme_dBm];
Pr_values_W = 10.^((Pr_values_dBm-30)/10);

% --- CÁLCULO DEL RUIDO DEL SISTEMA (Constante) ---
Pr_ref = Pr_values_W(1); % Potencia en caso ideal
SNR_linear_ref = 10^(SNR_target_APD_dB/10); 
% Nota: Asumimos ruido térmico dominante constante para simplificar la comparativa
P_noise_sys = (Pr_ref * M_apd)^2 / SNR_linear_ref; 

% --- IMPRESIÓN DE LA TABLA ---
fprintf('┌───────────────────────┬────────────┬───────────────┬──────────────┬────────────────┬─────────────────┐\n');
fprintf('│ ESCENARIO             │  Pr (dBm)  │ SNR PIN (M=1) │ Pr_amp (dBm) │ SNR APD (M=10) │ CAPACIDAD (APD) │\n');
fprintf('├───────────────────────┼────────────┼───────────────┼──────────────┼────────────────┼─────────────────│\n');

for i = 1:4
    % 1. Datos del escenario
    Pr_W = Pr_values_W(i);
    Pr_dBm_val = Pr_values_dBm(i);
    
    % CALCULO DE LA POTENCIA AMPLIFICADA
    Pr_amp_val_dBm = Pr_dBm_val + Gain_dB;
    
    % 2. Cálculo PIN (M=1)
    Signal_PIN = (Pr_W * M_pin)^2;
    SNR_lin_PIN = Signal_PIN / P_noise_sys;
    SNR_dB_PIN = 10*log10(SNR_lin_PIN);
    
    % 3. Cálculo APD (M=10)
    Signal_APD = (Pr_W * M_apd)^2;
    SNR_lin_APD = Signal_APD / P_noise_sys;
    SNR_dB_APD = 10*log10(SNR_lin_APD);
    
    % 4. Capacidad Shannon
    Cap_bps = B * log2(1 + SNR_lin_APD);
    Cap_Gbps = Cap_bps / 1e9;
    
    % 5. Formateo condicional para el PIN
    if SNR_dB_PIN < 0
        str_pin = sprintf('%6.2f OFF', SNR_dB_PIN);
    else
        str_pin = sprintf('%6.2f dB', SNR_dB_PIN);
    end
    
    % 6. Imprimir la tabla comparativa
    fprintf('│ %-21s │ %7.2f    │  %-12s │ %9.2f    │ %8.2f dB    │  %8.2f Gbps  │\n', ...
        scenarios{i}, Pr_dBm_val, str_pin, Pr_amp_val_dBm, SNR_dB_APD, Cap_Gbps);
end

fprintf('└───────────────────────┴────────────┴───────────────┴──────────────┴────────────────┴─────────────────┘\n');
fprintf('NOTA: Pr_amp = Pr + 20 dB (Ganancia del APD M = %d = %.1f dB)\n\n', M_apd, Gain_dB);

%% ========================================================================
% PARTE 8: CÁLCULO DE UMBRALES 
%% ========================================================================
fprintf('\n=== CÁLCULO DE UMBRALES PARA CADA CASO ===\n\n');

% 1. Configuración de parámetros
M_apd_linear = 10;           
Gain_dB = 20;                
R_base = 0.9;                % Responsividad base (A/W)
R_load = 10;                 % Resistencia de carga (Ohms)

% 2. Recuperar Potencias de Recepción (Pr) originales
Pr_dBm_original = [Pr_clear_dBm, Pr_turb_dBm, Pr_rain_mod_dBm, Pr_extreme_dBm];
Pr_W_original = 10.^((Pr_dBm_original - 30) / 10); 

% 3. CÁLCULO DE POTENCIA AMPLIFICADA (+20 dB)
% La potencia amplificada debe ser la original + 20 dB
Pr_amp_dBm = Pr_dBm_original + Gain_dB; 
Pr_amp_W = 10.^((Pr_amp_dBm - 30)/10); % Convertimos esa nueva potencia a Watts

% 4. CÁLCULO DEL UMBRAL (Voltaje)
% Fórmula: Umbral = I_total * R_load
% Donde I_total = Pr_original_W * M_linear * R_base
% (Nota: Usamos M=10 lineal para la corriente física real del fotodiodo)
I_photo_total = Pr_W_original * M_apd_linear * R_base;
thr = I_photo_total * R_load;

% Asignación a variables individuales
thr_1 = thr(1);
thr_2 = thr(2);
thr_3 = thr(3);
thr_4 = thr(4);

% --- MOSTRAR RESULTADOS ---
fprintf('PARÁMETROS:\n');
fprintf(' Ganancia aplicada a Pr: +%d dB\n', Gain_dB);
fprintf(' Ganancia lineal (M) para corriente: %d\n', M_apd_linear);
fprintf(' Responsividad (R_base): %.1f A/W\n', R_base);
fprintf(' Resistencia (R_load): %d Ω\n\n', R_load);

fprintf('┌─────────────────────────┬──────────────┬───────────────┬──────────────┐\n');
fprintf('│    ESCENARIOS           │ Pr (dBm)     │ Pr_amp (dBm)  │  UMBRAL (V)  │\n');
fprintf('├─────────────────────────┼──────────────┼───────────────┼──────────────┤\n');

fprintf('│ 1. Cielo Despejado      │  %6.2f      │  %8.2f     │ %8.4f     │\n', ...
    Pr_dBm_original(1), Pr_amp_dBm(1), thr_1);
fprintf('│ 2. Brisa/Turbulencia    │  %6.2f      │  %8.2f     │ %8.4f     │\n', ...
    Pr_dBm_original(2), Pr_amp_dBm(2), thr_2);
fprintf('│ 3. Lluvia Moderada      │  %6.2f      │  %8.2f     │ %8.4f     │\n', ...
    Pr_dBm_original(3), Pr_amp_dBm(3), thr_3);
fprintf('│ 4. Lluvia Intensa       │  %6.2f      │  %8.2f     │ %8.4f     │\n', ...
    Pr_dBm_original(4), Pr_amp_dBm(4), thr_4);
fprintf('└─────────────────────────┴──────────────┴───────────────┴──────────────┘\n');

%% ========================================================================
% PARTE 8.1: CÁLCULO DE UMBRALES (OPTIMIZADOS PARA BER)
%% ========================================================================
fprintf('\n=== CÁLCULO DE UMBRALES (OPTIMIZADOS PARA BER) ===\n');
% Factor de corrección para APD (baja el umbral ligeramente para evitar ruido shot en '1')
correction_factor = 0.85; 

% Aplicamos corrección
thr_opt_1 = thr_1 * correction_factor;
thr_opt_2 = thr_2 * correction_factor;
thr_opt_3 = thr_3 * correction_factor;
thr_opt_4 = thr_4 * correction_factor;

fprintf('Factor de Ajuste: %.2f\n', correction_factor);
fprintf('┌─────────────────────────────┬────────────────┬───────────────┬────────────────┐\n');
fprintf('│ ESCENARIO                   │ Pr_amp (dBm)   │ TEÓRICO (V)   │ OPTIMIZADO (V) │\n');
fprintf('├─────────────────────────────┼────────────────┼───────────────┼────────────────┤\n');
fprintf('│ 1. Cielo Despejado          │   %6.2f       │   %.4f      │    %.4f      │\n', Pr_amp_dBm(1), thr_1, thr_opt_1);
fprintf('│ 2. Brisa/Turbulencia        │   %6.2f       │   %.4f      │    %.4f      │\n', Pr_amp_dBm(2), thr_2, thr_opt_2);
fprintf('│ 3. Lluvia Moderada          │   %6.2f       │   %.4f      │    %.4f      │\n', Pr_amp_dBm(3), thr_3, thr_opt_3);
fprintf('│ 4. Lluvia Intensa           │   %6.2f       │   %.4f      │    %.4f      │\n', Pr_amp_dBm(4), thr_4, thr_opt_4);
fprintf('└─────────────────────────────┴────────────────┴───────────────┴────────────────┘\n\n');

%% ========================================================================
% PARTE 9: GENERACIÓN DE VARIABLES PARA WORKSPACE
%% ========================================================================

fprintf('=== EXPORTANDO VARIABLES AL WORKSPACE ===\n\n');

% Guardar variables relevantes en el Workspace para usarlas en Simulink
assignin('base', 'L_geo_dB', L_geo_dB);
assignin('base', 'gain_clear', factor_clear);
assignin('base', 'gain_turb', factor_turb);
assignin('base', 'gain_rain_mod', factor_rain_mod);
assignin('base', 'gain_extreme', factor_extreme);
assignin('base', 'sigma_lnI_turb', sqrt(sigma_R2_moderate));
assignin('base', 'distancia_km', distancia_km);
assignin('base', 'bit_rate_bps', bit_rate_bps);

% Variables del APD
assignin('base', 'M_apd', M_apd);
assignin('base', 'R_base', R_base);
assignin('base', 'R_detector', R_detector);

fprintf(' Variables de Atenuación:\n');
fprintf(' L_geo_dB = %.2f dB (Atenuación Geométrica)\n', L_geo_dB);
fprintf(' gain_clear = %.4f\n', factor_clear);
fprintf(' gain_turb = %.4f\n', factor_turb);
fprintf(' gain_rain_mod = %.4f\n', factor_rain_mod);
fprintf(' gain_extreme = %.4f\n\n', factor_extreme);

fprintf(' Variables de Turbulencia:\n');
fprintf(' sigma_lnI_turb = %.4f\n\n', sqrt(sigma_R2_moderate));

fprintf(' Variables del APD:\n');
fprintf(' M_apd_dB = %d (Ganancia APD)\n', M_apd_dB);
fprintf(' R_base = %.1f A/W (Responsividad base)\n', R_base);
fprintf(' R_detector = %.1f A/W (Responsividad efectiva)\n\n', R_detector);

fprintf(' Umbrales (Calculados con el Factor de Correción 0,85)\n');
fprintf(' thr_opt_1 = %.6f V (Caso 1: Cielo Despejado)\n', thr_opt_1);
fprintf(' thr_opt_2 = %.6f V (Caso 2: Brisa/Turbulencia)\n', thr_opt_2);
fprintf(' thr_opt_3 = %.6f V (Caso 3: Lluvia Moderada)\n', thr_opt_3);
fprintf(' thr_opt_4 = %.6f V (Caso 4: Lluvia + Niebla)\n\n', thr_opt_4);

%% ========================================================================
% PARTE 9.1: VARIABLES DE POTENCIA DE SEÑAL PARA BLOQUE AWGN (SIMULINK)
% ========================================================================
fprintf('=== EXPORTANDO POTENCIAS DE SEÑAL PARA AWGN ===\n');

% Calculamos la Potencia Eléctrica de Entrada (Input Signal Power)
% Fórmula: P_elec = (P_optica * Responsividad * Ganancia_APD)^2
% Asumimos carga unitaria o normalizada para el bloque AWGN

SigPow_1 = (Pr_W_vec(1) * R_base * M_apd)^2; % Para Caso 1 (Sol)
SigPow_2 = (Pr_W_vec(2) * R_base * M_apd)^2; % Para Caso 2 (Brisa)
SigPow_3 = (Pr_W_vec(3) * R_base * M_apd)^2; % Para Caso 3 (Lluvia Media)
SigPow_4 = (Pr_W_vec(4) * R_base * M_apd)^2; % Para Caso 4 (Lluvia Fuerte)

% Exportar al Workspace
assignin('base', 'SigPow_1', SigPow_1);
assignin('base', 'SigPow_2', SigPow_2);
assignin('base', 'SigPow_3', SigPow_3);
assignin('base', 'SigPow_4', SigPow_4);

fprintf(' SigPow_1 (Sol)           = %.10f Watts\n', SigPow_1);
fprintf(' SigPow_2 (Brisa)         = %.10f Watts\n', SigPow_2);
fprintf(' SigPow_3 (Lluvia Media)  = %.10f Watts\n', SigPow_3);
fprintf(' SigPow_4 (Lluvia Fuerte) = %.10f Watts\n\n', SigPow_4);

%% ========================================================================
% PARTE 10: GRÁFICAS
%% ========================================================================

fprintf('=== GENERANDO GRÁFICAS ===\n\n');

% Gráfica 1: Comparación de Atenuaciones (CON L_GEO)
figure('Name', 'Comparación de Atenuaciones por Escenario (Con L_geo)', 'Position', [100 100 950 650]);
atenuaciones = [L_total_clear_dB, L_total_turb_dB, L_total_rain_mod_dB, L_total_extreme_dB];
atenuaciones_atm = [L_atm_clear_dB, L_atm_turb_dB, L_atm_mod_dB, L_atm_extreme_dB];

x_pos = 1:4;
bar_width = 0.35;

% Barras de atenuación atmosférica
bar(x_pos - bar_width/2, atenuaciones_atm, bar_width, 'FaceColor', [0.2 0.4 0.8], ...
    'DisplayName', 'Atenuación Atmosférica', 'EdgeColor', 'black', 'LineWidth', 1.5);
hold on;

% Barras de atenuación total (incluyendo L_geo)
bar(x_pos + bar_width/2, atenuaciones, bar_width, 'FaceColor', [1 0.2 0.2], ...
    'DisplayName', sprintf('Total (Atm + L_g_e_o = %.2f dB)', L_geo_dB), 'EdgeColor', 'black', 'LineWidth', 1.6);

set(gca, 'XTick', x_pos);
set(gca, 'XTickLabel', {'Cielo Despejado', 'Brisa/Turbulencia', 'Lluvia Moderada', 'Lluvia+Niebla'});
ylabel('Atenuación (dB)', 'FontSize', 12, 'FontWeight', 'bold');
title('Atenuación del Enlace FSO - Comparación con y sin Pérdidas Geométricas', ...
    'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 11);
grid on;
ylim([0 max(atenuaciones)*1.15]);

% Agregar valores sobre las barras
for i = 1:length(atenuaciones)
    text(i - bar_width/2, atenuaciones_atm(i), sprintf('%.2f', atenuaciones_atm(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 9, 'FontWeight', 'bold');
    text(i + bar_width/2, atenuaciones(i), sprintf('%.2f', atenuaciones(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 9, 'FontWeight', 'bold');
end

fprintf(' Gráfica 1: Comparación de Atenuaciones (Con L_geo) - Generada\n');

% Gráfica 2: Comparación Pr vs Pr_amp (+20 dB)
figure('Name', 'Potencia Recibida: Original vs Amplificada (+20 dB)', 'Position', [150 150 1000 600]);
x_pos = 1:4;
bar_width = 0.35;

bar(x_pos - bar_width/2, Pr_dBm_original, bar_width, 'FaceColor', [0.8 0.2 0.2], 'DisplayName', 'Pr (Original)');
hold on;
bar(x_pos + bar_width/2, Pr_amp_dBm, bar_width, 'FaceColor', [0.2 0.8 0.2], 'DisplayName', 'Pr_{amp} (Pr + 20 dB)');

set(gca, 'XTick', x_pos);
set(gca, 'XTickLabel', {'Cielo Despejado', 'Brisa/Turb.', 'Lluvia Mod.', 'Lluvia+Niebla'});
ylabel('Potencia Recibida (dBm)', 'FontSize', 12, 'FontWeight', 'bold');
title('Comparación de Potencia: Original vs Amplificada (M=10, Gain=20dB)', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 11);
grid on;

% Etiquetas de valores
for i = 1:length(Pr_dBm_original)
    text(i - bar_width/2, Pr_dBm_original(i), sprintf('%.2f', Pr_dBm_original(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 9, 'FontWeight', 'bold');
    text(i + bar_width/2, Pr_amp_dBm(i), sprintf('%.2f', Pr_amp_dBm(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 9, 'FontWeight', 'bold');
end

    fprintf(' Gráfica 2: Comparativa de la Potencia de la Señal con el APD - Generada\n');

% Gráfica 3: Distribución Log-Normal de Intensidad
figure('Name', 'Distribución Log-Normal - Turbulencia', 'Position', [200 200 900 600]);
I_norm = linspace(0.01, 3, 1000); % Intensidad normalizada

% Distribuciones para diferentes niveles de turbulencia
pdf_weak = (1./(I_norm.*sqrt(2*pi*sigma_R2_weak))) .* ...
    exp(-(log(I_norm) + sigma_R2_weak/2).^2 ./ (2*sigma_R2_weak));

pdf_moderate = (1./(I_norm.*sqrt(2*pi*sigma_R2_moderate))) .* ...
    exp(-(log(I_norm) + sigma_R2_moderate/2).^2 ./ (2*sigma_R2_moderate));

pdf_strong = (1./(I_norm.*sqrt(2*pi*sigma_R2_strong))) .* ...
    exp(-(log(I_norm) + sigma_R2_strong/2).^2 ./ (2*sigma_R2_strong));

plot(I_norm, pdf_weak, 'b-', 'LineWidth', 2, 'DisplayName', 'Turbulencia Débil');
hold on;
plot(I_norm, pdf_moderate, 'r-', 'LineWidth', 2, 'DisplayName', 'Turbulencia Moderada');
plot(I_norm, pdf_strong, 'g-', 'LineWidth', 2, 'DisplayName', 'Turbulencia Fuerte');
xlabel('Intensidad Normalizada', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Función de Densidad de Probabilidad', 'FontSize', 12, 'FontWeight', 'bold');
title('Distribución Log-Normal de la Intensidad Óptica Recibida', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 11);
grid on;
xlim([0 3]);

fprintf(' Gráfica 3: Distribución Log-Normal - Generada\n');

% Gráfica 4: Atenuación vs Intensidad de Lluvia
figure('Name', 'Atenuación vs Intensidad de Lluvia', 'Position', [250 250 900 600]);
R_range = 0:1:100; % Intensidades de lluvia (mm/h)
alfa_rain_range = 1.076 * R_range.^0.67; % Atenuación específica (dB/km)
L_rain_range = (alfa_rain_range + alfa_clear_dB_km) * distancia_km + L_geo_dB; % Incluir L_geo

% Curva principal (sin L_geo)
L_rain_range_no_geo = (alfa_rain_range + alfa_clear_dB_km) * distancia_km;
plot(R_range, L_rain_range_no_geo, 'b-', 'LineWidth', 2, 'DisplayName', 'Atenuación atmosférica');
hold on;

% Curva con L_geo
plot(R_range, L_rain_range, 'r-', 'LineWidth', 2.5, 'DisplayName', sprintf('Total (Atm + L_g_e_o=%.2f dB)', L_geo_dB));

% Guías
plot([R_mod R_mod], [0 max(L_rain_range)], 'r--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot([R_intense R_intense], [0 max(L_rain_range)], 'g--', 'LineWidth', 1.5, 'HandleVisibility', 'off');

% Puntos de Escenarios
plot(R_mod, L_total_rain_mod_dB, 'ro', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'r', 'DisplayName', 'Lluvia Moderada (25 mm/h)');
plot(R_intense, L_total_extreme_dB, 'go', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'g', 'DisplayName', 'Lluvia Intensa (50 mm/h)');

% Formato
xlabel('Intensidad de Lluvia (mm/h)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Atenuación Total (dB)', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('Atenuación por Lluvia en Enlace FSO (%.1f km, 1550 nm)', distancia_km), ...
    'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 11);
grid on;

fprintf(' Gráfica 4: Atenuación vs Intensidad de Lluvia (Con L_geo) - Generada\n\n');

fprintf(' Autor: Luiggi Giovanni Mejia Villegas\n');
