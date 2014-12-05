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

/// Enable debugging and assertions.
void set debug(bool d) {
  _ndebug = !d;
}

bool _ndebug = true;

void _assert(bool a) {
  if (!_ndebug) {
    assert(a);
  }
}

const int _true = 1;
const int _false = 0;
const int empty = (-1);

int min(int a, int b) => a < b ? a : b;
