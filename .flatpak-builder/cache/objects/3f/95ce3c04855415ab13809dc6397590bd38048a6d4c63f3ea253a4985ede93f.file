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

#include "hdy-tab-view.h"

G_BEGIN_DECLS

gboolean hdy_tab_view_select_first_page (HdyTabView *self);
gboolean hdy_tab_view_select_last_page  (HdyTabView *self);

void hdy_tab_view_detach_page   (HdyTabView *self,
                                 HdyTabPage *page);
void hdy_tab_view_attach_page   (HdyTabView *self,
                                 HdyTabPage *page,
                                 gint        position);

HdyTabView *hdy_tab_view_create_window (HdyTabView *self);

G_END_DECLS
