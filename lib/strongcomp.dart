/// BTF, by Timothy A. Davis, Copyright (C) 2004-2011, University of Florida,
/// with support from Sandia National Laboratories.  All Rights Reserved.
/// Copyright (C) 2011 Richard Lincoln
///
/// BTF is free software; you can redistribute it and/or
/// modify it under the terms of the GNU Lesser General Public
/// License as published by the Free Software Foundation; either
/// version 2.1 of the License, or (at your option) any later version.
///
/// This Module is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
/// Lesser General Public License for more details.
///
/// You should have received a copy of the GNU Lesser General Public
/// License along with this Module; if not, write to the Free Software
/// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
part of edu.ufl.cise.btf;

/// Finds the strongly connected components of a graph, or equivalently, permutes
/// the matrix into upper block triangular form.  See btf.h for more details.
/// Input matrix and Q are not checked on input.
///
/// Copyright (c) 2004-2007.  Tim Davis, University of Florida,
/// with support from Sandia National Laboratories.  All Rights Reserved.

/// Flag [j] = UNVISITED if node j not visited yet.
const int unvisited = -2;

/// Flag [j] = UNASSIGNED if node j has been visited,
/// but not yet assigned to a strongly-connected
/// component (aka block).  Flag [j] = k (k in the
/// range 0 to nblocks-1) if node j has been visited
/// (and completed, with its postwork done) and
/// assigned to component k.
const int unassigned = -1;

/// BTF (C version) contains two versions of the depth-first-search, a
/// recursive one and a non-recursive one.  In BTF, the non-recursive
/// one is used.

/// Perform a depth-first-search of a graph, stored in an adjacency-list form.
/// The row indices of column j (equivalently, the out-adjacency list of node j)
/// are stored in Ai [Ap[j] ... Ap[j+1]-1].  Self-edge (diagonal entries) are
/// ignored.  Ap[0] must be zero, and thus nz = Ap[n] is the number of entries
/// in the matrix (or edges in the graph).  The row indices in each column need
/// not be in any particular order.  If an input column permutation is given,
/// node j (in the permuted matrix A*Q) is located in
/// Ai [Ap[Q[j]] ... Ap[Q[j]+1]-1].  This Q can be the same as the Match array
/// output from the maxtrans routine, for a square matrix that is structurally
/// full rank.
///
/// The algorithm is from the paper by Robert E. Tarjan, "Depth-first search and
/// linear graph algorithms," SIAM Journal on Computing, vol. 1, no. 2,
/// pp. 146-160, 1972.  The time taken by strongcomp is O(nnz(A)).
///
/// See also MC13A/B in the Harwell subroutine library (Iain S. Duff and John
/// K. Reid, "Algorithm 529: permutations to block triangular form," ACM Trans.
/// on Mathematical Software, vol. 4, no. 2, pp. 189-192, 1978, and "An
/// implementation of Tarjan's algorithm for the block triangular form of a
/// matrix," same journal, pp. 137-147.  This code is implements the same
/// algorithm as MC13A/B, except that the data structures are very different.
/// Also, unlike MC13A/B, the output permutation preserves the natural ordering
/// within each block.
///
/// [j] start the DFS at node j
/// [Ap] size n+1, column pointers for the matrix A
/// [Ai] row indices, size nz = Ap [n]
/// [Q] input column permutation
/// [time] size n, Time [j] = "time" that node j was first visited
/// [flag] size n, Flag [j]: see above
/// [low] size n, Low [j]: see definition below
/// [p_nblocks] size 1, number of blocks (aka strongly-connected-comp.)
/// [p_timestamp] size 1, current "time"
/// [Cstack] size n, output stack to hold nodes of components
/// [Jstack] size n, stack for the variable j
/// [Pstack] size n, stack for the variable p
void dfs(int j, final List<int> Ap, final List<int> Ai, final List<int> Q, List<int> time,
         List<int> flag, List<int> low, List<int> p_nblocks, List<int> p_timestamp,
         List<int> Cstack, List<int> Jstack, List<int> Pstack) {
  /* ------------------------------------------------------------------ */
  /* local variables, and initializations */
  /* ------------------------------------------------------------------ */

  /* local variables, but "global" to all DFS levels: */
  int chead; // top of Cstack
  int jhead; // top of Jstack and Pstack

  /* variables that are purely local to any one DFS level: */
  int i; // edge (j,i) considered; i can be next node to traverse
  int parent; // parent of node j in the DFS tree
  int pend; // one past the end of the adjacency list for node j
  int jj; // column j of A*Q is column jj of the input matrix A

  /* variables that need to be pushed then popped from the stack: */
  int p; // current index into the adj. list for node j
  /* the variables j and p are stacked in Jstack and Pstack */

  /* local copies of variables in the calling routine */
  int nblocks = p_nblocks[0];
  int timestamp = p_timestamp[0];

  /* ------------------------------------------------------------------ */
  /* start a DFS at node j (same as the recursive call dfs (EMPTY, j)) */
  /* ------------------------------------------------------------------ */

  chead = 0;
  /* component stack is empty */
  jhead = 0;
  /* Jstack and Pstack are empty */
  Jstack[0] = j;
  /* put the first node j on the Jstack */
  _assert(flag[j] == unvisited);

  while (jhead >= 0) {
    j = Jstack[jhead];
    /* grab the node j from the top of Jstack */

    /* determine which column jj of the A is column j of A*Q */
    jj = Q == null ? j : unflip(Q[j]);
    pend = Ap[jj + 1];
    /* j's row index list ends at Ai [pend-1] */

    if (flag[j] == unvisited) {

      /* ---------------------------------------------------------- */
      /* prework at node j */
      /* ---------------------------------------------------------- */

      /* node j is being visited for the first time */
      Cstack[++chead] = j; // push j onto the stack
      timestamp++; // get a timestamp
      time[j] = timestamp; // give the timestamp to node j
      low[j] = timestamp;
      flag[j] = unassigned; // flag node j as visited

      /* ---------------------------------------------------------- */
      /* set Pstack [jhead] to the first entry in column j to scan */
      /* ---------------------------------------------------------- */

      Pstack[jhead] = Ap[jj];
    }

    /* -------------------------------------------------------------- */
    /* DFS rooted at node j (start it, or continue where left off) */
    /* -------------------------------------------------------------- */

    for (p = Pstack[jhead]; p < pend; p++) {
      i = Ai[p];
      /* examine the edge from node j to node i */
      if (flag[i] == unvisited) {
        /* Node i has not been visited - start a DFS at node i.
         * Keep track of where we left off in the scan of adjacency list
         * of node j so we can restart j where we left off. */
        Pstack[jhead] = p + 1;
        /* Push i onto the stack and immediately break
         * so we can recurse on node i. */
        Jstack[++jhead] = i;
        _assert(time[i] == empty);
        _assert(low[i] == empty);
        /* break here to do what the recursive call dfs (j,i) does */
        break;
      } else if (flag[i] == unassigned) {
        /* Node i has been visited, but still unassigned to a block
         * this is a back or cross edge if Time [i] < Time [j].
         * Note that i might equal j, in which case this code does
         * nothing. */
        _assert(time[i] > 0);
        _assert(low[i] > 0);
        low[j] = min(low[j], time[i]);
      }
    }

    if (p == pend) {
      /* If all adjacent nodes of j are already visited, pop j from
       * Jstack and do the post work for node j.  This also pops p
       * from the Pstack. */
      jhead--;

      /* ---------------------------------------------------------- */
      /* postwork at node j */
      /* ---------------------------------------------------------- */

      /* determine if node j is the head of a component */
      if (low[j] == time[j]) {
        /* pop all nodes in this SCC from Cstack */
        while (_true != 0) {
          _assert(chead >= 0); // stack not empty (j in it)
          i = Cstack[chead--]; // pop a node from the Cstack
          _assert(i >= 0);
          _assert(flag[i] == unassigned);
          flag[i] = nblocks; // assign i to current block
          if (i == j) break; // current block ends at j
        }
        nblocks++; // one more block has been found
      }
      /* update Low [parent], if the parent exists */
      if (jhead >= 0) {
        parent = Jstack[jhead];
        low[parent] = min(low[parent], low[j]);
      }
    }
  }

  /* ------------------------------------------------------------------ */
  /* cleanup: update timestamp and nblocks */
  /* ------------------------------------------------------------------ */

  p_timestamp[0] = timestamp;
  p_nblocks[0] = nblocks;
}

/// Finds the strongly connected components of a graph, returning
/// a symmetric permutation.  The matrix A must be square, and is provided on
/// input in compressed-column form (see [maxtrans], above).  The diagonal of
/// the input matrix A (or A*Q if Q is provided on input) is ignored.
///
/// If Q is not null on input, then the strongly connected components of A*Q are
/// found.  Q may be flagged on input, where Q[k] < 0 denotes a flagged column k.
/// The permutation is j = unflip(Q [k]).  On output, Q is modified (the
/// flags are preserved) so that P*A*Q is in block upper triangular form.
///
/// If Q is null, then the permutation P is returned so that P*A*P' is in upper
/// block triangular form.
///
/// The vector R gives the block boundaries, where block b is in rows/columns
/// R[b] to R[b+1]-1 of the permuted matrix, and where b ranges from 1 to the
/// number of strongly connected components found.
///
/// [n] A is n-by-n in compressed column form
/// [Ap] size n+1
/// [Ai] size nz = Ap [n]
/// [Q] size n, input column permutation.  The permutation Q can
/// include a flag which indicates an unmatched row.
/// jold = unflip(Q [jnew]) is the permutation;
/// this function ingnores these flags.  On output, it is
/// modified according to the permutation P.
/// [P] size n.  P [k] = j if row and column j are kth row/col
/// in permuted matrix.
/// [R] size n+1.  kth block is in rows/cols R[k] ... R[k+1]-1
/// of the permuted matrix.
/// Returns the # of strongly connected components.
int strongcomp(final int n, final List<int> Ap, final List<int> Ai, List<int> Q, List<int> P, List<int> R) {
  final timestamp = new Int32List(1);
  final nblocks = new Int32List(1);

  /* ------------------------------------------------------------------ */
  /* get and initialize workspace */
  /* ------------------------------------------------------------------ */

  /* timestamp is incremented each time a new node is visited.
   *
   * Time [j] is the timestamp given to node j.
   *
   * Low [j] is the lowest timestamp of any node reachable from j via either
   * a path to any descendent of j in the DFS tree, or via a single edge to
   * an either an ancestor (a back edge) or another node that's neither an
   * ancestor nor a descendant (a cross edge).  If Low [j] is equal to
   * the timestamp of node j (Time [j]), then node j is the "head" of a
   * strongly connected component (SCC).  That is, it is the first node
   * visited in its strongly connected component, and the DFS subtree rooted
   * at node j spans all the nodes of the strongly connected component.
   *
   * The term "block" and "component" are used interchangebly in this code;
   * "block" being a matrix term and "component" being a graph term for the
   * same thing.
   *
   * When a node is visited, it is placed on the Cstack (for "component"
   * stack).  When node j is found to be an SCC head, all the nodes from the
   * top of the stack to node j itself form the nodes in the SCC.  This Cstack
   * is used for both the recursive and non-recursive versions.
   */

  final time = new Int32List(n);
  final flag = new Int32List(n);
  final low = P;
  /* use output array P as workspace for Low */
  final Cstack = R;
  /* use output array R as workspace for Cstack */

  /* stack for non-recursive dfs */
  final Jstack = new Int32List(n); // stack for j
  final Pstack = new Int32List(n); // stack for p

  for (int j = 0; j < n; j++) {
    flag[j] = unvisited;
    low[j] = empty;
    time[j] = empty;
    if (!_ndebug) {
      Cstack[j] = empty;
    }
    Jstack[j] = empty;
    Pstack[j] = empty;
  }

  timestamp[0] = 0;
  /* each node given a timestamp when it is visited */
  nblocks[0] = 0;
  /* number of blocks found so far */

  /* ------------------------------------------------------------------ */
  /* find the connected components via a depth-first-search */
  /* ------------------------------------------------------------------ */

  for (int j = 0; j < n; j++) {
    /* node j is unvisited or assigned to a block. Cstack is empty. */
    _assert(flag[j] == unvisited || (flag[j] >= 0 && flag[j] < nblocks[0]));
    if (flag[j] == unvisited) {
      /* non-recursive dfs (default) */
      dfs(j, Ap, Ai, Q, time, flag, low, nblocks, timestamp, Cstack, Jstack, Pstack);
    }
  }
  _assert(timestamp[0] == n);

  /* ------------------------------------------------------------------ */
  /* construct the block boundary array, R */
  /* ------------------------------------------------------------------ */

  for (int b = 0; b < nblocks[0]; b++) {
    R[b] = 0;
  }
  for (int j = 0; j < n; j++) {
    /* node j has been assigned to block b = Flag [j] */
    _assert(time[j] > 0 && time[j] <= n);
    _assert(low[j] > 0 && low[j] <= n);
    _assert(flag[j] >= 0 && flag[j] < nblocks[0]);
    R[flag[j]]++;
  }
  /* R [b] is now the number of nodes in block b.  Compute cumulative sum
   * of R, using Time [0 ... nblocks-1] as workspace. */
  time[0] = 0;
  for (int b = 1; b < nblocks[0]; b++) {
    time[b] = time[b - 1] + R[b - 1];
  }
  for (int b = 0; b < nblocks[0]; b++) {
    R[b] = time[b];
  }
  R[nblocks[0]] = n;

  /* ------------------------------------------------------------------ */
  /* construct the permutation, preserving the natural order */
  /* ------------------------------------------------------------------ */

  if (!_ndebug) {
    for (int k = 0; k < n; k++) {
      P[k] = empty;
    }
  }

  for (int j = 0; j < n; j++) {
    /* place column j in the permutation */
    P[time[flag[j]]++] = j;
  }

  if (!_ndebug) {
    for (int k = 0; k < n; k++) {
      _assert(P[k] != empty);
    }
  }

  /* Now block b consists of the nodes k1 to k2-1 in the permuted matrix,
   * where k1 = R [b] and k2 = R [b+1].  Row and column j of the original
   * matrix becomes row and column P [k] of the permuted matrix.  The set of
   * of rows/columns (nodes) in block b is given by P [k1 ... k2-1], and this
   * set is sorted in ascending order.  Thus, if the matrix consists of just
   * one block, P is the identity permutation. */

  /* ------------------------------------------------------------------ */
  /* if Q is present on input, set Q = Q*P' */
  /* ------------------------------------------------------------------ */

  if (Q != null) {
    /* We found a symmetric permutation P for the matrix A*Q.  The overall
     * permutation is thus P*(A*Q)*P'.  Set Q=Q*P' so that the final
     * permutation is P*A*Q.  Use Time as workspace.  Note that this
     * preserves the negative values of Q if the matrix is structurally
     * singular. */
    for (int k = 0; k < n; k++) {
      time[k] = Q[P[k]];
    }
    for (int k = 0; k < n; k++) {
      Q[k] = time[k];
    }
  }

  /* ------------------------------------------------------------------ */
  /* how to traverse the permuted matrix */
  /* ------------------------------------------------------------------ */

  /* If Q is not present, the following code can be used to traverse the
   * permuted matrix P*A*P'
   *
   *      // compute the inverse of P
   *      for (knew = 0 ; knew < n ; knew++)
   *      {
   *          // row and column kold in the old matrix is row/column knew
   *          // in the permuted matrix P*A*P'
   *          kold = P [knew] ;
   *          Pinv [kold] = knew ;
   *      }
   *      for (b = 0 ; b < nblocks ; b++)
   *      {
   *          // traverse block b of the permuted matrix P*A*P'
   *          k1 = R [b] ;
   *          k2 = R [b+1] ;
   *          nk = k2 - k1 ;
   *          for (jnew = k1 ; jnew < k2 ; jnew++)
   *          {
   *              jold = P [jnew] ;
   *              for (p = Ap [jold] ; p < Ap [jold+1] ; p++)
   *              {
   *                  iold = Ai [p] ;
   *                  inew = Pinv [iold] ;
   *                  // Entry in the old matrix is A (iold, jold), and its
   *                  // position in the new matrix P*A*P' is (inew, jnew).
   *                  // Let B be the bth diagonal block of the permuted
   *                  // matrix.  If inew >= k1, then this entry is in row/
   *                  // column (inew-k1, jnew-k1) of the nk-by-nk matrix B.
   *                  // Otherwise, the entry is in the upper block triangular
   *                  // part, not in any diagonal block.
   *              }
   *          }
   *      }
   *
   * If Q is present replace the above statement
   *          jold = P [jnew] ;
   * with
   *          jold = Q [jnew] ;
   * or
   *          jold = BTF_UNFLIP (Q [jnew]) ;
   *
   * then entry A (iold,jold) in the old (unpermuted) matrix is at (inew,jnew)
   * in the permuted matrix P*A*Q.  Everything else remains the same as the
   * above (simply replace P*A*P' with P*A*Q in the above comments).
   */

  /* ------------------------------------------------------------------ */
  /* return # of blocks / # of strongly connected components */
  /* ------------------------------------------------------------------ */

  return nblocks[0];
}
