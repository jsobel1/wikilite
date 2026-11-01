# Keep test side effects out of the user's filespace (CRAN policy):
# redirect the wikilite disk cache and the default graphics device to tempdir().
Sys.setenv(R_USER_CACHE_DIR = file.path(tempdir(), "wikilite-cache"))
grDevices::pdf(file.path(tempdir(), "Rplots.pdf"))
