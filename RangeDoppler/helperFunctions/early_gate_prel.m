function gate_ok=early_gate_prel(est, meas)
range=est(1);
doppler=est(2);
meas_range=meas(1);
meas_doppler=meas(2);
range_value=600;
doppler_value=50;
range_offset=1.5*range_value;
doppler_offset=2*doppler_value;
if(meas_range>range-range_offset && meas_range<range+range_offset && meas_doppler<doppler+doppler_offset && meas_doppler>doppler-doppler_offset)
    gate_ok=1;
else
    gate_ok=0;
end