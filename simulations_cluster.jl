using Distributed
using Base.Filesystem
using DataFrames
using CSV
using Query
using Statistics
using UnicodePlots
using ClusterManagers
using Dates
using DelimitedFiles

## load the packages by covid19abm

#using covid19abm

#addprocs(2, exeflags="--project=.")


#@everywhere using covid19abm

addprocs(SlurmManager(500), N=17, topology=:master_worker, exeflags="--project=.")
@everywhere using Parameters, Distributions, StatsBase, StaticArrays, Random, Match, DataFrames
@everywhere include("covid19abm.jl")
@everywhere const cv=covid19abm


function run(myp::cv.ModelParameters, nsims=1000, folderprefix="./")
    println("starting $nsims simulations...\nsave folder set to $(folderprefix)")
    dump(myp)
   
    # will return 6 dataframes. 1 total, 4 age-specific 
    cdr = pmap(1:nsims) do x                 
            cv.runsim(x, myp)
    end      

    println("simulations finished")
    println("total size of simulation dataframes: $(Base.summarysize(cdr))")
    ## write the infectors 
    DelimitedFiles.writedlm("$(folderprefix)/infectors.dat", [cdr[i].infectors for i = 1:nsims])    

    ## write contact numbers
    #writedlm("$(folderprefix)/ctnumbers.dat", [cdr[i].ct_numbers for i = 1:nsims])    
    ## stack the sims together
    allag = vcat([cdr[i].a  for i = 1:nsims]...)
    ag1 = vcat([cdr[i].g1 for i = 1:nsims]...)
    ag2 = vcat([cdr[i].g2 for i = 1:nsims]...)
    ag3 = vcat([cdr[i].g3 for i = 1:nsims]...)
    ag4 = vcat([cdr[i].g4 for i = 1:nsims]...)
    ag5 = vcat([cdr[i].g5 for i = 1:nsims]...)
    ag6 = vcat([cdr[i].g6 for i = 1:nsims]...)
    mydfs = Dict("all" => allag, "ag1" => ag1, "ag2" => ag2, "ag3" => ag3, "ag4" => ag4, "ag5" => ag5, "ag6" => ag6)
    #mydfs = Dict("all" => allag)
    
    ## save at the simulation and time level
    ## to ignore for now: miso, iiso, mild 
    #c1 = Symbol.((:LAT, :ASYMP, :INF, :PRE, :MILD,:IISO, :HOS, :ICU, :DED), :_INC)
    #c2 = Symbol.((:LAT, :ASYMP, :INF, :PRE, :MILD,:IISO, :HOS, :ICU, :DED), :_PREV)
    if !myp.heatmap
        c1 = Symbol.((:LAT, :HOS, :ICU, :DED,:LAT2, :HOS2, :ICU2, :DED2,:LAT3, :HOS3, :ICU3, :DED3), :_INC)
        #c2 = Symbol.((:LAT, :HOS, :ICU, :DED,:LAT2, :HOS2, :ICU2, :DED2), :_PREV)
        for (k, df) in mydfs
            println("saving dataframe sim level: $k")
            # simulation level, save file per health status, per age group
            #for c in vcat(c1..., c2...)
            for c in vcat(c1...)
            #for c in vcat(c2...)
                udf = unstack(df, :time, :sim, c) 
                fn = string("$(folderprefix)/simlevel_", lowercase(string(c)), "_", k, ".dat")
                CSV.write(fn, udf)
            end
            println("saving dataframe time level: $k")
            # time level, save file per age group
            #yaf = compute_yearly_average(df)       
            #fn = string("$(folderprefix)/timelevel_", k, ".dat")   
            #CSV.write(fn, yaf)       
        end
    else
        c1 = Symbol.((:LAT, :HOS, :ICU, :DED,:LAT2, :HOS2, :ICU2, :DED2,:LAT3, :HOS3, :ICU3, :DED3), :_INC)
        #c2 = Symbol.((:LAT, :HOS, :ICU, :DED,:LAT2, :HOS2, :ICU2, :DED2), :_PREV)
        for (k, df) in mydfs
            println("saving dataframe sim level: $k")
            # simulation level, save file per health status, per age group
            
            for c in vcat(c1...)
            #for c in vcat(c2...)
                udf = unstack(df, :time, :sim, c) 
                fn = string("$(folderprefix)/simlevel_", lowercase(string(c)), "_", k, ".dat")
                CSV.write(fn, udf)
            end
            println("saving dataframe time level: $k")
            # time level, save file per age group
            #yaf = compute_yearly_average(df)       
            #fn = string("$(folderprefix)/timelevel_", k, ".dat")   
            #CSV.write(fn, yaf)       
        end
    end
   


    ########## save general info about vaccine
   #=  n_vac_sus1 = [cdr[i].n_vac_sus1 for i=1:nsims]
    n_vac_rec1 = [cdr[i].n_vac_rec1 for i=1:nsims]
    n_inf_vac1 = [cdr[i].n_inf_vac1 for i=1:nsims]
    n_dead_vac1 = [cdr[i].n_dead_vac1 for i=1:nsims]
    n_hosp_vac1 = [cdr[i].n_hosp_vac1 for i=1:nsims]
    n_icu_vac1 = [cdr[i].n_icu_vac1 for i=1:nsims]
    
    n_vac_sus2 = [cdr[i].n_vac_sus2 for i=1:nsims]
    n_vac_rec2 = [cdr[i].n_vac_rec2 for i=1:nsims]
    n_inf_vac2 = [cdr[i].n_inf_vac2 for i=1:nsims]
    n_dead_vac2 = [cdr[i].n_dead_vac2 for i=1:nsims]
    n_hosp_vac2 = [cdr[i].n_hosp_vac2 for i=1:nsims]
    n_icu_vac2 = [cdr[i].n_icu_vac2 for i=1:nsims]

    n_dead_nvac = [cdr[i].n_dead_nvac for i=1:nsims]
    n_inf_nvac = [cdr[i].n_inf_nvac for i=1:nsims]
    n_hosp_nvac = [cdr[i].n_hosp_nvac for i=1:nsims]
    n_icu_nvac = [cdr[i].n_icu_nvac for i=1:nsims] =#
    R01 = [cdr[i].R01 for i=1:nsims]
    R02 = [cdr[i].R02 for i=1:nsims]
   
    #data = DataFrame(vac_sus_dose1 = n_vac_sus1,vac_herd_dose_1 = n_vac_rec1,inf_dose_1 = n_inf_vac1, dead_dose_1 = n_dead_vac1, hosp_dose_1 = n_hosp_vac1,icu_dose_1 = n_icu_vac1, vac_sus_dose_2 = n_vac_sus2, vac_herd_dose_2 = n_vac_rec2, inf_dose_2 = n_inf_vac2, dead_dose_2 = n_dead_vac2, hosp_dose_2 = n_hosp_vac2, icu_dose_2 = n_icu_vac2, inf_n_vac = n_inf_nvac,dead_n_vac = n_dead_nvac,hosp_n_vac = n_hosp_nvac,icu_n_vac = n_icu_nvac)
    
    #writedlm(string(folderprefix,"/general_vac_info.dat"),data)
    #CSV.write("$folderprefix/general_vac_info.csv",data)
    #= writedlm(string(folderprefix,"/com_vac1.dat"),[cdr[i].com_v1 for i=1:nsims])
    writedlm(string(folderprefix,"/ncom_vac1.dat"),[cdr[i].ncom_v1 for i=1:nsims])
    writedlm(string(folderprefix,"/com_vac2.dat"),[cdr[i].com_v2 for i=1:nsims])
    writedlm(string(folderprefix,"/ncom_vac2.dat"),[cdr[i].ncom_v2 for i=1:nsims])
    writedlm(string(folderprefix,"/com_total.dat"),[cdr[i].com_t for i=1:nsims])
    writedlm(string(folderprefix,"/ncom_total.dat"),[cdr[i].ncom_t for i=1:nsims]) =#
    writedlm(string(folderprefix,"/R01.dat"),R01)
    writedlm(string(folderprefix,"/R02.dat"),R02)
    
    writedlm(string(folderprefix,"/init_iso.dat"),[cdr[i].iniiso for i=1:nsims])

    return mydfs
end


function compute_yearly_average(df)
    ya = df |> @groupby(_.time) |> @map({time=key(_), cnt=length(_),
              sus_prev=mean(_.SUS_PREV), 
              lat_prev=mean(_.LAT_PREV), 
              pre_prev=mean(_.PRE_PREV), 
              asymp_prev=mean(_.ASYMP_PREV), 
              mild_prev=mean(_.MILD_PREV), 
              miso_prev=mean(_.MISO_PREV), 
              inf_prev=mean(_.INF_PREV), 
              iiso_prev=mean(_.IISO_PREV), 
              hos_prev=mean(_.HOS_PREV), 
              icu_prev=mean(_.ICU_PREV), 
              rec_prev=mean(_.REC_PREV), 
              ded_prev=mean(_.DED_PREV), 
              sus_inc=mean(_.SUS_INC),
              lat_inc=mean(_.LAT_INC), 
              pre_inc=mean(_.PRE_INC), 
              asymp_inc=mean(_.ASYMP_INC), 
              mild_inc=mean(_.MILD_INC), 
              miso_inc=mean(_.MISO_INC), 
              inf_inc=mean(_.INF_INC),
              iiso_inc=mean(_.IISO_INC),
              hos_inc=mean(_.HOS_INC),
              icu_inc=mean(_.ICU_INC),
              rec_inc=mean(_.REC_INC),
              ded_inc=mean(_.DED_INC)
              }) |> DataFrame
    return ya
end
#=
function savestr(p::cv.ModelParameters, custominsert="/", customstart="")
    datestr = (Dates.format(Dates.now(), dateformat"mmdd_HHMM"))
    ## setup folder name based on model parameters
    taustr = replace(string(p.??mild), "." => "")
    fstr = replace(string(p.fmild), "." => "")
    rstr = replace(string(p.??), "." => "")
    prov = replace(string(p.prov), "." => "")
    eldr = replace(string(p.eldq), "." => "")
    eldqag = replace(string(p.eldqag), "." => "")     
    fpreiso = replace(string(p.fpreiso), "." => "")
    tpreiso = replace(string(p.tpreiso), "." => "")
    fsev = replace(string(p.fsevere), "." => "")    
    frelasymp = replace(string(p.frelasymp), "." => "")
    strat = replace(string(p.ctstrat), "." => "")
    pct = replace(string(p.fctcapture), "." => "")
    cct = replace(string(p.fcontactst), "." => "")
    idt = replace(string(p.cidtime), "." => "") 
    tback = replace(string(p.cdaysback), "." => "")     
    fldrname = "/data/covid19abm/simresults/$(custominsert)/$(customstart)_$(prov)_strat$(strat)_pct$(pct)_cct$(cct)_idt$(idt)_tback$(tback)_fsev$(fsev)_tau$(taustr)_fmild$(fstr)_q$(eldr)_qag$(eldqag)_relasymp$(frelasymp)_tpreiso$(tpreiso)_preiso$(fpreiso)/"
    mkpath(fldrname)
end=#

function _calibrate(nsims, myp::cv.ModelParameters)
    myp.calibration != true && error("calibration parameter not turned on")
    vals = zeros(Int64, nsims)
    println("calibrating with beta: $(myp.??), total sims: $nsims, province: $(myp.prov)")
    println("calibration parameters:")
    dump(myp)
    cdr = pmap(1:nsims) do i 
        h,hh = cv.main(myp,i) ## gets the entire model. 
        val = sum(cv._get_column_incidence(h, covid19abm.LAT))            
        return val
    end
    return mean(cdr), std(cdr)
end

function calibrate(beta, nsims, herdi = 0, cali2 = false, fs = 0.0, prov=:usa, init_inf=1, size=10000)
    myp = cv.ModelParameters() # set up default parameters 
    myp.?? = beta
    myp.prov = prov
    myp.popsize = size
    myp.modeltime = 30
    myp.calibration = true
    myp.calibration2 = cali2
    myp.fsevere = fs
    myp.fmild = fs
    myp.initialinf = init_inf
    myp.herd = herdi
    m, sd = _calibrate(nsims, myp)
    println("mean R0: $(m) with std: $(sd)")
    myp.calibration = false       
    return m
end

function calibrate_robustness(beta, reps, prov=:usa)
    #[:ontario, :alberta, :bc, :manitoba, :newbruns, :newfdland, :nwterrito, :novasco, :nunavut, :pei, :quebec, :saskat, :yukon]
    # once a beta is found based on nsims simulations, 
    # see how robust it is. run calibration with same beta 100 times 
    # to see the variation in R0 produced. 
    #nsims = [1000]
    means = zeros(Float64, reps)
    #for (i, ns) in enumerate(nsims)
    cd = map(1:reps) do x 
        println("iter: $x")
        mval = calibrate(beta,10000)         
        return mval
    end
    
    #end
    # for i in 2:nworkers()
    #     ## mf defined as: @everywhere mg() = covid19abm.p.??     
    #     rpr = remotecall_fetch(mf,  i+1).prov
    #     rpr != prov && error("province didn't get set in the remote workers")
    # end
    return cd
end

function create_folder(ip::cv.ModelParameters,vac="none")
    
    
    
    
    #RF = string("heatmap/results_prob_","$(replace(string(ip.??), "." => "_"))","_vac_","$(replace(string(ip.vaccine_ef), "." => "_"))","_herd_immu_","$(ip.herd)","_$strategy","cov_$(replace(string(ip.cov_val)))") ## 
    main_folder = "/data/thomas-covid/CDC_guidelines"
    #main_folder = "."
   
    #RF = string(main_folder,"/results_prob_","$(replace(string(ip.??), "." => "_"))","_herd_immu_","$(ip.herd)","_$vac","_$(ip.third_strain_trans)_$(ip.strain_ef_red3)_$(ip.file_index)") ##  
    #this one below is for US_april in the lancet
    RF = string(main_folder,"/results_prob_","$(replace(string(ip.??), "." => "_"))","_herd_immu_","$(ip.herd)","_$vac","_$(ip.third_strain_trans)_$(ip.file_index)") ##  
   
    if !Base.Filesystem.isdir(RF)
        Base.Filesystem.mkpath(RF)
    end
    return RF
end


#run_param_fix(0.12,20,60,1.0,1.0,1.4,true,"pfizer")
## now, running vaccine and herd immunity, focusing and not focusing in comorbidity, first  argument turns off vac
#= function run_param(b,h_i = 0,ic=1,fs=0.0,fm=0.0,strain2_trans=1.0,vaccinate = false,vac = "none",when_= 999,hl=1,hm=0.0,nsims=500)
    
    
    if vac == "pfizer"
        sdd = 21
        pd = [[14],[0;7]]
        inf=[[0.46],[0.6;0.92]]
        symp=[[0.57],[0.66;0.94]]
        sev= [[0.62],[0.80;0.92]]
        ag_v = 16
    elseif vac == "moderna"
        sdd = 28
        pd=[[14],[0;14]]
        inf=[[0.61],[0.61;0.935]]
        symp=[[0.921],[0.921;0.941]]
        sev=[[0.921],[0.921;1.0]]
        ag_v = 18
    elseif vac == "vac1"
        sdd = 28
        pd=[[14],[0]]
        inf=[[0.50],[0.7]]
        symp=[[0.75],[0.8]]
        sev=[[0.75],[0.8]]
        ag_v = 18
    else
        sdd = 21
        pd=[[14],[0;14]]
        inf=[[0.61],[0.61;0.935]]
        symp=[[0.921],[0.921;0.941]]
        sev=[[0.921],[0.921;1.0]]
        ag_v = 18
    end

    
    #b = bd[h_i]
    #ic = init_con[h_i]
    @everywhere ip = cv.ModelParameters(??=$b,fsevere = $fs,fmild = $fm,vaccinating = $vaccinate,vac_efficacy_inf = $inf,
    vac_efficacy_symp=$symp, vac_efficacy_sev = $sev,
    herd = $(h_i),start_several_inf=true,initialinf=$ic,
    ins_sec_strain = true,sec_dose_delay = $sdd,vac_period = $sdd,days_to_protection=$pd,
    sec_strain_trans=$strain2_trans,
    min_age_vac=$ag_v, time_change = $when_, how_long = $hl, how_much = $hm)

    folder = create_folder(ip,vac)

    #println("$v_e $(ip.vaccine_ef)")
    run(ip,nsims,folder)
   
end
 =#

#run_param_fix(0.12,20,60,1.0,1.0,1.4,true,"pfizer")
## 
function run_param_scen(b,h_i = 0,ic=1,fs=0.0,fm=0.0,strain2_trans=1.5,vac = "none",red = 0.0,index = 0,tr=999,when_= 999,dosis=3,ta = 999,nsims=500)
    
    
    if vac == "pfizer"
        sdd = 21
        pd = [[14],[0;7]]
        inf=[[0.46],[0.6;0.92]]
        symp=[[0.57],[0.66;0.94]]
        sev= [[0.62],[0.80;0.92]]
        ag_v = 16
    elseif vac == "moderna"
        sdd = 28
        pd=[[14],[0;14]]
        inf=[[0.61],[0.61;0.935]]
        symp=[[0.921],[0.921;0.941]]
        sev=[[0.921],[0.921;1.0]]
        ag_v = 18
    elseif vac == "vac1"
        sdd = 28
        pd=[[14],[0]]
        inf=[[0.50],[0.7]]
        symp=[[0.75],[0.8]]
        sev=[[0.75],[0.8]]
        ag_v = 18
    else
        sdd = 21
        pd=[[14],[0;14]]
        inf=[[0.61],[0.61;0.935]]
        symp=[[0.921],[0.921;0.941]]
        sev=[[0.921],[0.921;1.0]]
        ag_v = 18
    end

    
    #b = bd[h_i]
    #ic = init_con[h_i]
    @everywhere ip = cv.ModelParameters(??=$b,fsevere = $fs,fmild = $fm,vaccinating = true,vac_efficacy_inf = $inf,
    vac_efficacy_symp=$symp, vac_efficacy_sev = $sev,
    herd = $(h_i),start_several_inf=true,initialinf3=$ic,
    ins_sec_strain = true,sec_dose_delay = $sdd,vac_period = $sdd,days_to_protection=$pd,
    third_strain_trans=$strain2_trans, strain_ef_red3 = $red,
    min_age_vac=$ag_v, time_back_to_normal = $when_,relaxing_time=$tr,status_relax = $dosis, relax_after = $ta,file_index = $index)

    folder = create_folder(ip,vac)

    #println("$v_e $(ip.vaccine_ef)")
    run(ip,nsims,folder)
   
end


function run_param_scen_cal(b,h_i = 0,ic=1,fs=0.0,fm=0.0,strain2_trans=1.5,vaccinate = false,vac = "none",red = 0.0,index = 0,when_= 999,hl = 1,hm = 0.0,nsims=500)
    
    
    if vac == "pfizer"
        sdd = 21
        pd = [[14],[0;7]]
        inf=[[0.46],[0.6;0.92]]
        symp=[[0.57],[0.66;0.94]]
        sev= [[0.62],[0.80;0.92]]
        ag_v = 16
    elseif vac == "moderna"
        sdd = 28
        pd=[[14],[0;14]]
        inf=[[0.61],[0.61;0.935]]
        symp=[[0.921],[0.921;0.941]]
        sev=[[0.921],[0.921;1.0]]
        ag_v = 18
    elseif vac == "vac1"
        sdd = 28
        pd=[[14],[0]]
        inf=[[0.50],[0.7]]
        symp=[[0.75],[0.8]]
        sev=[[0.75],[0.8]]
        ag_v = 18
    else
        sdd = 21
        pd=[[14],[0;14]]
        inf=[[0.61],[0.61;0.935]]
        symp=[[0.921],[0.921;0.941]]
        sev=[[0.921],[0.921;1.0]]
        ag_v = 18
    end

    
    #b = bd[h_i]
    #ic = init_con[h_i]
    @everywhere ip = cv.ModelParameters(??=$b,fsevere = $fs,fmild = $fm,vaccinating = $vaccinate,vac_efficacy_inf = $inf,
    vac_efficacy_symp=$symp, vac_efficacy_sev = $sev,
    herd = $(h_i),start_several_inf=true,initialinf3=$ic,
    ins_sec_strain = true,sec_dose_delay = $sdd,vac_period = $sdd,days_to_protection=$pd,
    third_strain_trans=$strain2_trans, strain_ef_red3 = $red,
    min_age_vac=$ag_v, time_back_to_normal = 307,how_long = $hl,how_much = $hm,time_change = $when_,status_relax = 1, relax_after = 14,file_index = $index)

    folder = create_folder(ip,vac)

    #println("$v_e $(ip.vaccine_ef)")
    run(ip,nsims,folder)
   
end





## now, running vaccine and herd immunity, focusing and not focusing in comorbidity, first  argument turns off vac
function run_calibration(beta = 0.0345,herd_im_v = 0,fs = 0.0,insert_sec=false,strain2_trans=1.0,nsims=1000)
    init_con = Dict(5=>3, 10=>4, 20=>6, 30=>9)
    ic = init_con[herd_im_v]
    time_s = insert_sec ? 100 : 30
    @everywhere ip = cv.ModelParameters(??=$beta,herd = $herd_im_v,modeltime = $(time_s),initialinf = $ic,ins_sec_strain = $insert_sec,
    sec_strain_trans=$strain2_trans,fsevere = $fs,fmild=$fs,start_several_inf=true)
    folder = create_folder(ip)

    #println("$v_e $(ip.vaccine_ef)")
    run(ip,nsims,folder)

    R0 = readdlm(string(folder,"/R01.dat"),header=false)[:,1]
    m = mean(R0)
    sd = std(R0)
    R02 = readdlm(string(folder,"/R02.dat"),header=false)[:,1]
    m2 = mean(R02)
    sd2 = std(R02)
    println("mean R01: $(m) with std1: $(sd) mean R02: $(m2) with std2: $(sd2)")
end