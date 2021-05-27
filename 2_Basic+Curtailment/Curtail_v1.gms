Sets t        time periods    /t0001*t8760/
;
$call=xls2gms r=a1:b8760 i=Demand.xls o=demand.inc

Parameter
d(t)     demand
/
$include demand.inc
/
;
Parameter
w(t)     wind profile
/
$include windprofile.inc
/
;
Parameter
p(t)     PV profile
/
$include PVprofile.inc
/
;


Scalar
cg grid cost (Euros per MW) /6.0816/
c1w costs of wind turbine /33.787/
c2w costs of wind generator /10.136/
c1pv costs of solar plant /101.3606/
c2pv costs of pv inverter /8.7845/
c1s  costs of charging   /5.068/
c2s costs of storage     /0.06757/
c3s costs of discharging         /15.204/
ech efficiency charging       /1/
edch efficiency discharging      /0.4/
sloss storage losses     /0.0000598/
l_init initial storage
;

l_init=0;

variables
pw(t) wind production
ppv(t) pv production
u(t) charging
v(t) discharging
l(t) storage level
a1w turbine capacity
a2w generator cpacity
a1pv PV plant capacity
a2pv PV inverter capacity
a1s Charging capacity
a2s Storage capacity
a3s discharging capacity
z      total costs
;

free variable
z;

positive variables
pw
ppv
u
v
l
a1w
a2w
a1pv
a2pv
a1s
a2s
a3s
;

Equations
Costs            total costs
Demand(t)        demand constraint
Maxgenw(t)       maximum wind generation
Maxgenpv(t)      maximum pv generation
Maxcharge(t)     maximum charging
Maxdischarge(t)  maximum discharging
Maxstorage(t)    maximum storage
Wprod(t)         wind production
Pvprod(t)        pv production
Stlevel(t)       storage level
;

Costs..                  z =e= c1w*a1w+(c2w+cg)*a2w+c1pv*a1pv+
                         (c2pv+cg)*a2pv+c1s*a1s+c2s*a2s+c3s*a3s;
Demand(t)..              pw(t)+ppv(t)-u(t)*ech+v(t)*edch=e=d(t);
Maxgenw(t)..             pw(t)=l=a2w;
Maxgenpv(t)..            ppv(t)=l=a2pv;
Maxcharge(t)..           u(t)=l=a1s;
Maxdischarge(t)..        v(t)=l=a3s;
Maxstorage(t)..          l(t)=l=a2s;
*curtailment added to wind
Wprod(t)..               pw(t)=l=w(t)*a1w;
*curtailment added to pv
Pvprod(t)..              ppv(t)=l=p(t)*a1pv;
Stlevel(t)..             l(t)=e=l(t-1)*(1-sloss)+u(t)-v(t)
;
model costmin /all/
solve costmin using lp minimising z;
execute_unload "results2.gdx" pw.l ppv.l u.l v.l l.l a1w.l a2w.l a1pv.l a2pv.l a1s.l a2s.l a3s.l z.l ;
execute 'gdxxrw.exe results2.gdx var=ppv.l rng=pv!'
execute 'gdxxrw.exe results2.gdx var=pw.l rng=wind!'
execute 'gdxxrw.exe results2.gdx var=u.l rng=charging!'
execute 'gdxxrw.exe results2.gdx var=v.l rng=discharging!'
execute 'gdxxrw.exe results2.gdx var=l.l rng=level!'
execute 'gdxxrw.exe results2.gdx var=a1w.l rng=turbine_cap!'
execute 'gdxxrw.exe results2.gdx var=a2w.l rng=generator_cap!'
execute 'gdxxrw.exe results2.gdx var=a1pv.l rng=pv_cap!'
execute 'gdxxrw.exe results2.gdx var=a2pv.l rng=inverter_cap!'
execute 'gdxxrw.exe results2.gdx var=a1s.l rng=charging_cap!'
execute 'gdxxrw.exe results2.gdx var=a2s.l rng=storage_cap!'
execute 'gdxxrw.exe results2.gdx var=a3s.l rng=discharging_cap!'
execute 'gdxxrw.exe results2.gdx var=z.l rng=z!'
