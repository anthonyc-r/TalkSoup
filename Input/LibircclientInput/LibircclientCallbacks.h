/***************************************************************************
                                callbacks.h
                          -------------------
    copyright            : (C) 2019 Anthony Conh-Richardby
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
 
#include "libircclient.h"
#import "LibircclientConnection.h"

void init_libircclient_callbacks();

LibircclientConnection *object_for_session(irc_session_t *session);

void set_object_for_session(id object, irc_session_t *session);

void event_connect(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_notice(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_topic(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_channel(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_channel_notice(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_channel(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_numeric(irc_session_t *session, unsigned int event, const char *origin, const char **params, unsigned int count);

void event_join(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_ctcp_req(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_mode(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_part(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_quit(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_nick(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_umode(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_topic(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);

void event_kick(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count);
