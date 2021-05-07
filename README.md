This code simulates the scenarios presented in 

Can the US return to pre-COVID-19 normal by July 4th?

Seyed M. Moghadas PhD, Pratha Sah PhD, Thomas N. Vilches PhD, Alison P. Galvani PhD


The file run_scen.jl runs the scenarios related to behavioral changes.
The main parameters to be changed are:
 
 -- day_insert_kids that represent the day in which teenagers are allowed start getting the vaccine. It is either 274 (June 1, 2021) or 304 (July 1,2021)
 
 --  back_normal_rate that represents the increasing in the contact rate when people who is not vaccinated yet are allowed to interact. We simulated 2.15285253=>1 (pre-pandemic contacts) 1.506996771 =>0.7 (70% of pre-pandemic contacts) and 1.82992465 =>0.85 (85% of pre-pandemic contacts) 
