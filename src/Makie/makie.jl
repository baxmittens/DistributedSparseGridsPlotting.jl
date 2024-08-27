using CairoMakie
using GLMakie
using Makie

function Makie.scatter!(ax::Axis, sg::SG, markersize=10) where {CT,CP<:AbstractCollocationPoint{2,CT},HCP<:AbstractHierarchicalCollocationPoint{2,CP},SG<:AbstractHierarchicalSparseGrid{2,HCP}}
	colors = cols = distinguishable_colors(numlevels(sg)+1, [RGB(1,1,1)])[2:end]
	nlevel = numlevels(sg)
	#traces = Vector{GenericTrace}(undef,nlevel)
	xvals = Vector{Vector{CT}}(undef,nlevel)
	yvals = Vector{Vector{CT}}(undef,nlevel)
	zvals = Vector{Vector{CT}}(undef,nlevel)
	#text = Vector{Vector{String}}(undef,nlevel)
	clr = Vector{Vector{RGB{N0f8}}}(undef,nlevel)
	for l = 1:nlevel
		xvals[l] = Vector{CT}()
		yvals[l] = Vector{CT}()
		zvals[l] = Vector{CT}()
		clr[l] = Vector{RGB{N0f8}}()
		#text[l] = Vector{String}()
	end
	for hcpt in sg
		l = level(hcpt)
		push!(xvals[l],coord(hcpt,1))
		push!(yvals[l],coord(hcpt,2))
		push!(zvals[l],level(hcpt))
		#push!(zvals,interpolate(sg, [xvals[end], yvals[end]]))
		#push!(text[l],string(pt_idx(hcpt))*"^"*string(i_multi(hcpt)))
		push!(clr[l],colors[level(hcpt)])
	end
	for i = 1:nlevel
		mw = markersize-foldl((x,y)->x+2.0/(y),1:i)
		Makie.scatter!(ax, xvals[i], yvals[i], markersize=mw, color=clr[i])
		#traces[i] = p = PlotlyJS.scatter(x=xvals[i], y=yvals[i], text=text[i], marker_color=clr[i], mode="markers",marker_size=mw,textposition="bottom center",name="level $i")
	end
	return nothing
end

function Makie.scatter!(ax::Axis3, sg::SG; markersize=5, z_offset=0.0) where {CT,CP<:AbstractCollocationPoint{2,CT},HCP<:AbstractHierarchicalCollocationPoint{2,CP},SG<:AbstractHierarchicalSparseGrid{2,HCP}}
	colors = cols = distinguishable_colors(numlevels(sg)+1, [RGB(1,1,1)])[2:end]
	#if color_order
#		colors = cols = colormap("Reds", N*maxp+1)
	#else	
	#end
	xvals = Vector{CT}()
	yvals = Vector{CT}()
	zvals = Vector{CT}()
	text = Vector{String}()
	clr = Vector{RGB{N0f8}}()
	for hcpt in sg
		push!(xvals,coord(hcpt,1))
		push!(yvals,coord(hcpt,2))
		push!(zvals,zero(CT)+z_offset*one(CT))
		push!(text,string(pt_idx(hcpt))*"^"*string(i_multi(hcpt)))
		#if !color_order
			push!(clr,colors[level(hcpt)])
		#else
		#
		#	N = length(children(hcpt))
		#	ord = 0
		#	for d = 1:N
		#		ord += polyorder_v1(hcpt, d, maxp)
		#	end
		#	push!(clr,colors[ord+1])
		#end
	end
	p = Makie.scatter!(ax, xvals, yvals, zvals, color=clr, markersize=markersize)
	return p
end


function GLMakie.surface!(ax, asg::SG, npts = 20, postfun=x->x; kwargs...) where {CT,CP<:AbstractCollocationPoint{2,CT},HCP<:AbstractHierarchicalCollocationPoint{2,CP},SG<:AbstractHierarchicalSparseGrid{2,HCP}}
	xs = LinRange(-1.0, 1.0, npts)
	ys = LinRange(-1.0, 1.0, npts)
	rcp = first(asg)
	tmp = zero(scaling_weight(rcp))
	zs = [begin;
			interpolate!(tmp, asg, [x, y])
			postfun(tmp) 
		end
		for x in xs, y in ys]
	return GLMakie.surface!(ax, xs, ys, zs)
end


#function surface_inplace_ops(asg::SG, npts = 20, postfun=x->x; kwargs...) where {CT,CP<:AbstractCollocationPoint{2,CT},HCP<:AbstractHierarchicalCollocationPoint{2,CP},SG<:AbstractHierarchicalSparseGrid{2,HCP}}
#	pts = range(-1.,stop=1.,length=npts)
#	xpts, ypts = ndgrid(pts,pts)
#	zz = similar(xpts)
#	rcp = first(asg)
#	for i = 1:npts, j=1:npts
#		tmp = zero(scaling_weight(rcp))
#		interpolate!(tmp, asg, [xpts[i,j], ypts[i,j]])
#		zz[i,j] = postfun(tmp)
#	end
#	p = PlotlyJS.surface(x=xpts,y=ypts,z=zz; kwargs...)
#end