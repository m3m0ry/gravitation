using Requests
import Requests: get, post, put, delete, options
using CSV
using DataFrames
using WriteVTK

query = Dict{String, String}(
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

function horizon_data(bodies::Dict{String, String}; url="http://ssd.jpl.nasa.gov/horizons_batch.cgi")
	for (i, k) in enumerate(keys(bodies))
		#download data from horizons
		query["COMMAND"] = k
		response = get(url, query = query)
		println(response)
		str = readstring(response)

		#filter out data
		m = match(r"\$\$SOE\n(?<csv_data>[\s-\S]*)\n\$\$EOE", str)
		data = m[:csv_data]
		data = replace(data, ",\n", "\n")
		df = CSV.read(IOBuffer(data); types=Dict(2=>String), header=["date1", "date2", "X", "Y", "Z", "VX", "VY", "VZ", "LT", "RG", "RR"], nullable=false)
		CSV.write("$(bodies[k]).csv", df)
	end
end

function csv_to_vtu(bodies::Dict{String,String}; file_name="my_vtu_file")
	vectors = Array{DataFrame}(bodies.count)

	for (i, k) in enumerate(keys(bodies))
		vectors[i] = CSV.read("$(bodies[k]).csv", nullable=false)
	end

	cells = WriteVTK.MeshCell[MeshCell(VTKCellTypes.VTK_VERTEX, [i]) for i = 1:length(vectors)]
	for i = 1:size(vectors[1])[1]
		points = Array{Float64}(3, length(vectors))
		for j = 1:length(vectors)
			points[1,j] = vectors[j][:X][i]
			points[2,j] = vectors[j][:Y][i]
			points[3,j] = vectors[j][:Z][i]
		end
		outfile = vtk_grid(string(file_name,i), points, cells) do vtk
			vtk_cell_data(vtk, [1 for i = 1:length(vectors)], "Mass")
		end
	end
end


major_bodies = Dict{String,String}(
	"10" => "Sun",
	"199" => "Mercury",
	"299" => "Venus",
	#"301" => "Moon",
	"399" => "Earth",
	#"401" => "Phobos",
	#"402" => "Deimos",
	"499" => "Mars",
	"599" => "Jupiter",
	"699" => "Saturn",
	"799" => "Uranus",
	"800" => "Neptune")

horizon_data(major_bodies)
csv_to_vtu(major_bodies, file_name="major_bodies")
