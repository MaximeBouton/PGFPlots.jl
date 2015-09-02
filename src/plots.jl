module Plots

export Plot, Histogram, Linear, Linear3, ErrorBars, Image, Contour, Scatter, Quiver, Node, Circle, Ellipse

using ..ColorMaps
using Compat

typealias RealRange @compat Tuple{Real,Real}

include("ndgrid.jl")

abstract Plot

type Histogram <: Plot
    data::AbstractArray{Real,1}
    bins::Integer
    density::Bool
    cumulative::Bool
    style::String
    Histogram(data; bins=20, density=false, cumulative=false, style="fill=blue!10") = new(data, bins, density, cumulative, style)
end

type Contour <: Plot
    data::AbstractArray{Real,2} # 3 x n matrix
    cols::Integer
    rows::Integer
    style
    number
    levels
    Contour(data, cols, rows; style=nothing, number=nothing, levels=nothing) = new(data, cols, rows, style, number, levels)
    function Contour(f::Function, xrange::RealRange, yrange::RealRange; style=nothing, number=nothing, levels=nothing)
        x = linspace(xrange[1], xrange[2], 40)
        y = linspace(yrange[1], yrange[2], 40)
        (X, Y) = meshgrid(x, y)
        A = map(f, X, Y)
        A = [X[:]'; Y[:]'; A[:]']
        new(A, length(x), length(y), style, number, levels)
    end
end

type Linear <: Plot
    data::AbstractArray{Real,2}
    mark
    style
    legendentry
    onlyMarks
    Linear{T<:Real}(data::AbstractArray{T,2}; mark=nothing, style=nothing, legendentry=nothing, onlyMarks=nothing) = new(data, mark, style, legendentry, onlyMarks)
end

type Linear3 <: Plot
    data::AbstractArray{Real,2}
    mark
    style
    legendentry
    onlyMarks
    Linear3{T<:Real}(data::AbstractArray{T,2}; mark=nothing, style=nothing, legendentry=nothing, onlyMarks=nothing) = new(data, mark, style, legendentry, onlyMarks)
end

type Scatter <: Plot
    data::AbstractArray{Any,2}
    mark
    style
    legendentry
    onlyMarks
	scatterClasses

	function Scatter{T<:Any}(data::AbstractArray{T,2}; mark=nothing, style=nothing, onlyMarks=true, legendentry=nothing, scatterClasses=nothing)
		if size(data,1) == 2
			return Linear(data, mark=mark, style=style, onlyMarks=onlyMarks, legendentry=legendentry)
		else
			return new(data, mark, style, legendentry, onlyMarks, scatterClasses)
		end
	end
end

type ErrorBars <: Plot
    data::AbstractArray{Real,2}
    mark
    style
    legendentry
    ErrorBars{T<:Real}(data::AbstractArray{T,2}; mark=nothing, style=nothing, legendentry=nothing) = new(data, mark, style, legendentry)
end

type Quiver <: Plot
    data::Matrix{Real}
    style
    legendentry
    Quiver{T<:Real}(data::Matrix{T}; style=nothing, legendentry=nothing) = new(data, style, legendentry)
end

type Node <: Plot
    data
    style
    x
    y
    Node(data, x, y; style=nothing) = new(data, style, x, y)
end

type Circle <: Plot
	xc
	yc
	radius
	Circle(xc=0,yc=0,radius=1) = new(xc,yc,radius)
end

type Ellipse <: Plot
	xc
	yc
	xradius
	yradius
	Ellipse(xc=0,yc=0,xradius=1,yradius=1) = new(xc,yc,xradius,yradius)
end

function Quiver(f::Function, xrange::RealRange, yrange::RealRange; style=nothing, legendentry=nothing, samples=15, normalize=true)
    x = linspace(xrange[1], xrange[2], samples)
    y = linspace(yrange[1], yrange[2], samples)
    (X, Y) = meshgrid(x, y)
    n = length(X)
    U = zeros(n)
    V = zeros(n)
    for i = 1:n
        (U[i], V[i]) = f(X[i], Y[i])
    end
    if normalize
        r = max(maximum(U),maximum(V))
        r /= min(minimum(diff(x)),minimum(diff(y)))
        U /= r
        V /= r
    end
    Quiver(X[:], Y[:], U, V, style=style, legendentry=legendentry)
end

Quiver{A<:Real,B<:Real,C<:Real,D<:Real}(x::Vector{A}, y::Vector{B}, u::Vector{C}, v::Vector{D}; style=nothing, legendentry=nothing) = Quiver([x y u v]', style=style, legendentry=legendentry)

Linear{A<:Real, B<:Real}(x::AbstractArray{A,1}, y::AbstractArray{B,1}; mark=nothing, style=nothing, legendentry=nothing, onlyMarks=nothing) = Linear([x y]', mark=mark, style=style, legendentry=legendentry, onlyMarks=onlyMarks)
Linear{A<:Real}(data::AbstractArray{A,1}; mark=nothing, style=nothing, legendentry=nothing, onlyMarks=nothing) = Linear([1:length(data)], data, mark=mark, style=style, legendentry=legendentry, onlyMarks=onlyMarks)


Linear3{A<:Real, B<:Real, C<:Real}(x::AbstractVector{A}, y::AbstractVector{B}, z::AbstractVector{C}; mark=nothing, style=nothing, legendentry=nothing, onlyMarks=nothing) = Linear3([x y z]', mark=mark, style=style, legendentry=legendentry, onlyMarks=onlyMarks)

ErrorBars{A<:Real, B<:Real, C<:Real, D<:Real, E<:Real, F<:Real}(x::AbstractArray{A,1}, y::AbstractArray{B,1}, xplus::AbstractArray{C,1}, yplus::AbstractArray{D,1},
                                                                xminus::AbstractArray{E,1}, yminus::AbstractArray{F,1}; mark=nothing, style=nothing, legendentry=nothing) = ErrorBars([x y xplus yplus xminus yminus]',mark=mark, style=style, legendentry=legendentry)
ErrorBars{A<:Real, B<:Real, C<:Real, D<:Real}(x::AbstractArray{A,1}, y::AbstractArray{B,1}, yplus::AbstractArray{C,1},yminus::AbstractArray{D,1}; mark=nothing, style=nothing, legendentry=nothing, onlyMarks=nothing) = ErrorBars([x y zeros(length(x)) yplus zeros(length(x)) yminus]', mark=mark, style=style, legendentry=legendentry)
ErrorBars{A<:Real, B<:Real, C<:Real}(x::AbstractArray{A,1}, y::AbstractArray{B,1}, yplusminus::AbstractArray{C,1}; mark=nothing, style=nothing, legendentry=nothing) = ErrorBars([x y zeros(length(x)) yplusminus zeros(length(x)) yplusminus]', mark=mark, style=style, legendentry=legendentry)

Scatter{A<:Real, B<:Real}(x::AbstractArray{A,1}, y::AbstractArray{B,1}; mark=nothing, style=nothing, legendentry=nothing, scatterClasses=nothing) = Scatter([x y]', mark=mark, style=style, legendentry=nothing, scatterClasses=scatterClasses)
Scatter{A<:Real, B<:Real, C<:Any}(x::AbstractArray{A,1}, y::AbstractArray{B,1}, f::AbstractArray{C,1}; mark=nothing, style=nothing, legendentry=nothing, scatterClasses=nothing) = Scatter([x y f]', mark=mark, style=style, legendentry=nothing, scatterClasses=scatterClasses)
Scatter{A<:Real, B<:Real}(x::A, y::B; mark=nothing, style=nothing, legendentry=nothing) = Scatter([x y]', mark=mark, style=style, legendentry=nothing)
Scatter{A<:Real, B<:Real}(x::A, y::B, f; mark=nothing, style=nothing, legendentry=nothing, scatterClasses=nothing) = Scatter([x y f]', mark=mark, style=style, legendentry=nothing, scatterClasses=scatterClasses)

global _imgid = 1

type Image <: Plot
    filename::String
    xmin::Real
    xmax::Real
    ymin::Real
    ymax::Real
    zmin::Real
    zmax::Real
    colorbar::Bool
    colormap::ColorMaps.ColorMap
    function Image{T <: Real}(A::Matrix{T}, xrange::RealRange, yrange::RealRange; filename=nothing, colorbar=true, colormap=ColorMaps.Gray(), zmin=nothing, zmax=nothing)
        global _imgid
        if filename == nothing
            id=myid()*10000000000000+_imgid
            filename = "tmp_$(id).png"
            _imgid += 1
        end
        if zmin == nothing
            zmin = minimum(A)
        end
        if zmax == nothing
            zmax = maximum(A)
        end
        if zmin == zmax
            zmin -= 1.
            zmax += 1.
        end
        A = A .- zmin
        A = A ./ (zmax - zmin)
        if !isa(colormap, ColorMaps.ColorMap)
            write(ColorMaps.RGBArray(colormap), A, filename)
        end
        write(colormap, A, filename)
        new(filename, xrange[1], xrange[2], yrange[1], yrange[2], zmin, zmax, colorbar, colormap)
    end
    function Image(f::Function, xrange::RealRange, yrange::RealRange; filename=nothing, colorbar=true, colormap=ColorMaps.Gray(), zmin=nothing, zmax=nothing, xbins=100, ybins=100)
        x = linspace(xrange[1], xrange[2], xbins)
        y = linspace(yrange[1], yrange[2], ybins)
        (X, Y) = meshgrid(x, y)
        A = map(f, X, Y)
        A = flipud(A)
        Image(A, xrange, yrange, filename=filename, colorbar=colorbar, colormap=colormap, zmin=zmin, zmax=zmax)
    end
end

end # end plot module
