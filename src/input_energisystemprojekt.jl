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
        :Wind            180.0          280.0           90.0
        :PV              460.0          75.0            60.0
        :Gas             myinf          myinf           myinf
        :Hydro           0.0            14.0            0.0
        :Batteries       myinf          myinf           myinf
        :Transmission    myinf          myinf           myinf
        :Nuclear         myinf          myinf           myinf
        ]

maxcap = AxisArray(maxcaptable[:,2:end]'.*1000, REGION, PLANT) # MW

investmentCostTable = [
        # PLANT          euro/kW  
        :Wind            1100.0
        :PV              600.0
        :Gas             550.0
        :Hydro           0.0
        :Batteries       150.0
        :Transmission    2500.0
        :Nuclear         7700.0
        ]

investmentCost = AxisArray(Float64.(investmentCostTable[:,2]), PLANT)

runningCostTable = [
        # PLANT          Running cost [euro/MWh_elec]  
        :Wind            0.1
        :PV              0.1
        :Gas             2.0
        :Hydro           0.1
        :Batteries       0.1
        :Transmission    0.0
        :Nuclear         4.0
        ]

runningCost = AxisArray(Float64.(runningCostTable[:,2]), PLANT)

fuelCostTable = [
        # PLANT          Fuel cost [euro/MWh_fuel]  
        :Wind            0.0
        :PV              0.0
        :Gas             22.0
        :Hydro           0.0
        :Batteries       0.0
        :Transmission    0.0
        :Nuclear         3.2
        ]

fuelCost = AxisArray(Float64.(fuelCostTable[:,2]), PLANT)

lifetimeTable = [
        # PLANT          Lifetime (years)  
        :Wind            25.0
        :PV              25.0
        :Gas             30.0
        :Hydro           80.0
        :Batteries       10.0
        :Transmission    50.0
        :Nuclear         50.0
        ]

lifetime = AxisArray(Float64.(lifetimeTable[:,2]), PLANT)

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

efficiency = AxisArray(Float64.(efficiencyTable[:,2]), PLANT)

emissionFactorTable = [
        # PLANT          Emission factor [ton CO2/MWh_fuel]  
        :Wind            0.0
        :PV              0.0
        :Gas             0.202
        :Hydro           0.0
        :Batteries       0.0
        :Transmission    0.0
        :Nuclear         0.0
        ]

emissionFactor = AxisArray(Float64.(emissionFactorTable[:,2]), PLANT)

variableCost = AxisArray(Float64.(runningCost .+ fuelCost ./ efficiency), PLANT)

discountrate=0.05


      return (; REGION,
                PLANT,
                HOUR,
                numregions,
                load,
                maxcap,
                investmentCost,
                lifetime,
                emissionFactor,
                variableCost,
                discountrate
                )

end # read_input
