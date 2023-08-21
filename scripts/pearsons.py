#!/usr/bin/env python3  

from scipy.stats import pearsonr
import numpy as np
import argparse

def read_qmatrix(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()

    # Convert lines to floats
    lines = [list(map(float, line.strip().split())) for line in lines]

    n = len(lines)
    matrix = [[0 for _ in range(n)] for _ in range(n)]

    for i in range(n):
        for j, value in enumerate(lines[i]):
            matrix[i][j] = value
            matrix[j][i] = value

    return matrix

def pearsons_correlation(matrix1, matrix2):
    # Convert matrices to 1D arrays
    array1 = np.array(matrix1).flatten()
    array2 = np.array(matrix2).flatten()

    correlation, _ = pearsonr(array1, array2)
    return correlation

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Calculate Pearson's correlation coefficient between two Q-matrices.")
    parser.add_argument('q1', type=str, help="Path to the first Q-matrix.")
    parser.add_argument('q2', type=str, help="Path to the second Q-matrix.")
    args = parser.parse_args()

    q1 = read_qmatrix(args.q1)
    q2 = read_qmatrix(args.q2)

    correlation = pearsons_correlation(q1, q2)
    #print(q1)    
    #print(q2)
    print(f"Pearson's correlation coefficient between the matrices: {correlation}")
