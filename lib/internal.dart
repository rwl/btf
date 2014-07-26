/**
 * BTF, by Timothy A. Davis, Copyright (C) 2004-2011, University of Florida,
 * with support from Sandia National Laboratories.  All Rights Reserved.
 * Copyright (C) 2011 Richard Lincoln
 *
 * BTF is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This Module is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this Module; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
 *
 */

part of edu.ufl.cise.btf;

//public class Dbtf_internal extends Dbtf {

/**
 * Enable debugging and assertions.
 */
bool NDEBUG = true ;

void ASSERT (bool a)
{
	if (!NDEBUG)
	{
		assert(a) ;
	}
}

void ASSERT_INT (int a)
{
	ASSERT (a != 0) ;
}

/**
 * Enable diagnostic printing.
 */
bool NPRINT = true ;

void PRINTF (String format)//, Object... args)
{
	if (!NPRINT)
	{
		print (format);//, args) ;
	}
}

const int TRUE = 1 ;
const int FALSE = 0 ;
const int EMPTY = (-1) ;

int MIN (int a, int b)
{
	return (((a) < (b)) ?  (a) : (b)) ;
}

//}
