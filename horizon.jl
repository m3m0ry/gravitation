using Requests
import Requests: get, post, put, delete, options
using CSV
using WriteVTK



query = Dict(
	"batch" => "l",
	"COMMAND" => "499",
	"CENTER" => "500@10",
	"MAKE_EPHEM" => "YES",
	"TABLE_TYPE" => "VECTORS",
	"START_TIME" => "2017-02-15",
	"STOP_TIME" => "2018-02-15",
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
print(str)

m = match(r"\$\$SOE\n(?<csv_data>[\s-\S]*)\n\$\$EOE", str)
data = m[:csv_data]
data = replace(data, ",\n", "\n")
df = CSV.read(IOBuffer(data); types=[Float64, String, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64], header=["date1", "date2", "X", "Y", "Z", "VX", "VY", "VZ", "LT", "RG", "RR"], nullable=false)

cells = [MeshCell(VTKCellTypes.VTK_VERTEX, [i]) for i = 1:1]
for i = 1:size(df)[1]
	outfile = vtk_grid(string("my_vtu_file",i), [df[:X][i] df[:Y][i] df[:Z][i]]', cells) do vtk
		vtk_cell_data(vtk, [1], "Mass")
	end
end


