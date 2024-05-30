options(repos=c("http://cloud.r-project.org", "http://bioconductor.org/packages/3.9/bioc", "http://bioconductor.org/packages/3.9/data/annotation"))

installV <- function(package) {
    # install from bioconductor
    tmp <- unlist(strsplit(package, "_"))
    pkgname <- tmp[1]
    version <- paste(tmp[2:length(tmp)], collapse="_")
    devtools::install_version(package=pkgname, version=version, dependencies=FALSE, upgrade='never')
}

installV("BiocParallel_1.18.1") # specific version unavailable in conda
