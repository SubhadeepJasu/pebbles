/*
 * Copyright (C) 2020 Purism SPC
 *
 * SPDX-License-Identifier: LGPL-2.1+
 *
 * Author: Alexander Mikhaylenko <alexander.mikhaylenko@puri.sm>
 */

#pragma once

#if !defined(_HANDY_INSIDE) && !defined(HANDY_COMPILATION)
#error "Only <handy.h> can be included directly."
#endif

#include <gtk/gtk.h>
#include "hdy-tab-view.h"

G_BEGIN_DECLS

#define HDY_TYPE_TAB (hdy_tab_get_type())

G_DECLARE_FINAL_TYPE (HdyTab, hdy_tab, HDY, TAB, GtkContainer)

HdyTab *hdy_tab_new (HdyTabView *view,
                     gboolean    pinned);

void hdy_tab_set_page (HdyTab     *self,
                       HdyTabPage *page);

gint hdy_tab_get_display_width (HdyTab *self);
void hdy_tab_set_display_width (HdyTab *self,
                                gint    width);

gboolean hdy_tab_get_hovering (HdyTab *self);
void     hdy_tab_set_hovering (HdyTab   *self,
                               gboolean  hovering);

gboolean hdy_tab_get_dragging (HdyTab *self);
void     hdy_tab_set_dragging (HdyTab   *self,
                               gboolean  dragging);

gboolean hdy_tab_get_inverted (HdyTab *self);
void     hdy_tab_set_inverted (HdyTab   *self,
                               gboolean  inverted);

void hdy_tab_set_fully_visible (HdyTab   *self,
                                gboolean  fully_visible);

G_END_DECLS
