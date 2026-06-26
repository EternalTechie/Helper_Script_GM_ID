clear
clc

files = dir('SimResults_Width_1um/*.dat');

nL = length(files);

db = struct();

W = 1e-06;

for k = 1:nL

    fname = files(k).name;

    fprintf("Reading %s\n", fname);

    data_length = readtable("SimResults_Width_1um/" + fname);

    % Columns:
    % 1 -> VGS
    % 2 -> GM
    % 3 -> ID
    % 4 -> CGG
    % 5 -> GDS
    % 6 -> VTH
    % 7 -> VDSAT
    % 8 -> VTH
    
    vgs = data_length{:, 1};
    gm  = data_length{:,2};
    id  = data_length{:,3};
    cgg = data_length{:,4};
    gds = data_length{:,5};
    vth = data_length{:,6};
    vdsat = data_length{:,7};

    % Derived quantities

    gm_id  = gm ./ id;
    gm_gds = gm ./ gds;
    ft     = gm ./ (2*pi*cgg);
    vov    = vgs - vth;
    id_w   = id ./ W;

    % Keep only VOV > 50mV

    mask = vgs > 50e-3;

    vth    = vth(mask);
    vov    = vov(mask);
    vdsat = vdsat(mask);

    id     = id(mask);
    id_w   = id_w(mask);

    gm_id  = gm_id(mask);
    gm_gds = gm_gds(mask);
    ft     = ft(mask);

    % Sort by GM/ID

    [gm_id, idx] = sort(gm_id);

    vth    = vth(idx);
    vov    = vov(idx);
    vdsat = vdsat(idx);

    id     = id(idx);
    id_w   = id_w(idx);

    gm_gds = gm_gds(idx);
    ft     = ft(idx);

    % Extract length from filename
    %
    % Example:
    % nmos_nch_150nm.dat -> 150 nm

    token = regexp(fname,'nmos_nch_(\d+)nm\.dat','tokens');

    L_um = str2double(token{1}{1});
    L    = L_um * 1e-9;

    % Store curve

    db.curves(k).L = L;
    db.curves(k).W = W;

    db.curves(k).VTH = vth;
    db.curves(k).VOV = vov;
    db.curves(k).VDSAT = vdsat;

    db.curves(k).ID   = id;
    db.curves(k).ID_W = id_w;

    db.curves(k).GM_ID  = gm_id;
    db.curves(k).GM_GDS = gm_gds;
    db.curves(k).FT     = ft;

end

% Sort curves by increasing length

L_all = [db.curves.L];

[~, idx] = sort(L_all);

db.curves = db.curves(idx);

db.INFO = 'GM/ID characterization database';
db.W    = W;

nch_18_mac_nominal_1um = db;

save('nch_18_mac_nominal_1um.mat','nch_18_mac_nominal_1um');

disp('Database written to nch_18_mac_nominal_1um.mat')