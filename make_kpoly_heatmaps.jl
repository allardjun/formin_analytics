using CairoMakie


function compute_kpoly(kcap0, kdel0, rcap, Pocc, prvec0)
    kcap = kcap0.*(1 .- Pocc)
    kdel = kdel0.*prvec0
    kpoly = ( (kdel.+rcap)./(kdel.*kcap) .+ 1.0 ./kdel ).^(-1)
    return kpoly
end

function compute_kpolyratio(kcap0, kdel0, Pocc_ratio, prvec_ratio, rcap)

    Pocc_unhandfuffed = 0.9
    prvec_unhandfuffed = 1e-3
    kpoly_unhandcuffed = compute_kpoly(
        kcap0, kdel0, rcap, Pocc_unhandfuffed,prvec_unhandfuffed
        )
    kpoly_handcuffed = compute_kpoly(
        kcap0, kdel0, rcap, Pocc_ratio*Pocc_unhandfuffed, prvec_ratio*prvec_unhandfuffed
        )

    # return kpoly_unhandcuffed
    # return kpoly_handcuffed

    return kpoly_handcuffed ./ kpoly_unhandcuffed
end



function plot_kpoly_heatmaps(param_sets)
    Pocc_ratio_range = range(0.9, 1.1, length=20)
    prveczero_ratio_range = range(0.5, 2.0, length=20)
    
    # Create figure with proper spacing
    fig = Figure(size=(1200, 400))
    
    # Create heatmaps for each parameter set
    for (i, (kcap, kdel, rcap)) in enumerate(param_sets)
        ax = Axis(fig[1, i], 
                 xlabel="Pocc_ratio",
                 ylabel="prveczero_ratio",
                 title="kcap0=$(kcap), kdel0=$(kdel), rcap0=$(rcap)")
        
        z = [compute_kpolyratio(kcap, kdel, p1, p2, rcap) 
             for p1 in Pocc_ratio_range, p2 in prveczero_ratio_range]
            
        @show minimum(z), maximum(z)
        global_min = 1e-2
        global_max = 1e1

        hm = heatmap!(ax, Pocc_ratio_range, prveczero_ratio_range, z,
                      colormap=:viridis, colorscale=log,
                      colorrange=(global_min, global_max),
                    )
        # Add contour line at z = 1.0
        contour!(ax, Pocc_ratio_range, prveczero_ratio_range, z,
                levels=[1.0], color=:white, linewidth=2)

        # Add reference point at (1.0, 1.0)
        scatter!(ax, [1.0], [1.0], 
                color=:white,    # color of the marker
                markersize=15,   # size of the marker
                strokewidth=2,   # width of the marker border
                strokecolor=:white, # color of the marker border
                marker=:circle)  # marker shape
    end

    # Colorbar(fig[1, length(param_sets)+1], hm, vertical=false, flipaxis=false)


    # Adjust the layout to make subplots equal width
    # for i in 1:3
    #     colsize!(fig.layout, i, Relative(1/3))
    # end
    
    


    return fig
end

param_sets = [
    (10.0, 1.0, 0.1),
    (2.0, 20.0, 2.0),
    (3.0, 3.0, 1.0)
]

fig = plot_kpoly_heatmaps(param_sets)

display(fig)

if false
    save("kpoly_heatmaps.pdf", fig)
end