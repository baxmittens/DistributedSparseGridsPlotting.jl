using DistributedSparseGrids
using StaticArrays 
using DistributedSparseGridsPlotting
include(joinpath("../src/support","ndgrid.jl"))

function sparse_grid(N::Int,pointprops,nlevel=6,RT=Float64,CT=Float64)
	# define collocation point
	CPType = CollocationPoint{N,CT}
	# define hierarchical collocation point
	HCPType = HierarchicalCollocationPoint{N,CPType,RT}
	# init grid
	asg = init(AHSG{N,HCPType},pointprops)
	#set of all collocation points
	cpts = Set{HierarchicalCollocationPoint{N,CPType,RT}}(collect(asg))
	# fully refine grid nlevel-1 times
	for i = 1:nlevel-1
		union!(cpts,generate_next_level!(asg))
	end
	return asg
end

N = 6

pointprops = @SVector [1,1,1,1,1,1]
asg = sparse_grid(N, pointprops, 4, Vector{Float64}) 

#define function: input are the coordinates x::SVector{N,CT} and an unique id ID::String (e.g. "1_1_1_1")
fun1(x::SVector{N,Float64},ID::String) =  [(1.0-exp(-1.0*(abs(2.0 - (x[1]-1.0)^2.0 - (x[2]-1.0)^2.0) +0.01)))/(abs(2-(x[1]-1.0)^2.0-(x[2]-1.0)^2.0)+0.01), x[3:6]...]

# initialize weights
@time init_weights!(asg, fun1)

# adaptive refine
for i = 1:20
# call generate_next_level! with tol=1e-5 and maxlevels=20
	cpts = generate_next_level!(asg, 1e-5, 13)
	init_weights!(asg, collect(cpts), fun1)
end

# integration
asg = integrate_inplace_ops(asg, [1,2])

#using Combinatorics
#combs = collect(combinations(1:N,2))
#using CairoMakie
using GLMakie
#CairoMakie.activate!(type = "svg", px_per_unit=2.0, pt_per_unit=0.5)
GLMakie.activate!()

#import DistributedSparseGrids: coord, level, numlevels
f = Figure(size=(500,400));
ax = Axis3(f[1,1]);
scatter!(ax, asg, markersize=3)
surface!(ax, asg, 200, x->x[1])
f
#mw(i) = 8.0-foldl((x,y)->x+2.0/(y),1:i)
#x,y,c,masi = Float64[],Float64[],Int[],Float64[]
#for hcpt in asg 
#	push!(x, coord(hcpt,1))
#	push!(y, coord(hcpt,2))
#	push!(c, level(hcpt))
#	push!(masi, mw(level(hcpt)))
#end
#scatter!(ax, x, y, color=c, colormap = :BrBG_10, colorrange = (1, numlevels(asg)), markersize=masi)
#f
#save("figure.png", f, pdf_version="1.4", px_per_unit = 5.0)

