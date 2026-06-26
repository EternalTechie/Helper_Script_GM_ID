% Desired operating point
Id = 25e-7;
L  = 1e-06;

pmos_db = pch_18_mac_nominal_1um;

lengths = [pmos_db.curves.L];

% Interpolate ro at every characterized length
ro_all = zeros(1,length(lengths));
gds_all = zeros(1,length(lengths));

for k = 1:length(lengths)

    curve = pmos_db.curves(k);

    % Sort by ID
    [id_sorted, idx] = sort(curve.ID);
    gds_sorted = curve.GDS(idx);

    % Remove duplicate ID values by averaging corresponding GDS
    [id_unique, ~, ic] = unique(id_sorted);
    gds_unique = accumarray(ic, gds_sorted, [], @mean);

    % Interpolate GDS
    gds = interp1( ...
        id_unique, ...
        gds_unique, ...
        Id, ...
        'pchip' ...
    );

    ro_all(k) = 1/gds;
    gds_all(k) = gds;

end

% Interpolate across channel length
ro = interp1( ...
    lengths, ...
    ro_all, ...
    L, ...
    'pchip' ...
);

disp(ro_all);

fprintf("ro = %.2f Ohm\ngds = %f", ro, 1/ro);