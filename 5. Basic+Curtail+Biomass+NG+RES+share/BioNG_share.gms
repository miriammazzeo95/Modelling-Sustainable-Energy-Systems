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
*Emissions Costs
ce emissions costs /20/
*Emission Factor for natural gas
eng emission factor NG /0.0002016/
*Efficiency NG unit
efng efficiency NG /0.6/
*Efficiency biomass unit
efb efficiency biomass /0.32/
*Grid Costs
cg grid cost /6.0816/
*Wind Costs
c1w costs of wind turbine /33.787/
c2w costs of wind generator /10.136/
*Biomass costs
cfb fixed costs for biomasss /273.1669606/
cvb variable costs for bioamss /0.0016/
colb costs for being online for biomass /2500/
csub startup costs for biomass /15000/
*Biomass fuel cost
cvfuelb variable fuel cost for biomass /0.0306/
*Natural gas costs
cfng fixed costs for NG /111.4967186/
cvng variable costs for NG /0.0045/
colng costs for being online for NG /2500/
csung startup costs for NG /15000/
*Natural gas fuel cost
cvfuelng variable fuel cost for NG /0.02744424/
*Biomass minimum load
minpb minimum load for biomass /0.15/
*Natural gas minimum load
minpng minimum load for natural gas /0.4/
*PV Costs
c1pv costs of solar plant /101.3606/
c2pv costs of pv inverter /8.7845/
*Storage Costs
c1s  costs of charging   /5.068/
c2s costs of storage     /0.06757/
c3s costs of discharging         /15.204/
ech efficiency charging       /1/
edch efficiency discharging      /0.4/
*Change of hourly storage losses as suggested in the presentation
sloss storage losses     /0.0000598216383138617/
l_init initial storage
Max maximum RANDOM /589514814800000000/
;
l_init=0;

variables
pw(t) wind production
ppv(t) pv production
*biomass production added
pb(t) biomass production
*Natural Gas production added
png(t) natural gas production
u(t) charging
v(t) discharging
l(t) storage level
a1w turbine capacity
a2w generator cpacity
a1pv PV plant capacity
a2pv PV inverter capacity
*Biomass capacity
ab biomass capacity
a1s Charging capacity
a2s Storage capacity
a3s discharging capacity
*Natural Gas capacity
ang natural gas capacity
z      total costs
;

free variable
z;

positive variables
pw
ppv
pb
png
u
v
l
a1w
a2w
a1pv
a2pv
*biomass capacity added
ab
a1s
a2s
a3s
;

*biomass and NG online and startup status added as binary variables
Binary variables
olb(t)
sub(t)
olng(t)
sung(t)
;

Equations
Costs            total costs
Demand(t)        demand constraint
ShareRES         share of RES constraint
Maxgenw(t)       maximum wind generation
Maxgenpv(t)      maximum pv generation
Maxgenb1(t)      maximum biomass generation
Maxgenb2(t)      maximum biomass generation online Max
Mingenb1(t)      minimum biomass generation
*Mingenb2(t)     minimum biomass generation online Min
Maxgenng1(t)     maximum NG generation
Maxgenng2(t)     maximum NG generation online Max
Mingenng1(t)     minimum NG generation
*Mingenng2(t)    minimum NG generation online Min
Maxcharge(t)     maximum charging
Maxdischarge(t)  maximum discharging
Maxstorage(t)    maximum storage
Stlevel(t)       storage level
Wprod(t)         wind production
Pvprod(t)        pv production
Bonlinestatus(t) biomass online status
NGonlinestatus(t) natural gas online status
;

*Objective function with biomass costs added
Costs..                  z =e= c1w*a1w+(c2w+cg)*a2w+c1pv*a1pv+
                         (c2pv+cg)*a2pv+c1s*a1s+c2s*a2s+c3s*a3s+(cfb+cg)*ab+(cfng+cg)*ang+
                         sum(t,(cvb+cvfuelb/efb)*pb(t)+(cvng+(cvfuelng+ce*eng)/efng)*png(t)
                         +colb*olb(t)+csub*sub(t)+colng*olng(t)+csung*sung(t));
*Demand constraint with biomass production added
Demand(t)..              pw(t)+ppv(t)+pb(t)+png(t)-u(t)*ech+v(t)*edch=e=d(t);
*Share of RES production policy (30%)
ShareRES(t)..            pw(t)+ppv(t)+pb(t)=g=0.3*(d(t)+u(t)*ech-v(t)*edch);
*Maximum wind generation
Maxgenw(t)..             pw(t)=l=a2w;
*Maximum pv generation
Maxgenpv(t)..            ppv(t)=l=a2pv;
*Maximum biomass generation
Maxgenb1(t)..            pb(t)=l=ab;
Maxgenb2(t)..            pb(t)=l=Max*olb(t);
*Minimum biomass generation
Mingenb1(t)..            pb(t)=g=ab*minpb;
*Maximum natural gas generation
Maxgenng1(t)..           png(t)=l=ang;
Maxgenng2(t)..           png(t)=l=Max*olng(t);
*Minimum natural gas generation
Mingenng1(t)..           png(t)=g=ang*minpng;
*Storage Constraints
Maxcharge(t)..           u(t)=l=a1s;
Maxdischarge(t)..        v(t)=l=a3s;
Maxstorage(t)..          l(t)=l=a2s;
Stlevel(t)..             l(t)=e=l(t-1)*(1-sloss)+u(t)-v(t);
*Wind production with curtailment
Wprod(t)..               pw(t)=l=w(t)*a1w;
*PV Production with curtailment
Pvprod(t)..              ppv(t)=l=p(t)*a1pv;
*Biomass Production online status
Bonlinestatus(t)..       olb(t)-olb(t-1)=l=sub(t);
*Natural gas Production online status
NGonlinestatus(t)..      olng(t)-olng(t-1)=l=sung(t);

model costmin /all/;
*option measure, limcol = 100, optcr = 0.00, mip = xpress ;
*Option limrow=0, limcol=0, optcr=0, mip=cplex;
solve costmin using MIP minimising z;

