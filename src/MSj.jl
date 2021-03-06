"""
Main module for `MSj.jl`-- A Julia package to load and process mass spectrometry data.

"""
module MSj


using Statistics           # used for Perasons correlation calculation
using LsqFit               # used for curve fitting
using FFTViews             # used for fft
using Interpolations       # used for interpolation
using LinearAlgebra        # used for matrix operation 
using LightXML, Codecs     # used for mzXML file import
using Unicode              # used for file io
using Combinatorics        # used for factorial & permutations
using DataStructures       # used for PriorityQueue
using Printf               # used for @sprintf
using Libz                 # used for zlib compression (mzxml import)

import Base: +, -, *, /


include("types.jl")
include("Io.jl")
include("msscans.jl")
include("mzxml.jl")
include("process.jl")
include("extract.jl")
include("utilities.jl")
include("isotopes.jl")


# Submodules
# ----------

include("plots.jl")



end # module
