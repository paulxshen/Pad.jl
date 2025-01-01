using ArrayPadding
# include("../src/main.jl")

a = collect(reshape(1:16, 4, 4))

@assert pad(a, -1, 1) == [
    -1 -1 -1 -1 -1 -1
    -1 1 5 9 13 -1
    -1 2 6 10 14 -1
    -1 3 7 11 15 -1
    -1 4 8 12 16 -1
    -1 -1 -1 -1 -1 -1
]

@assert pad!(copy(a), -1, 1) == [
    -1 -1 -1 -1
    -1 6 10 -1
    -1 7 11 -1
    -1 -1 -1 -1
]

@assert pad(a, -1, 1, 0) == [
    -1 -1 -1 -1 -1
    -1 1 5 9 13
    -1 2 6 10 14
    -1 3 7 11 15
    -1 4 8 12 16
]

@assert pad!(copy(a), -1, 1, 0) == [
    -1 -1 -1 -1
    -1 6 10 14
    -1 7 11 15
    -1 8 12 16
]

@assert pad(a, -1, (0, 1), (1, 0)) == [
    -1 1 5 9 13
    -1 2 6 10 14
    -1 3 7 11 15
    -1 4 8 12 16
    -1 -1 -1 -1 -1
]

@assert pad!(copy(a), -1, (0, 1), (1, 0)) == [
    -1 5 9 13
    -1 6 10 14
    -1 7 11 15
    -1 -1 -1 -1
]

@assert pad(a, :periodic, (1, 1), (0, 0)) == [
    16 4 8 12 16
    13 1 5 9 13
    14 2 6 10 14
    15 3 7 11 15
    16 4 8 12 16
]

@assert pad!(copy(a), :periodic, (1, 1), (0, 0)) == [
    16 8 12 16
    14 6 10 14
    15 7 11 15
    16 8 12 16
]

@assert pad(a, :symmetric, 1) == [
    1 1 5 9 13 13
    1 1 5 9 13 13
    2 2 6 10 14 14
    3 3 7 11 15 15
    4 4 8 12 16 16
    4 4 8 12 16 16
]

@assert pad!(copy(a), :symmetric, 1) == [
    6 6 10 10
    6 6 10 10
    7 7 11 11
    7 7 11 11
]

@assert pad(a, :mirror, 1) == [
    6 2 6 10 14 10
    5 1 5 9 13 9
    6 2 6 10 14 10
    7 3 7 11 15 11
    8 4 8 12 16 12
    7 3 7 11 15 11
]

@assert pad!(copy(a), :mirror, 1) == [
    11 7 11 7
    10 6 10 6
    11 7 11 7
    10 6 10 6
]

@assert pad(a, :replicate, 1) == [
    1 1 5 9 13 13
    1 1 5 9 13 13
    2 2 6 10 14 14
    3 3 7 11 15 15
    4 4 8 12 16 16
    4 4 8 12 16 16
]

@assert pad!(copy(a), :replicate, 1) == [
    6 6 10 10
    6 6 10 10
    7 7 11 11
    7 7 11 11
]

using Zygote
using Zygote: Buffer

@assert withgradient(a) do a
    a = pad(a, 0, 1)
    sum(a)
end == (val=136, grad=([1.0 1.0 1.0 1.0; 1.0 1.0 1.0 1.0; 1.0 1.0 1.0 1.0; 1.0 1.0 1.0 1.0],))

@assert withgradient(a) do a
    a_ = Buffer(a)
    # a_ .= a
    copyto!(a_, a)
    pad!(a_, 0, 1)
    a = copy(a_)
    sum(a)
end == (val=34, grad=([0.0 0.0 0.0 0.0; 0.0 1.0 1.0 0.0; 0.0 1.0 1.0 0.0; 0.0 0.0 0.0 0.0],))