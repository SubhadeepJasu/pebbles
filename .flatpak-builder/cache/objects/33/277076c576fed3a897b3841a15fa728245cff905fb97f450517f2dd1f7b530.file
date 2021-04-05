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

#define HDY_TYPE_TAB_BOX (hdy_tab_box_get_type())

G_DECLARE_FINAL_TYPE (HdyTabBox, hdy_tab_box, HDY, TAB_BOX, GtkContainer)

void hdy_tab_box_set_view (HdyTabBox  *self,
                           HdyTabView *view);
void hdy_tab_box_set_adjustment (HdyTabBox     *self,
                                 GtkAdjustment *adjustment);
void hdy_tab_box_set_block_scrolling (HdyTabBox *self,
                                      gboolean   block_scrolling);

void hdy_tab_box_attach_page (HdyTabBox  *self,
                              HdyTabPage *page,
                              gint        position);
void hdy_tab_box_detach_page (HdyTabBox  *self,
                              HdyTabPage *page);
void hdy_tab_box_select_page (HdyTabBox  *self,
                              HdyTabPage *page);

void hdy_tab_box_try_focus_selected_tab (HdyTabBox  *self);
gboolean hdy_tab_box_is_page_focused (HdyTabBox  *self,
                                      HdyTabPage *page);

void hdy_tab_box_set_extra_drag_dest_targets (HdyTabBox     *self,
                                              GtkTargetList *extra_drag_dest_targets);

gboolean hdy_tab_box_get_expand_tabs (HdyTabBox *self);
void     hdy_tab_box_set_expand_tabs (HdyTabBox *self,
                                      gboolean   expand_tabs);

gboolean hdy_tab_box_get_inverted (HdyTabBox *self);
void     hdy_tab_box_set_inverted (HdyTabBox *self,
                                   gboolean   inverted);

G_END_DECLS
