using Makie, CairoMakie
using Makie: MakieLayout
using AlgebraOfGraphics

set_aog_theme!()

for ts in [1, 5]
    depth = 5

    fig = Figure(backgroundcolor="#f8f8ff", resolution=(1200, 1200))
    hastime = ts > 1
    xlabelcolor = hastime ? :black : :transparent
    ax = Axis(fig[1, 1]; spinewidth=0, aspect=DataAspect(), backgroundcolor="#f8f8ff",
        xlabel="Time", ylabel="Depth", xlabelsize=30, ylabelsize=30, xlabelcolor)
    hidedecorations!(ax, label=false)
    xlims!(ax, (0.5, 6))
    ylims!(ax, (0.5, nothing))

    pts = [Point2f(i, j) for i in 1:ts for j in 1:depth]

    position = Observable((1, 1))
    colormap = collect(cgrad(:sienna, 5, categorical=true, rev=true))

    arc_data = map(1:depth) do yin
        lift(position) do (x, yout)
            offset = 3
            center = Point2f(x - offset, (yin + yout) / 2)
            radius = sqrt(abs2(offset) + abs2((yout - yin) / 2))
            stop = acos(offset/radius)
            start = -stop
            visible = yout > yin
            return (; center, radius, start, stop, visible, color=colormap[yout])
        end
    end

    for d in arc_data
        arc!(ax, @lift($d.center), @lift($d.radius), @lift($d.start), @lift($d.stop);
            visible=@lift($d.visible), color=@lift($d.color), linewidth=3)
    end

    segment_data = lift(position) do (x, yout)
        coords = map(1:depth) do yin
            pt0 = Point2f(x-1, yin)
            pt1 = Point2f(x, yout)
            return pt0, pt1
        end
        visible = x > 1
        color = colormap[yout]
        return (; coords, visible, color)
    end

    linesegments!(ax, @lift($segment_data.coords),
        visible=@lift($segment_data.visible), color=@lift($segment_data.color), linewidth=3)

    scatter!(ax, pts, color=[colormap[j] for i in 1:ts for j in 1:depth], markersize=30)

    filename = hastime ? "connectivity_time" : "connectivity" 
    save(joinpath(@__DIR__, "..", "assets", "$filename.png"), fig)
    itr = [(i, j) for i in 1:ts for j in 1:depth]

    asset_path = joinpath(@__DIR__, "..", "assets")

    record(fig, joinpath(asset_path, "$filename.gif"), itr, framerate=2) do pos
        position[] = pos
    end
end