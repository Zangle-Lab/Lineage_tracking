# Lineage_tracking
Code for QPI-based lineage tracking

Major steps executed in this workflow:
1) Compute background of wells (CommonWellBackground/main_well_avg.m)
2) Split images into subimages (AlignSubImages/main_image_align.m)
3) Perform cell tracking (TrackCells/main_tracking.m)
4) Perform track reconnection (TrackCells/track_reconnect.m)
5) Perform generation tracking (GenTracking/main_gen_tracking.m)
6) Add track masses to get total mass per well
