plane_x_interp=plane_x(14);
x_sp=x_speed(19);
plane_y_interp=plane_y(14);
y_sp=y_speed(19);
plane_z_interp=plane_z(14);
z_sp=z_speed(19);
j=14;
for tt=2:112
    if(tt==t(j+1)+2)
        j=j+1;
        plane_x_interp(tt)=plane_x_interp(tt-1);
        plane_y_interp(tt)=plane_y_interp(tt-1);
        plane_z_interp(tt)=plane_z_interp(tt-1);
        x_speed_int(tt)=x_speed(j);
        y_speed_int(tt)=y_speed(j);
        z_speed_int(tt)=z_speed(j);
    else
       plane_x_interp(tt)=plane_x_interp(tt-1)+x_speed(j);
       plane_y_interp(tt)=plane_y_interp(tt-1)+y_speed(j);
       plane_z_interp(tt)=plane_z_interp(tt-1)+z_speed(j);
       x_speed_int(tt)=x_speed(j);
       y_speed_int(tt)=y_speed(j);
       z_speed_int(tt)=z_speed(j);
    end

end