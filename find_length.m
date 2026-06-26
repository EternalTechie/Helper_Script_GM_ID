function L = find_length(db, quantity, gm_id, target)

    nCurves = length(db.curves);

    lengths = zeros(1,nCurves);
    metric  = zeros(1,nCurves);

    for k = 1:nCurves
    
        curve = db.curves(k);

        lengths(k) = curve.L;

        metric(k) = interp1( ...
            curve.GM_ID, ...
            curve.(quantity), ...
            gm_id, ...
            'pchip' ...
        );

    end

    % Check target range

    if target < min(metric) || target > max(metric)
        error('Target is outside characterization range');
    end

    % Sort because interp1 expects monotonic x

    [metric, idx] = sort(metric);
    lengths = lengths(idx);

    % Solve for length

    L = interp1( ...
        metric, ...
        lengths, ...
        target, ...
        'pchip' ...
    );

end