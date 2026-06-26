function [rms_all, rms_overall] = width_error(db, quantity)

    ref = db.curves(1);

    nW = length(db.curves);

    rms_all = zeros(1, nW-1);

    for k = 2:nW

        curve = db.curves(k);

        % Common VOV range

        vov_min = max(min(ref.VOV), min(curve.VOV));
        vov_max = min(max(ref.VOV), max(curve.VOV));

        vov = linspace(vov_min, vov_max, 2000);

        % Interpolate quantity onto common VOV grid

        q_ref = interp1( ...
            ref.VOV, ...
            ref.(quantity), ...
            vov, ...
            'pchip' ...
        );

        q_cur = interp1( ...
            curve.VOV, ...
            curve.(quantity), ...
            vov, ...
            'pchip' ...
        );

        % RMS error with respect to reference width

        rms_all(k-1) = sqrt(mean((q_cur - q_ref).^2));

    end

    % RMS of RMS errors

    rms_overall = sqrt(mean(rms_all.^2));

end