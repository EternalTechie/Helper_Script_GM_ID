function value = lookup(db, quantity, gm_id, L)

    lengths = [db.curves.L];

    % Check length range

    if L < min(lengths) || L > max(lengths)
        error('Length outside characterization range')
    end

    % Exact length match

    idx = find(abs(lengths - L) < 1e-15, 1);

    if ~isempty(idx)

        curve = db.curves(idx);

        if gm_id < min(curve.GM_ID) || gm_id > max(curve.GM_ID)
            error('gm/Id outside characterization range')
        end

        value = interp1( ...
            curve.GM_ID, ...
            curve.(quantity), ...
            gm_id, ...
            'pchip' ...
        );

        return

    end

    % Evaluate quantity at all characterized lengths

    nL = length(db.curves);

    metric = zeros(1, nL);

    for k = 1:nL

        curve = db.curves(k);

        if gm_id < min(curve.GM_ID) || gm_id > max(curve.GM_ID)
            error('gm/Id outside characterization range')
        end

        metric(k) = interp1( ...
            curve.GM_ID, ...
            curve.(quantity), ...
            gm_id, ...
            'pchip' ...
        );

    end

    % Interpolate across all lengths

    value = interp1( ...
        lengths, ...
        metric, ...
        L, ...
        'pchip' ...
    );

end