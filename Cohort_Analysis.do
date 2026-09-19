**
clear
use "C:\Users\marti\OneDrive\Desktop\Stat_clinical_epi\Parziale_2\Porto_Marghera.dta"

adopath + "C:\Users\marti\OneDrive\Desktop\Stat_clinical_epi\Lab_Sera"
which dyrate


* Descriptive statistics
describe
summarize y*

tab fucod

* fucod: event
* yrin: year of first exposure
* ynasc: year of birth
* yrin73: year of entry into follow-up
* yrout: year of end of follow-up or event

**** VARIABLE CREATION ***

* Create the EVENTO variable
gen EVENTO=0
replace EVENTO=1 if fucod==2
label define EVENTO 0 "Alive" 1 "Deceased"
label values EVENTO EVENTO

tab EVENTO

browse if idsogget==24 | idsogget==1

* Create age-at-exposure variable
gen Eta_esp=0
replace Eta_esp=yrin-ynasc

* Create Eta_start variable (age at entry into follow-up)
gen Eta_start=0
replace Eta_start=yrin73-ynasc

* Create age-at-event or age-at-end-of-follow-up variable
* Age at the event if EVENTO==1, or age at the end of follow-up if EVENTO==0
gen Eta_end=0
replace Eta_end=yrout-ynasc

* Create the Durata_fup variable
* Time to the event if EVENTO==1, or follow-up duration if EVENTO==0
gen Durata_fup=0
replace Durata_fup=yrout-yrin73

* Create latency variable (time from first exposure to the event or end of follow-up)
* Length of employment
gen Latenza=0
replace Latenza=yrout-yrin

* Time from the beginning of employment to the beginning of follow-up
gen dur_lav_start_fup=0
replace dur_lav_start_fup=yrin73-yrin

* browse if idsogget==24 | idsogget==1

* Categorize entry into exposure
gen ingresso= .
replace ingresso=1 if yrin < 1969
replace ingresso=2 if yrin >= 1969 & yrin < 1973
replace ingresso=3 if yrin >= 1973 & yrin < 1985
replace ingresso=4 if yrin >= 1985

label define ingresso 1 "<1969" 2 "1969-72" 3 "1973-84" 4 ">=1985"
label values ingresso ingresso

* Summary of the variables created

summarize EVENTO Eta_esp Eta_end Eta_start Durata_fup Latenza dur_lav_start_fu ingresso

*** DEFINE THE SURVIVAL-TIME DATA ***

stset yrout, failure(EVENTO) origin(time yrin) enter(time yrin73) id(idsogget)

* Describe the data
stsum
stdes
stvary

* Split by calendar period
stsplit cal=0, at(1973, 1983, 1993, 2000)
tabulate cal

* browse if idsogget==24 | idsogget==1

* Split by age (every 5 years)
stsplit eta, after(time=ynasc) at(15(5)90)
tabulate eta

* browse if idsogget==24 | idsogget==1

* Split by latency
stsplit lat, after(time=yrin) at(0,10,20,30,40,50)
tabulate lat

* browse if idsogget==24 | idsogget==1

* Kaplan-Meier survival curves
sts graph
sts graph, failure by(lat)
sts graph, failure by(eta)
sts graph, failure by(cal)
sts graph, failure by(ingresso)

* Create person-years variable
gen ap=(_t - _t0)

* Create current-calendar-year variable
gen anno_corr=0
replace anno_corr=yrin+_t0

* Create current-age variable
gen eta_corr=Eta_esp+_t0

stvary

* browse if idsogget==24 | idsogget==1

table eta, stat(sum ap)

table cal, stat(sum ap)

table lat, stat(sum ap)

tab EVENTO cal
tab EVENTO eta
tab EVENTO lat

stsum, by(lat)
stsum, by(eta)
stsum, by(cal)

*** RATES **

* Overall rate
strate

* Stratified rates
strate cal
strate eta
strate lat

* Rate-ratio comparisons by latency
stmh lat, compare(10,0)
stmh lat, compare(20,0)
stmh lat, compare(30,0)
stmh lat, compare(40,0)

* Add confounders (calendar period and age)
stmh lat cal eta, compare(10,0)
stmh lat cal eta, compare(20,0)
stmh lat cal eta, compare(30,0)
stmh lat cal eta, compare(40,0)


** AGGREGATED DATA **
collapse (sum) EVENTO ap, by(cal eta lat)
describe

* STANDARDIZED RATES (SRR)

ir EVENTO lat ap, by(eta) estandard
ir EVENTO lat ap, by(cal) estandard

*** Same results as strate and stmh ***
* Crude rates

dyrate EVENTO, exposure(ap)
dyrate EVENTO eta, exposure(ap)
dyrate EVENTO lat, exposure(ap)

* Rate ratios
dymh EVENTO lat, exposure(ap) compare(10,0)
dymh EVENTO lat, exposure(ap) compare(20,0)
dymh EVENTO lat, exposure(ap) compare(30,0)
dymh EVENTO lat, exposure(ap) compare(40,0)


* Mantel-Haenszel rate ratios/trend
dymh EVENTO lat cal eta, exposure(ap) compare(10,0)
dymh EVENTO lat cal eta, exposure(ap) compare(20,0)
dymh EVENTO lat cal eta, exposure(ap) compare(30,0)
dymh EVENTO lat cal eta, exposure(ap) compare(40,0)

