# Lineage_tracking
Code for QPI-based lineage tracking.

To accompany:
Jingzhou Zhang, Justin Griffin, Koushik Roy, Alexander Hoffmann, and Thomas A Zangle, “Tracking of Lineage Mass via Quantitative Phase Imaging and Confinement in Low Refractive Index Microwells,” bioRxiv, doi: 10.1101/2024.03.27.587085.

Major steps executed in this workflow:
1) Compute background of wells (CommonWellBackground/main_well_avg.m)
2) Split images into subimages (AlignSubImages/main_image_align.m)
3) Perform cell tracking (TrackCells/main_tracking.m)
4) Perform track reconnection (TrackCells/track_reconnect.m)
5) Perform generation tracking (GenTracking/main_gen_tracking.m)
6) Add track masses to get total mass per well (TotalMass/main_total_mass.m)
