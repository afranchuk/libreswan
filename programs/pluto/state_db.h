/* State table indexed by serialno, for libreswan
 *
 * Copyright (C) 2017 Andrew Cagney
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.  See <http://www.fsf.org/copyleft/gpl.txt>.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 */

#ifndef _state_db_h_
#define _state_db_h_

#include "state_entry.h"

/*
 * XXX: all of these should not be public.
 */

extern struct state_hash_table statetable;
extern void hash_icookie(struct state *st);
extern struct state_entry *icookie_chain(const uint8_t *icookie);

/*
 * Return the linked list of states that match ICOOKIE+RCOOKIE hash.
 */
struct state_entry **hash_by_state_cookies(struct state_hash_table *table,
					   const uint8_t *icookie,
					   const uint8_t *rcookie);

/*
 * Insert the state into the hash table using cookies as the hash.
 */
void insert_by_state_cookies(struct state_hash_table *table,
			     struct state_entry *entry,
			     const uint8_t *icookie, const uint8_t *rcookie);

#endif
