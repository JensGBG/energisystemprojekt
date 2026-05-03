# I den här filen kan ni stoppa all inputdata. 
# Läs in datan ni fått som ligger på Canvas genom att använda paketen CSV och DataFrames

using CSV, DataFrames

function read_input()
println("\nReading Input Data...")
folder = dirname(@__FILE__)

#Sets
REGION = [:DE, :SE, :DK]
PLANT = [:Wind, :PV, :Gas, :Hydro, :Batteries, :Transmission, :Nuclear]
HOUR = 1:8760

#Parameters
numregions = length(REGION)
numhours = length(HOUR)

timeseries = CSV.read("$folder\\TimeSeries.csv", DataFrame)
wind_cf = AxisArray(ones(numregions, numhours), REGION, HOUR)
load = AxisArray(zeros(numregions, numhours), REGION, HOUR)
 
    for r in REGION
        wind_cf[r, :]=timeseries[:, "Wind_"*"$r"]                                                        # 0-1, share of installed cap
        load[r, :]=timeseries[:, "Load_"*"$r"]                                                           # [MWh]
    end

myinf = 1e8
maxcaptable = [                                                             # GW
        # PLANT           DE             SE              DK       
        :Wind            180            280             90
        :PV              460            75              60
        :Gas             myinf          myinf           myinf
        :Hydro           0              14              0
        :Batteries       myinf          myinf           myinf
        :Transmission    myinf          myinf           myinf
        :Nuclear         myinf          myinf           myinf
        ]

maxcap = AxisArray(maxcaptable[:,2:end]'.*1000, REGION, PLANT) # MW

investmentCostTable = [
        # PLANT          euro/kW  
        :Wind            1100
        :PV              600
        :Gas             550
        :Hydro           0
        :Batteries       150
        :Transmission    2500
        :Nuclear         7700
        ]

investmentCost = AxisArray(investmentCostTable[:,2], PLANT)

runningCostTable = [
        # PLANT          Running cost [euro/MWh_elec]  
        :Wind            0.1
        :PV              0.1
        :Gas             2
        :Hydro           0.1
        :Batteries       0.1
        :Transmission    0
        :Nuclear         4
        ]

runningCost = AxisArray(runningCostTable[:,2], PLANT)

fuelCostTable = [
        # PLANT          Fuel cost [euro/MWh_fuel]  
        :Wind            0
        :PV              0
        :Gas             22
        :Hydro           0
        :Batteries       0
        :Transmission    0
        :Nuclear         3.2
        ]

fuelCost = AxisArray(fuelCostTable[:,2], PLANT)

lifetimeTable = [
        # PLANT          Lifetime (years)  
        :Wind            25
        :PV              25
        :Gas             30
        :Hydro           80
        :Batteries       10
        :Transmission    50
        :Nuclear         50
        ]

lifetime = AxisArray(lifetimeTable[:,2], PLANT)

efficiencyTable = [
        # PLANT          Efficiency
        :Wind            1.0
        :PV              1.0
        :Gas             0.4
        :Hydro           1.0
        :Batteries       0.9
        :Transmission    0.98
        :Nuclear         0.4
        ]

efficiency = AxisArray(efficiencyTable[:,2], PLANT)

emissionFactorTable = [
        # PLANT          Emission factor [ton CO2/MWh_fuel]  
        :Wind            0
        :PV              0
        :Gas             0.202
        :Hydro           0
        :Batteries       0
        :Transmission    0
        :Nuclear         0
        ]

emissionFactor = AxisArray(emissionFactorTable[:,2], PLANT)

discountrate=0.05


      return (; REGION,
                PLANT,
                HOUR,
                numregions,
                load,
                maxcap,
                investmentCost,
                lifetime,
                runningCost,
                fuelCost,
                efficiency,
                emissionFactor)

end # read_input
