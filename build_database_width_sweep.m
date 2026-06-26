clear
clc

files = dir('SimResults_Width_Sweep/*.dat');

nW = length(files);

db = struct();

% Fixed length for width sweep

L = 430e-9;

for k = 1:nW

    fname = files(k).name;

    fprintf("Reading %s\n", fname);

    data_width = readtable("SimResults_Width_Sweep/" + fname);

    % Columns:
    % 1 -> VGS
    % 2 -> GM
    % 3 -> ID
    % 4 -> CGG
    % 5 -> GDS
    % 6 -> VTH
    % 7 -> VDSAT

    vgs   = data_width{:,1};
    gm    = data_width{:,2};
    id    = data_width{:,3};
    cgg   = data_width{:,4};
    gds   = data_width{:,5};
    vth   = data_width{:,6};
    vdsat = data_width{:,7};

    % Extract width from filename
    %
    % Example:
    % nmos_nch_320nm.dat -> 320 nm

    token = regexp(fname,'nmos_nch_(\d+)nm\.dat','tokens');

    W_nm = str2double(token{1}{1});
    W    = W_nm * 1e-9;

    % Derived quantities

    gm_id  = gm ./ id;
    gm_gds = gm ./ gds;
    ft     = gm ./ (2*pi*cgg);
    vov    = vgs - vth;
    id_w   = id ./ W;

    % Keep only VGS > 50mV

    mask = vgs > 50e-3;

    vgs   = vgs(mask);
    vth   = vth(mask);
    vov   = vov(mask);
    vdsat = vdsat(mask);

    id   = id(mask);
    id_w = id_w(mask);

    gm_id  = gm_id(mask);
    gm_gds = gm_gds(mask);
    ft     = ft(mask);

    % Sort by GM/ID

    [gm_id, idx] = sort(gm_id);

    vgs   = vgs(idx);
    vth   = vth(idx);
    vov   = vov(idx);
    vdsat = vdsat(idx);

    id   = id(idx);
    id_w = id_w(idx);

    gm_gds = gm_gds(idx);
    ft     = ft(idx);

    % Store curve

    db.curves(k).L = L;
    db.curves(k).W = W;

    db.curves(k).VGS   = vgs;
    db.curves(k).VTH   = vth;
    db.curves(k).VOV   = vov;
    db.curves(k).VDSAT = vdsat;

    db.curves(k).ID   = id;
    db.curves(k).ID_W = id_w;

    db.curves(k).GM_ID  = gm_id;
    db.curves(k).GM_GDS = gm_gds;
    db.curves(k).FT     = ft;

end

% Sort curves by increasing width

W_all = [db.curves.W];

[~, idx] = sort(W_all);

db.curves = db.curves(idx);

db.INFO = 'GM/ID width characterization database';
db.L    = L;

nch_18_mac_width_sweep = db;

save('nch_18_mac_width_sweep.mat', ...
     'nch_18_mac_width_sweep');

disp('Database written to nch_18_mac_width_sweep.mat')