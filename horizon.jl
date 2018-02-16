using Requests
import Requests: get, post, put, delete, options
using CSV



query = Dict(
	"batch" => "l",
	"COMMAND" => "499",
	"CENTER" => "500@10",
	"MAKE_EPHEM" => "YES",
	"TABLE_TYPE" => "VECTORS",
	"START_TIME" => "2018-02-15",
	"STOP_TIME" => "2018-03-17",
	"STEP_SIZE" => "1d",
	"OUT_UNITS" => "KM-S",
	"REF_PLANE" => "ECLIPTIC",
	"REF_SYSTEM" => "J2000",
	"VECT_CORR" => "NONE",
	"VEC_LABELS" => "YES",
	"VEC_DELTA_T" => "NO",
	"CSV_FORMAT" => "YES",
	"OBJ_DATA" => "NO",
	"VEC_TABLE" => "3")

url = "http://ssd.jpl.nasa.gov/horizons_batch.cgi"

response = get(url, query = query)
println(response)
str = readstring(response)

m = match(r"\$\$SOE\n(?<csv_data>[\s-\S]*)\n\$\$EOE", str)
data = m[:csv_data]
data = replace(data, ",\n", "\n")
df = CSV.read(IOBuffer(data); types=[Float64, String, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64], header=["date1", "date2", "X", "Y", "Z", "VX", "VY", "VZ", "Something", "Something", "Something"])
df


