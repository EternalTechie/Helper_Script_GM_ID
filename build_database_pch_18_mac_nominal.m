clear
clc

files = dir('SimResults_PMOS_1um/*.dat');

nL = length(files);

db = struct();

W = 1e-6;

for k = 1:nL

    fname = files(k).name;

    fprintf("Reading %s\n", fname);

    data_length = readtable("SimResults_PMOS_1um/" + fname);

    % Columns:
    % 1 -> VGS
    % 2 -> GM
    % 3 -> ID
    % 4 -> CGG
    % 5 -> GDS
    % 6 -> VTH
    % 7 -> VDSAT

    vgs   = data_length{:,1};
    gm    = data_length{:,2};
    id    = data_length{:,3};
    cgg   = data_length{:,4};
    gds   = data_length{:,5};
    vth   = data_length{:,6};
    vdsat = data_length{:,7};

    % Derived quantities

    gm_id  = gm ./ id;
    gm_gds = gm ./ gds;
    ft     = gm ./ (2*pi*cgg);
    vov    = vgs - vth;
    id_w   = id ./ W;

    % Keep only VOV > 50 mV

    mask = vov > 50e-3;

    vgs   = vgs(mask);
    vth   = vth(mask);
    vov   = vov(mask);
    vdsat = vdsat(mask);

    id    = id(mask);
    id_w  = id_w(mask);

    gm    = gm(mask);
    gds   = gds(mask);

    gm_id  = gm_id(mask);
    gm_gds = gm_gds(mask);
    ft     = ft(mask);

    % Extract length from filename

    token = regexp(fname,'pch_18_mac_(\d+)nm\.dat','tokens');

    L_nm = str2double(token{1}{1});
    L = L_nm*1e-9;

    % Store curve (NO SORTING)

    db.curves(k).L = L;
    db.curves(k).W = W;

    db.curves(k).VGS   = vgs;
    db.curves(k).VTH   = vth;
    db.curves(k).VOV   = vov;
    db.curves(k).VDSAT = vdsat;

    db.curves(k).ID   = id;
    db.curves(k).ID_W = id_w;

    db.curves(k).GM   = gm;
    db.curves(k).GDS  = gds;

    db.curves(k).GM_ID  = gm_id;
    db.curves(k).GM_GDS = gm_gds;
    db.curves(k).FT     = ft;

end

% Sort only the curves by channel length

L_all = [db.curves.L];
[~,idx] = sort(L_all);
db.curves = db.curves(idx);

db.INFO = 'PMOS characterization database';
db.W = W;

pch_18_mac_nominal_1um = db;

save('pch_18_mac_nominal_1um.mat','pch_18_mac_nominal_1um');

disp('Database written to pch_18_mac_nominal_1um.mat')