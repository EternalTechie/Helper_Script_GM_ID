clear
clc

load("pch_18_mac_nominal_1um.mat")

curve = pch_18_mac_nominal_1um.curves(1);

%% ID vs VGS

VGS = curve.VOV + curve.VTH;
ID  = curve.ID;

figure;
plot(VGS, ID, 'LineWidth', 1.5);
grid on;
xlabel('V_{GS} (V)');
ylabel('I_D (A)');
title(sprintf('I_D vs V_{GS} (L = %.0f nm)', curve.L*1e9));

%% GDS vs ID

GDS = curve.GDS;

figure;
plot(ID, GDS, 'LineWidth', 1.5);
grid on;
xlabel('I_D (A)');
ylabel('g_{ds} (S)');
title(sprintf('g_{ds} vs I_D (L = %.0f nm)', curve.L*1e9));

%% Check for duplicate ID values

fprintf("Total samples      : %d\n", length(ID));
fprintf("Unique ID samples  : %d\n", length(unique(ID)));

dup = find(diff(ID)==0);

if isempty(dup)
    disp("No consecutive duplicate ID values.");
else
    fprintf("Found %d consecutive duplicate ID values.\n", length(dup));
end