/*
 * Copyright (C) 2020 Purism SPC
 *
 * Authors:
 * Julian Sparber <julian@sparber.net>
 *
 * SPDX-License-Identifier: LGPL-2.1+
 *
 */

#pragma once

#if !defined(_HANDY_INSIDE) && !defined(HANDY_COMPILATION)
#error "Only <handy.h> can be included directly."
#endif

#include <gtk/gtk.h>

#include "hdy-avatar.h"

G_BEGIN_DECLS

#define HDY_AVATAR_ICON_ERROR hdy_avatar_icon_error_quark()
GQuark  hdy_avatar_icon_error_quark (void);
#define HDY_AVATAR_ICON_ERROR_EMPTY 0

#define HDY_TYPE_AVATAR_ICON (hdy_avatar_icon_get_type())

G_DECLARE_FINAL_TYPE (HdyAvatarIcon, hdy_avatar_icon, HDY, AVATAR_ICON, GObject)

HdyAvatarIcon *hdy_avatar_icon_new (HdyAvatarImageLoadFunc  load_image,
                                    gpointer                user_data,
                                    GDestroyNotify          destroy);

G_END_DECLS
