function pointcoords(geom::AbstractGeometry)
    @assert geotype(geom) == :Point
    [tuple(coordinates(geom)...)]
end

function multipointcoords(geom::AbstractGeometry)
    @assert geotype(geom) == :MultiPoint
    coords = coordinates(geom)
    first.(coords), last.(coords)
end

function linestringcoords(geom::AbstractGeometry)
    @assert geotype(geom) == :LineString
    coords = coordinates(geom)
    first.(coords), last.(coords)
end

function multilinestringcoords(geom::AbstractGeometry)
    @assert geotype(geom) == :MultiLineString
    x, y = Float64[], Float64[]
    for line in coordinates(geom)
        append!(x, first.(line)); push!(x, NaN)
        append!(y, last.(line)); push!(y, NaN)
    end
    x, y
end

function polygoncoords(geom::AbstractGeometry)
    @assert geotype(geom) == :Polygon
    ring = first(coordinates(geom)) # currently doesn't plot holes
    first.(ring), last.(ring)
end

function multipolygoncoords(geom::AbstractGeometry)
    @assert geotype(geom) == :MultiPolygon
    x, y = Float64[], Float64[]
    for poly in coordinates(geom)
        ring = first(coordinates(poly)) # currently doesn't plot holes
        append!(x, first.(ring)); push!(x, NaN)
        append!(y, last.(ring)); push!(y, NaN)
    end
    x, y
end

shapecoords(geom::AbstractPoint) = pointcoords(geom)
shapecoords(geom::AbstractMultiPoint) = multipointcoords(geom)
shapecoords(geom::AbstractLineString) = linestringcoords(geom)
shapecoords(geom::AbstractMultiLineString) = multilinestringcoords(geom)
shapecoords(geom::AbstractPolygon) = polygoncoords(geom)
shapecoords(geom::AbstractMultiPolygon) = multipolygoncoords(geom)

function shapecoords(geom::AbstractGeometry)
    gtype = geotype(geom)
    if gtype == :Point
        return pointcoords(geom)
    elseif gtype == :MultiPoint
        return multipointcoords(geom)
    elseif gtype == :LineString
        return linestringcoords(geom)
    elseif gtype == :MultiLineString
        return multilinestringcoords(geom)
    elseif gtype == :Polygon
        return polygoncoords(geom)
    elseif gtype == :MultiPolygon
        return multipolygoncoords(geom)
    else
        warn("unknown geometry type: $gtype")
    end
end

RecipesBase.@recipe function f(geom::AbstractPoint)
    if plotattributes[:plot_object].n == 0 
        aspect_ratio --> 1
        legend --> :false
    end
    seriestype --> :scatter
    shapecoords(geom)
end

RecipesBase.@recipe function f(geom::AbstractMultiPoint)
    if plotattributes[:plot_object].n == 0 
        aspect_ratio --> 1
        legend --> :false
    end
    seriestype --> :scatter
    shapecoords(geom)
end

RecipesBase.@recipe function f(geom::AbstractLineString)
    if plotattributes[:plot_object].n == 0 
        aspect_ratio --> 1
        legend --> :false
    end
    seriestype --> :path
    shapecoords(geom)
end

RecipesBase.@recipe function f(geom::AbstractMultiLineString)
    if plotattributes[:plot_object].n == 0 
        aspect_ratio --> 1
        legend --> :false
    end
    seriestype --> :path
    shapecoords(geom)
end

RecipesBase.@recipe function f(geom::AbstractPolygon)
    if plotattributes[:plot_object].n == 0 
        aspect_ratio --> 1
        legend --> :false
    end
    seriestype --> :shape
    shapecoords(geom)
end

RecipesBase.@recipe function f(geom::AbstractMultiPolygon)
    if plotattributes[:plot_object].n == 0 
        aspect_ratio --> 1
        legend --> :false
    end
    seriestype --> :shape
    shapecoords(geom)
end

RecipesBase.@recipe function f(geom::AbstractGeometry)
    if plotattributes[:plot_object].n == 0 
        aspect_ratio --> 1
        legend --> :false
    end
    gtype = geotype(geom)
    if gtype == :Point || gtype == :MultiPoint
        seriestype := :scatter
    elseif gtype == :LineString || gtype == :MultiLineString
        seriestype := :path
    elseif gtype == :Polygon || gtype == :MultiPolygon
        seriestype := :shape
    else
        @warn("unknown geometry type: $gtype")
    end
    shapecoords(geom)
end

RecipesBase.@recipe function f(geom::Vector{<:Union{Missing, AbstractGeometry}})
    if plotattributes[:plot_object].n == 0 
        aspect_ratio --> 1
        legend --> :false
    end
    for g in skipmissing(geom)
        @series begin
            gtype = geotype(g)
            if gtype == :Point || gtype == :MultiPoint
                seriestype := :scatter
            elseif gtype == :LineString || gtype == :MultiLineString
                seriestype := :path
            elseif gtype == :Polygon || gtype == :MultiPolygon
                seriestype := :shape
            else
                @warn("unknown geometry type: $gtype")
            end
            shapecoords(g)
        end
    end
end

RecipesBase.@recipe f(feature::AbstractFeature) = geometry(feature)
RecipesBase.@recipe f(features::Vector{<:AbstractFeature}) = geometry.(features)
RecipesBase.@recipe f(collection::AbstractFeatureCollection) = features(collection)
RecipesBase.@recipe f(collection::AbstractGeometryCollection) = geometries(collection)
