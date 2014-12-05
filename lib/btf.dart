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
library edu.ufl.cise.btf;

import 'dart:typed_data';

part 'internal.dart';
part 'maxtrans.dart';
part 'order.dart';
part 'strongcomp.dart';

/* ====================================================================== */
/* === BTF marking of singular columns ================================== */
/* ====================================================================== */

/// [flip] is a "negation about -1", and is used to mark an integer j
/// that is normally non-negative.  [flip(-1)] is -1.  [flip] of
/// a number > -1 is negative, and [flip] of a number < -1 is positive.
/// [flip(flip(j)) = j] for all integers j.  [unflip(j)] acts
/// like an "absolute value" operation, and is always >= -1. You can test
/// whether or not an integer j is "flipped" with the isFlipped(j)
/// macro.
int flip(int j) => -j - 2;

bool isFlipped(int j) => j < -1;

int unflip(int j) => isFlipped(j) ? flip(j) : j;

/* ====================================================================== */
/* === BTF version ====================================================== */
/* ====================================================================== */

/// All versions of BTF include these definitions.
/// As an example, to test if the version you are using is 1.2 or later:
///
///      if (VERSION >= versionCode(1, 2)) ...

const String DATE = "Jan 25, 2011";
int versionCode(int main, int sub) => main * 1000 + sub;
const int MAIN_VERSION = 1;
const int SUB_VERSION = 1;
const int SUBSUB_VERSION = 2;
final int VERSION = versionCode(MAIN_VERSION, SUB_VERSION);
