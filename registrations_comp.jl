#! /usr/bin/env julia
using DataFrames

root = "/Users/davidc/Documents/Big_Data/Summit registrations"

#Read current report:
current = joinpath(root, "report_aug_15.csv")
data2015 = joinpath(root, "Summit_regs_2015.csv")
data2014 = joinpath(root, "Summit_regs_2014.csv")
data2013 = joinpath(root, "Summit_regs_2013.csv")

report_2016 = readtable(current)
report_2015 = readtable(data2015)
report_2014 = readtable(data2014)
report_2013 = readtable(data2013)

#Output vector
v = Vector()

summit_dates = (Date("2016-10-26"), Date("2015-09-29"), Date("2014-09-24"), Date("2013-11-27"))

#Counter for loop
w = 0
for current_report in [report_2016, report_2015, report_2014, report_2013]
  current_report[:Order_Date_conv] = Date(current_report[:Order_Date])
  w = w + 1
  current_report[:Days_to_summit] = map((x) -> Dates.value(summit_dates[w] - x), current_report[:Order_Date_conv])
  sort!(current_report,cols=:Days_to_summit, rev=true)

  current_report[:Summit_guest] = 0
  current_report[:Summit_paid] = 0
  current_report[:Summit_ws] = 0
  current_report[:Total_paid] = 0

  for r in eachrow(current_report)
    if r[:Ticket_Type] == "Summit Guest"
      r[:Summit_guest] = r[:Quantity]
    #elseif r[:Ticket_Type] == "Workshop"
    elseif (contains(r[:Ticket_Type], "Workshop")) | (contains(r[:Ticket_Type], "SDN")) | (contains(r[:Ticket_Type], "OpenStack"))
      r[:Summit_ws] = r[:Quantity]
    else
      r[:Summit_paid] = r[:Quantity]
    end
    r[:Total_paid] = r[:Summit_ws] + r[:Summit_paid]
  end

  current_summed = by(current_report, :Days_to_summit, d -> DataFrame(WS = sum(d[:Summit_ws]), Guest = sum(d[:Summit_guest]), Paid = sum(d[:Summit_paid]), Total_paid = sum(d[:Total_paid]) ))

  for a in [:WS, :Paid, :Guest, :Total_paid]
    x = 0
    for r in eachrow(current_summed)
      x = x + r[a]
      r[a] = x
    end
  end

  push!(v, current_summed)
end

write_js(joinpath(root,"test2016.js"), v[1], varname="regs2016", append=false)
write_js(joinpath(root,"test2016.js"), v[2], varname="regs2015", append=true)
write_js(joinpath(root,"test2016.js"), v[3], varname="regs2014", append=true)
write_js(joinpath(root,"test2016.js"), v[4], varname="regs2013", append=true)
