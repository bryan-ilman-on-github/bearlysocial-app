import math


def BroMin(T, c, r, L, U, B, Tp, Tc, H_max, l_r, u):
    for b in range(r, B + 1):  # Loop from r to B.
        P = math.floor((b * H_max) / r)
        while P >= max(T / Tp, T / Tc, c):
            if P * r * l_r <= b * L and P * u <= b * U:
                return P, b
            P -= 1  # Decrement P.
    return "No feasible solution found."


def BroMax(T, c, r, L, U, B, Tp, Tc, H_max, l_r, u):
    for b in range(B, r - 1, -1):  # Loop from B down to r.
        P = math.floor((b * H_max) / r)
        while P >= max(T / Tp, T / Tc, c):
            if P * r * l_r <= b * L and P * u <= b * U:
                return P, b
            P -= 1  # Decrement P.
    return "No feasible solution found."

# Parameter values based on the table.
T = 10
c = 600  # Pick a value in the range 200–600.
r = 4   # Pick a value in the range 4–20.
L = 200
U = 2000
B = 20   # Pick a value in the range 20–60.
Tp = 10  # MB/s.
Tc = 20  # MB/s.
H_max = 10000
l_r = 1  # ms
u = 5    # ms

# Call the algorithms with these parameters.
result_bro_min = BroMin(T, c, r, L, U, B, Tp, Tc, H_max, l_r, u)
result_bro_max = BroMax(T, c, r, L, U, B, Tp, Tc, H_max, l_r, u)

# Print results.
print("Result from BroMin:", result_bro_min)
print("Result from BroMax:", result_bro_max)
