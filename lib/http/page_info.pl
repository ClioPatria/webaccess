/*  Part of ClioPatria SeRQL and SPARQL server

    Author:        Jan Wielemaker
    E-mail:        J.Wielemaker@cs.vu.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 2010, University of Amsterdam,
		   VU University Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- module(http_page_info,
	  [ page_content_type/2		% +URL, -MimeType
	  ]).
:- use_module(library(http/http_open)).
:- use_module(library(uri)).

/** <module> Get info on external web links
*/


%%	page_content_type(+URL, -ContentType:atom) is semidet.
%
%	Query the external resource using   a =HEAD= request, extracting
%	the content-type as an atom. Extracted  values are cached. Fails
%	if the content-type cannot be extracted due to errors.
%
%	@bug	Failures shouldbe retried after some time.

:- dynamic
	content_type_cache/2.

page_content_type(URL, MimeType) :-
	content_type_cache(URL, Type), !,
	atom(Type),
	Type = MimeType.
page_content_type(URL, MimeType) :-
	uri_components(URL, Components),
	uri_data(scheme, Components, Scheme),
	Scheme == http,
	catch(http_open(URL, Stream,
			[ method(head),
			  header(content_type, Type)
			]), _, fail),
	close(Stream),
	assertz(content_type_cache(URL, Type)),
	MimeType = Type.
page_content_type(URL, _) :-
	assertz(content_type_cache(URL, meta(fail))),
	fail.
